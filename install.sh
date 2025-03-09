#!/bin/bash

set -o errexit  # Exit on error
set -o pipefail # Exit when a command in a pipe fails
# set -o nounset  # Exit when using an undeclared variable

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_TIME=$SECONDS

getPackageInstallState() {
    local package_name=$1
    dpkg-query --show --showformat '${db:Status-Status}\n' "$package_name" | grep --quiet --line-regexp "installed"
    return $?
}

initDockerEnvironment() {
    local running_containers=$(docker ps --quiet)
    if [[ -n $running_containers ]]; then
        printLog "error" "Unable to initialize environment while containers are running!"
        return 1
    fi

    local stopped_containers=$(docker ps --quiet --all)
    if [[ -n $stopped_containers ]]; then
        printLog "error" "Unable to initialize environment while stopped containers exist!"
        return 1
    fi

    local custom_networks=$(docker network ls --format '{{.Name}}' | grep --extended-regexp --invert-match 'bridge|host|none')
    if [[ -n $custom_networks ]]; then
        printLog "error" "Unable to initialize environment while custom networks exist!"
        return 1
    fi

    # --------------------------------------------------
    docker network create --driver bridge --subnet 172.17.1.0/24 --gateway 172.17.1.1 'caddy'
    docker network create --driver bridge --subnet 172.17.2.0/24 --gateway 172.17.2.1 'cloud'
    docker network create --driver bridge --subnet 172.17.3.0/24 --gateway 172.17.3.1 'iot'
    docker network create --driver bridge --subnet 172.17.4.0/24 --gateway 172.17.4.1 'mail'
    docker network create --driver bridge --subnet 172.17.5.0/24 --gateway 172.17.5.1 'media'
    docker network create --driver bridge --subnet 172.17.6.0/24 --gateway 172.17.6.1 'monitor'
    docker network create --driver bridge --subnet 172.17.7.0/24 --gateway 172.17.7.1 'other'
    docker network create --driver bridge --subnet 172.17.8.0/24 --gateway 172.17.8.1 'system'
    docker network create --driver bridge --subnet 172.17.9.0/24 --gateway 172.17.9.1 'tools'

    printLog "success" "Docker environment successfully initialized."
    return 0
}

pruneDockerEnvironment() {
    local running_containers=$(docker ps --quiet)
    if [[ -n $running_containers ]]; then
        docker stop $running_containers || {
            printLog "error" "Failed to stop running containers!"
            return 1
        }
    fi

    local stopped_containers=$(docker ps --quiet --all)
    if [[ -n $stopped_containers ]]; then
        docker rm --force $stopped_containers || {
            printLog "error" "Failed to remove stopped containers!"
            return 1
        }
    fi

    local custom_networks=$(docker network ls --format '{{.Name}}' | grep --extended-regexp --invert-match 'bridge|host|none')
    if [[ -n $custom_networks ]]; then
        docker network rm $custom_networks || {
            printLog "error" "Failed to remove custom networks!"
            return 1
        }
    fi

    # --------------------------------------------------
    docker system prune --all --force --volumes || {
        printLog "error" "Failed to prune docker system!"
        return 1
    }

    printLog "success" "Docker environment successfully pruned."
    return 0
}

printHelp() {
    echo "Usage: $SCRIPT_NAME [OPTIONS] TASK"
    echo "Options:"
    echo "  -h, --help          Display this help message."
    echo "Tasks:"
    echo "  init                Init docker environment."
    echo "  prune               Prune docker environment."
    return 0
}
printLog() {
    local log_type=$1
    local log_text=$2

    case $log_type in
        "error")
            echo -e "\e[1;31m$log_text\e[0m"
            ;;
        "warn")
            echo -e "\e[1;33m$log_text\e[0m"
            ;;
        "info")
            echo -e "\e[1;34m$log_text\e[0m"
            ;;
        "success")
            echo -e "\e[1;32m$log_text\e[0m"
            ;;
        *)
            echo -e "$log_text"
            ;;
    esac
    return 0
}

main() {
    # --------------------------------------------------
    # pre checks
    if [[ $EUID -ne 0 ]]; then
        printLog "error" "Script has to be run with root user privileges!"
        return 1
    fi

    getPackageInstallState 'docker-ce' || {
        printLog "error" "Required package 'docker-ce' is not installed!"
        return 1
    }

    # --------------------------------------------------
    # variables

    # --------------------------------------------------
    # parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            init)
                readonly docker_init='true'
                break;
                ;;
            prune)
                readonly docker_prune='true'
                break;
                ;;
            -h | --help)
                printHelp
                return 0
                ;;
            *)
                printLog "error" "Invalid argument; use --help for further information!"
                return 1
                ;;
        esac
        shift
    done

    if ! [[ -n $docker_init || -n $docker_prune ]]; then
        printLog "error" "No tasks specified; use --help for further information!"
        return 1
    fi

    # --------------------------------------------------
    if [[ -n $docker_init ]]; then
        printLog "info" "Current task: Init docker environment."
        initDockerEnvironment
    fi

    if [[ -n $docker_prune ]]; then
        printLog "info" "Current task: Prune docker environment."
        pruneDockerEnvironment
    fi

    # --------------------------------------------------
    local run_time=$((SECONDS - SCRIPT_TIME))
    printLog "success" "Script finished successfully. Execution time: $run_time seconds."
    return 0
}

main "$@"
exit $?

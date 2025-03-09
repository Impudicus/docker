# Tdarr

## Transcode Options
1. Migz Remove Image Formats From File
2. Migz Order Streams
3. Migz Clean Audio Streams (ger)
4. Migz Clean Subtitle Streams (ger)
5. Nvidia GPU & FFMPEG by Migz
6. New File Size Check (optional)

## Template
``` javascript
// Use the same calculation used for currentBitrate but divide it in half to get targetBitrate.
// Logic of h265 can be half the bitrate as h264 without losing quality.
// eslint-disable-next-line no-bitwise
  if (targetBitrate > 4750) {
    targetBitrate = 4750;
  }

...
// Set bitrateSettings variable using bitrate information calulcated earlier.
bitrateSettings = `-b:v ${targetBitrate}k -maxrate ${targetBitrate}k -bufsize ${targetBitrate}k`;
```

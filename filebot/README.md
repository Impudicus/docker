# Filebot

## Templates

### Movies
``` javascript
/movies/
{n.colon(' ').ascii().removeAll(/[-!?'.]/)} ({y})
/
{n.colon(' ').ascii().removeAll(/[-!?'.]/)} ({y}) 
[
{any{source}{vs}{'HDTV'}
	.replaceAll( '[Aa][Mm][Aa][Zz][Oo][Nn]','AMAZON')
	.replaceAll( '[Bb][Ll][Uu][Rr][Aa][Yy]','BLURAY')
	.replaceAll( '[Nn][Ee][Tt][Ff][Ll][Ii][Xx]','NETFLIX')
	.replaceAll( '[Ww][Ee][Bb][Hh][Dd]','WEB')
}
-
{any{vf}{'1080p'}}
]
[
{any{ac}{'AAC'}
	.replaceAll('MLP','TrueHD')
}
-
{any{channels}{'2.0'}}
]
[
{any{vc}{vcf}{'AVC'}
	.replaceAll('AVC|avc','AVC')
	.replaceAll('X264|x264','AVC')
	.replaceAll('H264|h264','AVC')
	.replaceAll('X265|x265','HEVC')
	.replaceAll('H265|h265','HEVC')
	.replaceAll('HEVC|hevc','HEVC')
}
]
```
### Series
``` javascript
/series/
{n.colon(' ').ascii().removeAll(/[-!?'.]/)} ({y})
/
{n.colon(' ').ascii().removeAll(/[-!?'.]/)} {s00e00} 
[
{any{source}{vs}{'HDTV'}
	.replaceAll( '[Aa][Mm][Aa][Zz][Oo][Nn]','AMAZON')
	.replaceAll( '[Bb][Ll][Uu][Rr][Aa][Yy]','BLURAY')
	.replaceAll( '[Nn][Ee][Tt][Ff][Ll][Ii][Xx]','NETFLIX')
	.replaceAll( '[Ww][Ee][Bb][Hh][Dd]','WEB')
}
-
{any{vf}{'1080p'}}
]
[
{any{ac}{'AAC'}
	.replaceAll('MLP','TrueHD')
}
-
{any{channels}{'2.0'}}
]
[
{any{vc}{vcf}{'AVC'}
	.replaceAll('AVC|avc','AVC')
	.replaceAll('X264|x264','AVC')
	.replaceAll('H264|h264','AVC')
	.replaceAll('X265|x265','HEVC')
	.replaceAll('H265|h265','HEVC')
	.replaceAll('HEVC|hevc','HEVC')
}
]
```

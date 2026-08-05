# Usage guide

## Command synopsis

```text
ytclip [options] URL [START [END]]
```

`URL` must begin with `http://` or `https://`. Quote URLs in the shell because
YouTube URLs can contain characters such as `&` that the shell otherwise
interprets.

## Downloading a complete video

```bash
ytclip 'https://www.youtube.com/watch?v=VIDEO_ID'
```

`ytclip` selects the best available video/audio combination, asks `yt-dlp` to
merge it as MP4, embeds available metadata and a thumbnail, and refuses to
expand playlist URLs into multiple downloads.

The default filename is:

```text
Video title [VIDEO_ID].mp4
```

The actual container can vary if the source formats cannot be represented as
MP4; `yt-dlp` and `ffmpeg` make the final compatibility decision.

## Downloading an excerpt

Provide both a start and end timestamp:

```bash
ytclip 'https://youtu.be/VIDEO_ID' 1:30 2:45
```

Or provide only the start to continue through the end:

```bash
ytclip 'https://youtu.be/VIDEO_ID' 1:30
```

Excerpt filenames include the requested range:

```text
Video title [VIDEO_ID] [1-30-2-45].mp4
```

`--force-keyframes-at-cuts` asks `ffmpeg` to re-encode around the cut so the
requested boundaries are more accurate. Segment downloads can therefore take
longer than an unmodified full-video download.

## Timestamp formats

The following forms are accepted:

| Form | Example | Meaning |
| --- | --- | --- |
| Seconds | `90` | 1 minute, 30 seconds |
| Minutes and seconds | `1:30` | 1 minute, 30 seconds |
| Hours, minutes, seconds | `01:02:03` | 1 hour, 2 minutes, 3 seconds |
| Fractional seconds | `1:30.500` | 1 minute, 30.5 seconds |

When colons are used, seconds must be below 60. In `HH:MM:SS`, minutes must
also be below 60. The end timestamp must be later than the start timestamp.

## Audio-only downloads

Use `-a` or `--audio-only` to extract a high-quality MP3:

```bash
ytclip --audio-only 'https://youtu.be/VIDEO_ID'
ytclip -a 'https://youtu.be/VIDEO_ID' 3:10 4:00
```

## Output directory

Downloads are saved in the current directory unless `-o` or `--output-dir` is
provided. A missing destination directory is created automatically.

```bash
ytclip -o ~/Videos 'https://youtu.be/VIDEO_ID'
ytclip --output-dir '/path/with spaces' 'https://youtu.be/VIDEO_ID' 30 60
```

## Interactive use

Running `ytclip` without arguments in a terminal prompts for a URL. Scripts and
non-interactive sessions must always provide the URL as an argument.

## Options

| Option | Purpose |
| --- | --- |
| `-a`, `--audio-only` | Extract MP3 audio instead of saving video |
| `-o DIR`, `--output-dir DIR` | Select the destination directory |
| `-h`, `--help` | Display built-in help |
| `-V`, `--version` | Display the `ytclip` version |

Options must appear before the URL. Use `--` before a URL beginning with a
hyphen, although ordinary HTTP URLs do not require it.

## Exit behavior

Argument and dependency errors exit with status `2`. Once `yt-dlp` starts,
`ytclip` becomes the `yt-dlp` process, so download failures and interrupts use
`yt-dlp`'s own exit status. Pressing Ctrl+C interrupts the active download.

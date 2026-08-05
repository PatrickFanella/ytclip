# Troubleshooting

## `yt-dlp is not installed`

On Arch Linux, install the official repository package:

```bash
sudo pacman -S --needed yt-dlp
```

Confirm that the executable is available:

```bash
command -v yt-dlp
yt-dlp --version
```

## `ffmpeg is not installed`

Timestamp cuts, format merging, metadata, thumbnails, and MP3 extraction need
`ffmpeg`:

```bash
sudo pacman -S --needed ffmpeg
ffmpeg -version
```

## `ytclip: command not found`

The installer uses `~/.local/bin` by default. Confirm the command exists and
that the directory is on `PATH`:

```bash
ls -l ~/.local/bin/ytclip
printf '%s\n' "$PATH"
```

For Bash, add this to `~/.bashrc` if necessary:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new shell or run `source ~/.bashrc`.

## A URL containing `&` behaves strangely

Quote the URL so the shell does not interpret it:

```bash
ytclip 'https://www.youtube.com/watch?v=VIDEO_ID&t=90s'
```

The URL's own `t=` parameter does not define a clip. Pass explicit positional
timestamps to `ytclip` when you want an excerpt.

## The cut is slow

Accurate cuts use `--force-keyframes-at-cuts`, which can require re-encoding.
This costs CPU time but avoids visibly snapping every cut to a distant existing
keyframe.

## YouTube requests sign-in or rejects the request

First update the official package and retry:

```bash
sudo pacman -Syu yt-dlp
```

Authentication and site-side access restrictions are handled by `yt-dlp`, not
by `ytclip`. Consult `yt-dlp --help` for cookie and browser-profile options.
`ytclip` intentionally does not accept or store credentials.

## Diagnosing the command

Check the wrapper and its dependencies:

```bash
ytclip --version
command -v ytclip yt-dlp ffmpeg
```

Run the repository's offline tests from the checkout:

```bash
./tests/test.sh
```

# ytclip

`ytclip` is a small Bash command for downloading a complete YouTube video or
only a timestamped excerpt. It wraps `yt-dlp` and `ffmpeg` with a deliberately
small interface and validates timestamps before starting a download. It also
installs Bash completion. The current version is 1.0.0.

> Download only media you are permitted to save. You are responsible for
> complying with copyright law and the source site's terms.

## Requirements

- Bash 4.3 or newer
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp)
- [`ffmpeg`](https://ffmpeg.org/)

On Arch Linux:

```bash
sudo pacman -S --needed yt-dlp ffmpeg
```

## Install

Clone the repository and run the installer:

```bash
git clone https://github.com/subculture-collective/ytclip.git
cd ytclip
./install.sh
```

For development, link the installed command to this checkout so changes take
effect immediately:

```bash
./install.sh --link
```

The default destination is `~/.local/bin/ytclip`, with completion in
`~/.local/share/bash-completion/completions/ytclip`. Ensure `~/.local/bin` is
on your `PATH`. Use `./install.sh --prefix DIR` for another prefix. An existing
file that differs is moved aside with a `.backup.<timestamp>` suffix.

## Quick start

```bash
# Entire video
ytclip 'https://youtu.be/VIDEO_ID'

# From 1:30 through 2:45
ytclip 'https://youtu.be/VIDEO_ID' 1:30 2:45

# From 1:30 through the end
ytclip 'https://youtu.be/VIDEO_ID' 1:30

# Extract a section as MP3
ytclip --audio-only 'https://youtu.be/VIDEO_ID' 3:10 4:00

# Choose the destination
ytclip --output-dir ~/Videos 'https://youtu.be/VIDEO_ID'
```

Timestamps accept seconds (`90`), `MM:SS` (`1:30`), or `HH:MM:SS`
(`01:02:03`), with optional milliseconds.

## Documentation

- [Complete usage guide](docs/usage.md)
- [Troubleshooting](docs/troubleshooting.md)
- Run `ytclip --help` for the concise command reference.

## Development

The tests replace `yt-dlp` and `ffmpeg` with local recording fakes, so they do
not access YouTube or download media:

```bash
./tests/test.sh
```

To check Bash syntax directly:

```bash
bash -n bin/ytclip install.sh tests/test.sh
```

## Repository layout

```text
bin/ytclip                 Main command
completions/bash/ytclip    Bash completion
docs/                      User documentation
install.sh                 Copy or link a per-user installation
tests/test.sh              Offline CLI smoke tests
```

## Contributing

Report bugs and request features in
[GitHub issues](https://github.com/subculture-collective/ytclip/issues). Send
code as a pull request on GitHub against `main`; CI runs `tests/test.sh` on
every pull request.

## License

MIT. See [LICENSE](LICENSE).

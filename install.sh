#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--copy|--link] [--prefix DIR]

Install ytclip and its Bash completion for the current user.

Options:
  --copy          Copy files into the prefix (default)
  --link          Symlink files to this checkout for development
  --prefix DIR    Installation prefix (default: ~/.local)
  -h, --help      Show this help
EOF
}

die() {
  printf 'install.sh: error: %s\n' "$*" >&2
  exit 2
}

mode=copy
prefix="${HOME:?HOME is not set}/.local"

while (($#)); do
  case "$1" in
    --copy) mode=copy; shift ;;
    --link) mode=link; shift ;;
    --prefix)
      (($# >= 2)) || die '--prefix requires a directory'
      prefix="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source_command="$repo_dir/bin/ytclip"
source_completion="$repo_dir/completions/bash/ytclip"
command_dir="$prefix/bin"
completion_dir="$prefix/share/bash-completion/completions"
command_target="$command_dir/ytclip"
completion_target="$completion_dir/ytclip"

[[ -x "$source_command" ]] || die "source command is not executable: $source_command"
[[ -f "$source_completion" ]] || die "completion file is missing: $source_completion"

mkdir -p -- "$command_dir" "$completion_dir"

backup_if_different() {
  local source="$1" target="$2" backup
  [[ -e "$target" || -L "$target" ]] || return 0

  if [[ -f "$target" ]] && cmp -s -- "$source" "$target"; then
    rm -f -- "$target"
    return 0
  fi

  backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
  mv -- "$target" "$backup"
  printf 'Backed up existing file: %s\n' "$backup" >&2
}

backup_if_different "$source_command" "$command_target"
backup_if_different "$source_completion" "$completion_target"

if [[ "$mode" == link ]]; then
  ln -s -- "$source_command" "$command_target"
  ln -s -- "$source_completion" "$completion_target"
else
  install -m 0755 -- "$source_command" "$command_target"
  install -m 0644 -- "$source_completion" "$completion_target"
fi

printf 'Installed command: %s\n' "$command_target"
printf 'Installed Bash completion: %s\n' "$completion_target"

case ":$PATH:" in
  *":$command_dir:"*) ;;
  *) printf 'Note: add %s to PATH before using ytclip.\n' "$command_dir" >&2 ;;
esac

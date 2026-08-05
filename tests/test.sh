#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
ytclip="$repo_dir/bin/ytclip"
temp_dir="$(mktemp -d)"
trap 'rm -rf -- "$temp_dir"' EXIT

mock_bin="$temp_dir/bin"
mkdir -p -- "$mock_bin" "$temp_dir/output"

cat >"$mock_bin/yt-dlp" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$YTCLIP_TEST_LOG"
EOF
cat >"$mock_bin/ffmpeg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$mock_bin/yt-dlp" "$mock_bin/ffmpeg"

export PATH="$mock_bin:/usr/bin:/bin"
export YTCLIP_TEST_LOG="$temp_dir/arguments.log"

tests=0

pass() {
  tests=$((tests + 1))
  printf 'ok %d - %s\n' "$tests" "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_log_line() {
  grep -Fqx -- "$1" "$YTCLIP_TEST_LOG" || fail "missing recorded argument: $1"
}

[[ "$("$ytclip" --version)" == 'ytclip 1.0.0' ]] || fail 'version output'
pass 'prints the version'

"$ytclip" --help | grep -Fq 'ytclip [options] URL [START [END]]' || fail 'help output'
pass 'prints help'

if "$ytclip" https://youtu.be/test 1:70 2:00 >/dev/null 2>&1; then
  fail 'invalid timestamp was accepted'
fi
pass 'rejects an invalid timestamp'

if "$ytclip" https://youtu.be/test 2:00 1:30 >/dev/null 2>&1; then
  fail 'reversed range was accepted'
fi
pass 'rejects a reversed range'

"$ytclip" -o "$temp_dir/output" https://youtu.be/test 1:30 2:45 >/dev/null 2>&1
assert_log_line '--no-playlist'
assert_log_line '--download-sections'
assert_log_line '*1:30-2:45'
assert_log_line '--force-keyframes-at-cuts'
assert_log_line 'https://youtu.be/test'
pass 'constructs a timestamped video download'

"$ytclip" --audio-only https://youtu.be/test >/dev/null 2>&1
assert_log_line '--extract-audio'
assert_log_line '--audio-format'
assert_log_line 'mp3'
pass 'constructs an audio-only download'

"$ytclip" https://youtu.be/test 90 >/dev/null 2>&1
assert_log_line '*90-inf'
pass 'supports an open-ended clip'

printf '1..%d\n' "$tests"

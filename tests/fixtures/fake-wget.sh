#!/bin/sh
# Fake wget: intercept reviewdog install.sh download
# Supports both "wget -O - URL" (stdout) and "wget -O FILE URL" (file output)
FAKE_INSTALL="${FAKE_INSTALL_SCRIPT:-/tmp/fake-reviewdog-install.sh}"
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -O|--output-document) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *reviewdog*)
    if [ -n "$out" ] && [ "$out" != "-" ]; then
      cat "$FAKE_INSTALL" > "$out"
    else
      cat "$FAKE_INSTALL"
    fi
    exit 0
    ;;
esac
exec /usr/bin/wget "$@"

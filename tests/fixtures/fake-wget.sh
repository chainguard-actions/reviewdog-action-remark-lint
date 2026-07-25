#!/bin/sh
# Fake wget: intercepts reviewdog install.sh download.
# Supports both "wget -O - URL | sh" (stdout) and "wget -O FILE URL" (file) forms.
# Also supports -q (quiet) flag which is ignored.

out="-"
prev=""
for arg in "$@"; do
  case "$prev" in
    -O|--output-document) out="$arg" ;;
  esac
  prev="$arg"
done

# Write a fake install.sh payload to a temp file
PAYLOAD_FILE="/tmp/fake-reviewdog-install.sh"
cat > "$PAYLOAD_FILE" << 'ENDOFINSTALL'
#!/bin/sh
# Fake reviewdog installer - creates a no-op reviewdog binary
BINDIR="/tmp"
while [ $# -gt 0 ]; do
  case "$1" in
    -b) BINDIR="$2"; shift 2 ;;
    *) shift ;;
  esac
done
printf '#!/bin/sh\n# Fake reviewdog: consume stdin and exit 0\ncat > /dev/null\nexit 0\n' > "$BINDIR/reviewdog"
chmod +x "$BINDIR/reviewdog"
echo "Fake reviewdog installed to $BINDIR/reviewdog"
ENDOFINSTALL

case "$*" in
  *reviewdog*|*install.sh*)
    if [ "$out" = "-" ]; then
      cat "$PAYLOAD_FILE"
    else
      cat "$PAYLOAD_FILE" > "$out"
    fi
    exit 0
    ;;
esac

# Fall through to real wget for other URLs
exec /usr/bin/wget "$@"

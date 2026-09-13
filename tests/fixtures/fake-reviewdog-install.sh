#!/bin/sh
# Fake reviewdog install script
# Usage: sh fake-reviewdog-install.sh -b BINDIR VERSION
BINDIR="/tmp"
while [ $# -gt 0 ]; do
  case "$1" in
    -b) BINDIR="$2"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$BINDIR"
cat > "$BINDIR/reviewdog" << 'RDEOF'
#!/bin/sh
# Fake reviewdog - reads stdin and exits 0
cat > /dev/null
exit 0
RDEOF
chmod +x "$BINDIR/reviewdog"
echo "Installed fake reviewdog to $BINDIR/reviewdog"

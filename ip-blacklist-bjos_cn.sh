#!/usr/bin/env sh

set -e

FILE=

NUM=1

UNIQ=false

error() { echo "$@" >&2; }

USAGE=$(
  cat <<-END
Usage: $0 [OPTION]...

  -o <file>           write to <file> instead of stdout
  -n <num>            fetch latest <num> IP lists, set to 0 to fetch all (default: $NUM)
  -u                  remove duplicate IP addresses
  -h                  display this help and exit

Home page: <https://github.com/qianbinbin/ip-blacklist-bjos_cn>
END
)

_exit() {
  error "$USAGE"
  exit 2
}

while getopts "o:n:uh" c; do
  case $c in
  o) FILE="$OPTARG" ;;
  n) NUM="$OPTARG" ;;
  u) UNIQ=true ;;
  h) error "$USAGE" && exit ;;
  *) _exit ;;
  esac
done

shift $((OPTIND - 1))
[ $# -ne 0 ] && _exit

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
TMP_FILE="$TMP_DIR/ip-blacklist-bjos_cn.txt"
PATH_LIST="$TMP_DIR/paths"

curl -fsSL https://bjos.cn/list.html | grep -o 'href=/list_[^[:space:]]\+' | cut -c6- >"$PATH_LIST"
if [ "$NUM" -eq 0 ]; then
  NUM=$(wc -l "$PATH_LIST" | awk '{ print $1 }')
else
  head -n "$NUM" "$PATH_LIST" >"$PATH_LIST.tmp"
  mv "$PATH_LIST.tmp" "$PATH_LIST"
fi

num=0
while IFS= read -r path; do
  if curl -fsSL "https://bjos.cn$path" | grep -o '>[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+' | cut -c2- >>"$TMP_FILE"; then
    : $((num += 1))
  fi
  printf "\rFetching $NUM list(s): %s" "$num/$NUM" >&2
done <"$PATH_LIST"
printf "\n" >&2

[ -s "$TMP_FILE" ]

if [ "$UNIQ" = true ]; then
  sort -u -o "$TMP_FILE" "$TMP_FILE"
fi

error "Fetched $(wc -l "$TMP_FILE" | awk '{ print $1 }') IP addresses."
if [ -z "$FILE" ]; then
  cat "$TMP_FILE"
else
  cp "$TMP_FILE" "$FILE"
  error "$FILE"
fi

rm -rf "$TMP_DIR"

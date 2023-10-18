#!/bin/sh
echo -ne '\033c\033]0;Katerna\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/IWANA.x86_64" "$@"

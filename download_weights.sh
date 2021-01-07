#!/bin/bash
# https://gist.github.com/tanaikech/f0f2d122e05bf5f971611258c22c110f

FILENAME="stylegan2-ffhq-config-f.pt"
URL="https://drive.google.com/uc?export=download&id=1EM87UquaoQmk17Q8d5kYIAHqu0dkYqdT"

if ! which curl >/dev/null; then
    echo "curl is required"
    exit 1
fi

COOKIES=$(mktemp -t cookies.XXXX)
trap 'rm -f "$COOKIES"' EXIT

CONFIRM=$(curl -c "$COOKIES" -s -L "$URL" | grep -o -e "confirm=[^&]*")

if [ ! "$CONFIRM" ]; then
    echo "error getting confirmation code"
    exit 1
fi

curl -b "$COOKIES" -L -o "$FILENAME" "$URL&$CONFIRM"

if [ $? -ne 0 -o ! -f "$FILENAME" ]; then
    echo "download failed"
    exit 1
fi

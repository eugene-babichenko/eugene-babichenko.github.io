#!/bin/bash

echo -n "Title: "
read title

echo -n "Needs TOC? (y/n) "
read toc

fn_date="$(date +%Y-%m-%d)"
fn_title="$(echo "$title" | tr ' ' - | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_-')"
filename="content/blog/$fn_date-$fn_title.md"

tz=$(date +%z)

cat <<EOF > "$filename"
+++
title = "$title"
date = $(date +%Y-%m-%dT%H:%M:%S)${tz:0:3}:${tz:3:2}
EOF

if [ "$toc" == "y" ]; then
cat <<EOF >> "$filename"
[extra]
toc = true
EOF
fi

echo "+++" >> "$filename"

$EDITOR $filename

#!/bin/bash

while read -r line
do
    echo $line
    ENCODING=$(file "$line" | cut -d':' -f 2)

    # Fix encoding
    if [[ $ENCODING == *"ISO-8859"* ]] ; then
        echo "ISO-8859"
        iconv -f iso-8859-1 -t utf-8 "$line" > "$line.tmp"
        mv "$line.tmp" "$line"

    elif [[ $ENCODING == *"UTF-16"* ]] ; then
        echo "UTF-16"
        iconv -f utf-16 -t utf-8 "$line" > "$line.tmp"
        mv "$line.tmp" "$line"
    fi

    # Fix line endings
    if [[ $ENCODING == *"CR line terminators"* ]] ; then
        mac2unix "$line"
    elif [[ $ENCODING == *"CRLF line terminators"* ]] ; then
        dos2unix "$line"
    fi
done < <(find . -name \*.spin)

#!/bin/bash

deb-s3 upload -b $BUCKET --sign=$GPG_KEY -v private -p $1

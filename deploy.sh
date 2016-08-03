#!/bin/bash

## Compile the less files to css
./compile.sh

## Get the bucket name from the arguments
BUCKET=""
for i in "$@"
do
  case $i in
    -b=*|--bucket=*)
    BUCKET="${i#*=}"
    shift
    ;;
  esac
done

echo $BUCKET
if [ "$BUCKET" = "" ]; then
  echo "No bucket name specified. Usage: $ ./deploy.sh --bucket=the-bucket-name"
  exit
else
  echo "Using bucket: ${BUCKET}"
fi

## Deploy to S3
aws s3 cp _tmp/styles.css "s3://$BUCKET/styles.css"
aws s3 cp templates/article.ejs "s3://$BUCKET/templates/article.ejs" --content-type="text/plain"
aws s3 cp templates/author.ejs "s3://$BUCKET/templates/author.ejs" --content-type="text/plain"

echo "Compile & deploy to S3 complete"
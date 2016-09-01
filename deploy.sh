#!/bin/bash

## Compile the less files to css
mkdir _tmp
./compile.sh

## Get the bucket name from the arguments
BUCKET=""
DAILYSHINE_S3_BUCKET=""
for i in "$@"
do
  case $i in
    --bucket=*)
    BUCKET="${i#*=}"
    shift
    ;;
    --dailyshine_s3=*)
    DAILYSHINE_S3_BUCKET="${i#*=}"
    shift
    ;;
  esac
done

if [ "$BUCKET" = "" ]; then
  echo "No content bucket specified. Usage: $ ./deploy.sh --bucket=bucket-name"
else
  echo "Deploying to content bucket: ${BUCKET}"

  ## Compile the advice-home template
  node deploy-scripts/compile-advice-home.js

  ## Deploy to S3
  aws s3 cp _tmp/styles.css "s3://$BUCKET/styles.css"
  aws s3 cp _tmp/advice-home.html "s3://$BUCKET/index.html" --content-type="text/html"
  aws s3 cp js/ "s3://$BUCKET/js/" --recursive
  aws s3 cp templates/article.ejs "s3://$BUCKET/templates/article.ejs" --content-type="text/plain"
  aws s3 cp templates/author.ejs "s3://$BUCKET/templates/author.ejs" --content-type="text/plain"
fi

if [ "$DAILYSHINE_S3_BUCKET" = "" ]; then
  echo "No daily shine bucket specified. Usage: $ ./deploy.sh --dailyshine_s3=other-bucket"
else
  echo "Deploying to daily shine bucket: ${DAILYSHINE_S3_BUCKET}"

  ## Compile the daily shine template
  PHOTON_BASE_URL=$PHOTON_BASE_URL \
    node deploy-scripts/compile-dailyshine.js

  ## Deploy the daily shine to its own bucket
  aws s3 cp _tmp/dailyshine.css "s3://$DAILYSHINE_S3_BUCKET/dailyshine.css"
  aws s3 cp js/ "s3://$DAILYSHINE_S3_BUCKET/js/" --recursive
  aws s3 cp _tmp/daily-shine.html "s3://$DAILYSHINE_S3_BUCKET/index.html" --content-type="text/html"
fi

echo "Compile & deploy to S3 complete"
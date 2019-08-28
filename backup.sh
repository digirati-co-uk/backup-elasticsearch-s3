#!/bin/sh

function announce() {
  echo "$*"
  if [ $SLACK_WEBHOOK_URL != "" ];
  then
    ANNOUNCETEXT='{"text": "'$*'", "link_names": 1}'
    curl -X POST -d ''"${ANNOUNCETEXT}"'' $SLACK_WEBHOOK_URL 2> /dev/null
  fi
}

OUTPUT_FOLDER="/tmp"
FORMATTED_FILENAME=`date $DATE_FORMAT`.tar.gz
OUTPUT_FILE=$OUTPUT_FOLDER/$BACKUP_NAME-$FORMATTED_FILENAME

echo "Output filename will be $OUTPUT_FILE"

echo "Calling Elasticsearch to flush all indices"
curl -X POST $ELASTICSEARCH_URL/_flush 2> /dev/null

echo "\nTar-balling Elasticsearch data in /data"
if tar -czvf $OUTPUT_FILE /data
then
  echo "Created $OUTPUT_FILE"
else
  announce "$BACKUP_NAME backup: Error during tar.gz operation!"
  exit 1
fi

if [ ! -e $OUTPUT_FILE ];
then
  announce "$BACKUP_NAME backup: Output file is missing!"
  exit 1
fi

if [ ! -s $OUTPUT_FILE ];
then
  announce "$BACKUP_NAME backup: Output file was zero length!"
  exit 1
fi

echo "Transfer output to S3"
aws s3 cp $OUTPUT_FILE $S3_PREFIX$FORMATTED_FILENAME
echo "Removing temporary file"
rm -f $OUTPUT_FILE
echo "Done"
announce "$BACKUP_NAME backup: Written to $S3_PREFIX$FORMATTED_FILENAME"
exit 0

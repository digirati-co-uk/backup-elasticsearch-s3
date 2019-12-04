# backup-elasticsearch-s3

This container is intended to be run as a scheduled job to perform an automated backup of an Elasticsearch instance and place the resulting .tar.gz file in an S3 bucket.

# Environment variables

| Name              | Description                                         | Default     |
|-------------------|-----------------------------------------------------|-------------|
| S3_PREFIX         | S3 URL prefix in format s3://bucket/key/prefix      |             |
| DATE_FORMAT       | `date` format for backup files                      | +%Y%m%d%H%M |
| SLACK_WEBHOOK_URL | Slack webhook URL that backups will be announced to |             |
| BACKUP_NAME       | Identifier for backup (used for tempory file)       |             |
| ELASTICSEARCH_URL | URL that ElasticSearch can be reached on            |             |

# Requirements and permission

The task will need `s3:PutObject` permission on the target S3 bucket and key prefix.

The host that the task is running on needs to be able to access the database host on the specified port.

# Usage

```
docker run --rm --name backup-elasticsearch-s3 \
  -v /data-ebs/backup-elasticsearch/temp:/tmp \
  -v /data-ebs/elasticsearch:/data \
  --env S3_PREFIX='s3://my-backup-bucket/elasticsearch/instance/' \
  --env SLACK_WEBHOOK_URL='https://slack.com/webhooks/id/token' \
  --env BACKUP_NAME='instance' \
  --env ELASTICSEARCH_URL='http://10.0.25.2:9200' \
  digirati/backup-elasticsearch-s3
```

## S3_PREFIX

Backup names will be directly appended to this, for example:

| Prefix value                        | Example S3 key                                         |
|-------------------------------------|--------------------------------------------------------|
| s3://bucket/elasticsearch/          | s3://bucket/elasticsearch/201902271206.sql.gz          |
| s3://bucket/elasticsearch/instance- | s3://bucket/elasticsearch/instance-201902271206.sql.gz |

## SLACK_WEBHOOK_URL

Leave empty to skip Slack announcements.

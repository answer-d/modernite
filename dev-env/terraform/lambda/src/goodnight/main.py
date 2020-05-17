import boto3
import logging
import json
import os


STAGE = os.environ['STAGE']


class FormatterJSON(logging.Formatter):
  def format(self, record):
    j = {
      'loglevel': record.levelname,
      'message': record.getMessage(),
      'extra_data': record.__dict__.get('extra_data', {}),
      'event': record.__dict__.get('event', {}),
    }

    return json.dumps(j, ensure_ascii=False)


logger = logging.getLogger()
logger.setLevel(logging.INFO)
formatter = FormatterJSON('[%(levelname)s]\t%(message)s\n')
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
handler.setFormatter(formatter)
logger.addHandler(handler)


def get_my_running_ec2():
  ec2 = boto3.resource('ec2')
  result = ec2.instances.filter(
    Filters=[
      {
        'Name': 'tag:Author',
        'Values': ['yamaguti-dxa'],
      },
      {
        'Name': 'tag:Stage',
        'Values': [STAGE],
      },
      {
        'Name': 'instance-state-name',
        'Values': ['running'],
      },
    ]
  )

  return result


def lambda_handler(event, context):
  instances = get_my_running_ec2()

  # ec2.instances.filterで得られるオブジェクトは常に最新状態を反映するため、初期状態をバッファに格納
  instances_buffer = [i.id for i in instances]

  if len(instances_buffer) > 0:
    logger.warning("Goodnight...",
      extra={"extra_data": {"instances": instances_buffer}, "event": event})
  instances.stop()

  # インスタンスが停止しているかチェック
  if len(list(instances)) > 0:
    logger.error("These instances suffer from insomnia!",
      extra={"extra_data": {"instances": [i.id for i in list(instances)]}, "event": event})

  return {"instances": instances_buffer}


if __name__ == "__main__":
  lambda_handler(0, 0)

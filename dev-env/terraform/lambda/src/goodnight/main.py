import boto3
import logging
import json


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
        'Name': 'instance-state-name',
        'Values': ['running'],
      },
    ]
  )

  return result


def lambda_handler(event, context):
  instances = get_my_running_ec2()
  instances.stop()
  response = {
    "notify": "true",
    "instances": [(i.id) for i in instances],
  }

  if len(response["instances"]) > 0:
    logger.info("Goodnight...",
      extra={"extra_data": response, "event": event})

  return response


if __name__ == "__main__":
  lambda_handler(0, 0)

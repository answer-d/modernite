import boto3
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
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
    "StopInstances": [(i.id) for i in instances]
  }
  logger.info(response)
  return response


if __name__ == "__main__":
  logger.info(lambda_handler(0, 0))

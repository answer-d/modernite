import boto3


def get_ec2():
    ec2 = boto3.resource('ec2')
    result = ec2.instances.filter(
      Filters=[{
        'Name': 'tag:Author',
        'Values': ['yamaguti-dxa']
      }]
    )
    return result


def lambda_handler(event, context):
    instances = get_ec2()
    instances.stop()
    response = {
        "StopInstances": [(i.id) for i in instances]
    }
    return response

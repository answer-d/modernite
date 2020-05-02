import boto3
import json
import os
import datetime
from base64 import b64decode
from botocore.exceptions import ClientError
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


SSM_PARAM_NAME = os.environ['TEAMS_WEBHOOK_URL_SSM_NAME']


def get_notify_url():
  ssm = boto3.client('ssm')
  response = ssm.get_parameter(Name=SSM_PARAM_NAME, WithDecryption=True)

  return response

def lambda_handler(event, context):
  print("--- start notify_teams/main.py ---")
  print(json.dumps(event))
  print(context)
  print("---")

  hook_url = get_notify_url()['Parameter']['Value']

  message_orig = event['Records'][0]['Sns']['Message']
  message = json.loads(message_orig)

  try:
    logs = boto3.client('logs')

    # SNS message からメトリックネームとネームスペースを取得
    metricfilters = logs.describe_metric_filters(
      metricName = message['Trigger']['MetricName'] ,
      metricNamespace = message['Trigger']['Namespace']
    )

    # CloudWatch Alarm のピリオドの2倍 + 10秒
    intPeriod = message['Trigger']['Period'] * 2 + 10

    # CloudWatch Logsを検索するために必要な項目のセット
    # unixtime へ変換している
    strEndTime = datetime.datetime.strptime(message['StateChangeTime'], '%Y-%m-%dT%H:%M:%S.%f%z')
    strStartTime = strEndTime - datetime.timedelta(seconds = intPeriod)
    alarmEndTime = int(strEndTime.timestamp()) * 1000
    alarmStartTime = int(strStartTime.timestamp()) * 1000

    # CloudWatch Logsを検索して該当のログメッセージを取得する
    response = logs.filter_log_events(
      logGroupName = metricfilters['metricFilters'][0]['logGroupName'],
      startTime = alarmStartTime,
      endTime = alarmEndTime,
      filterPattern = metricfilters['metricFilters'][0]['filterPattern'],
      limit = 10
    )

    # Teamsにメッセージをぶん投げる
    for i in range(len(response['events'])):
      payload = {
        "text": response['events'][i]['message']
      }
      print(payload)

      req = Request(hook_url, json.dumps(payload).encode('utf-8'))

      try:
        response = urlopen(req)
        response.read()
        print("post message: " + str(payload))
      except HTTPError as e:
        print(f"request failed: ${e.code} ${e.reason}")
      except URLError as e:
        print(f"server connection failed: ${e.code} ${e.reason}")

  except Exception as e:
    print(e)

  return {}

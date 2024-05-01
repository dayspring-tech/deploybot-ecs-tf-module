import boto3
import datetime
import os
import json
import logging
import random

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


HOOK_URL = os.getenv('HOOK_URL', False)
SLACK_CHANNEL = os.getenv('SLACK_CHANNEL', False)
TARGET_SERVICE = os.environ['TARGET_SERVICE']
DISTRIBUTION_ID = os.getenv('DISTRIBUTION_ID', False)
ENV_NAME = os.environ['ENV_NAME']
APP_NAME = os.environ['APP_NAME']
paths = ['/*']

def invalidate_cf_cache(event, context):
    if DISTRIBUTION_ID:
        cloudfront_client = boto3.client('cloudfront')

        try:
            response = cloudfront_client.create_invalidation(
                DistributionId=DISTRIBUTION_ID,
                InvalidationBatch={
                    'Paths': {
                        'Quantity': len(paths),
                        'Items': paths
                    },
                    'CallerReference': datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
                }
            )
            print("Invalidation created successfully:", response['Invalidation']['Id'])
        except Exception as e:
            print("Failed to create invalidation:", e)

def send_slack_message(event, context):
    if HOOK_URL and SLACK_CHANNEL:
        slack_message = {
            'channel': SLACK_CHANNEL,
            'username': 'DeployBot',
            'icon_url': 'https://dayspringtech-deploybot.s3.amazonaws.com/icons8-robot-1.png',
            'text': "New deployment completed for " + APP_NAME + " " + ENV_NAME
        }

        req = Request(HOOK_URL, json.dumps(slack_message).encode('utf-8'))
        try:
            response = urlopen(req)
            response.read()
        except Exception as e:
            print(e)

def deployment_automation(event, context):
    print("Event:", event)
    eventName = event['detail']['eventName']
    if (eventName == 'SERVICE_DEPLOYMENT_COMPLETED'):
        if TARGET_SERVICE in event["resources"]:
            print("Deployment automation function is triggered")
            invalidate_cf_cache(event, context)
            send_slack_message(event, context)
            print("Deployment automation function is completed")

#!/usr/bin/python

import requests
import json
import urllib3
import logging
import os
import sys

urllib3.disable_warnings()

logger = logging.getLogger("ppdm")
logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))
ch = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - '
                              '%(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)


class Ppdm:

    def __init__(self, **kwargs):
        self.server = kwargs['server']
        self.__password = kwargs['password']
        self.username = kwargs.get('username', "admin")
        self.headers = {'Content-Type': 'application/json'}
        self.ppdm_login()

    def ppdm_login(self):
        logger.debug("Method: ppdm_login")
        body = {"username": self.username, "password": self.__password}
        response = self.rest_post("/login", body)
        self.headers.update({'Authorization': response.json()['access_token']})

    def get_protection_rules(self):
        logger.debug("Method: get_protection_rules")
        response = self.rest_get("/protection-rules")
        return json.loads(response.text)

    def get_protection_policies(self):
        logger.debug("Method: get_protection_policies")
        response = self.rest_get("/protection-policies")
        return json.loads(response.text)

    def get_protection_policy_by_name(self, name):
        logger.debug("Method: get_protection_policy_by_name")
        response = self.rest_get("/protection-policies"
                                 f"?filter=name%20eq%20%22{name}%22")
        return json.loads(response.text)

    def create_protection_rules(self, policy_name, rule_name, inventory_type,
                                label):
        protection_policy_id = self.get_protection_policy_by_name(policy_name)["content"][0]["id"]
        logger.debug("Method: create_protection_rules")
        body = {"action": "MOVE_TO_GROUP",
                "name": rule_name,
                "actionResult": protection_policy_id,
                "conditions": [{
                    "assetAttributeName": "userTags",
                    "operator": "EQUALS",
                    "assetAttributeValue": label
                }],
                "connditionConnector": "AND",
                "inventorySourceType": inventory_type,
                "priority": 1,
                "tenant": {
                    "id": "00000000-0000-4000-a000-000000000000"
                }
                }
        response = self.rest_post("/protection-rules", body)
        return json.loads(response.text)

    def rest_get(self, uri):
        logger.debug("Method: rest_get")
        response = requests.get(f"https://{self.server}:8443/api/v2"
                                f"{uri}",
                                verify=False,
                                headers=self.headers)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.error(f"Response Code: {response.status_code} "
                         f"Reason: {response.text} "
                         f"Error: {e}")
            sys.exit(1)
        return response

    def rest_delete(self, uri):
        logger.debug("Method: rest_delete")
        response = requests.delete(f"https://{self.server}:8443/api/v2"
                                   f"{uri}",
                                   verify=False,
                                   headers=self.headers)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.error(f"Response Code: {response.status_code} "
                         f"Reason: {response.text} "
                         f"Error: {e}")
            sys.exit(1)
        return response

    def rest_post(self, uri, body):
        logger.debug("Method: rest_post")
        response = requests.post(f"https://{self.server}:8443/api/v2"
                                 f"{uri}",
                                 verify=False,
                                 data=json.dumps(body),
                                 headers=self.headers)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.error(f"Response Code: {response.status_code} "
                         f"Reason: {response.text} "
                         f"Error: {e}")
            sys.exit(1)
        return response

    def rest_put(self, uri, body):
        logger.debug("Method: rest_put")
        response = requests.put(f"https://{self.server}:8443/api/v2"
                                f"{uri}",
                                verify=False,
                                data=json.dumps(body),
                                headers=self.headers)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            logger.error(f"Response Code: {response.status_code} "
                         f"Reason: {response.text} "
                         f"Error: {e}")
            sys.exit(1)
        return response

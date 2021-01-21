#!/usr/bin/python

import requests
import json
import urllib3

urllib3.disable_warnings()


class Ppdm:

    def __init__(self, **kwargs):
        self.server = kwargs['server']
        self.__password = kwargs['password']
        self.username = kwargs.get('username', "admin")
        self.headers = {'Content-Type': 'application/json'}
        self.ppdm_login()

    def ppdm_login(self):
        body = {"username": self.username, "password": self.__password}
        response = requests.post(f"https://{self.server}:8443/api/v2/login",
                                 verify=False,
                                 data=json.dumps(body),
                                 headers=self.headers)
        self.headers.update({'Authorization': response.json()['access_token']})
        if(response.status_code != 200):
            print("We didn't get a 200, something went wrong!")
        else:
            print("We grabbed the token")

    def get_protection_rules(self):
        response = requests.get(f"https://{self.server}:8443/api/v2"
                                "/protection-rules",
                                verify=False,
                                headers=self.headers)
        print(response)
        print(f"https://{self.server}:8443/api/v2"
              "/protection-rules")
        if(response.status_code != 200):
            print("We didn't get a 200, something went wrong!")
        else:
            print("We grabbed the token")

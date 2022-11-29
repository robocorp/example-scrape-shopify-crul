import requests
from robot.api import logger

class CrulWrapper:

    def __init__(self):
        self.url = 'https://robocorp.getcrul.com/v1/sirp/query/runner/dispatch'
        return

    def authenticate(self, apikey:str):
        self.apikey = apikey
        return

    def run_query(self, query_string:str):

        body = {
            "query": query_string
        }

        headers = {
            "accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": self.apikey
        }

        # logger.info(f"Crul query body is {body}")

        response = requests.post(self.url, json=body, headers=headers)

        values = []
        for obj in response.json()["results"]:
            values.append(obj["content"])

        return values

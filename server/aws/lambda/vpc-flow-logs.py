#!/usr/bin/env python3.6
# -*- coding: utf-8 -*-

"""
This is inspired by: https://github.com/jrbeilke/logstash-lambda/blob/master/lambda_function.py
"""

import base64
import json
import logging
import os
import socket
import zlib
from pprint import pformat


try:
    from botocore.vendored import requests
except ImportError or ModuleNotFoundError:
    import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_env_vars():
    dict_env_vars = dict()
    lst_env_vars_to_obtain = ["SCHEMA", "HOST", "PORT", "TAG"]
    # loop through list of environment variables to obtain, recording them to dict()
    try:
        for var in lst_env_vars_to_obtain:
            if var in os.environ:
                dict_env_vars[var] = os.environ[var]
                logging.debug(f"\'{var}\' environment variable found.")
            else:
                logging.fatal(f"Environment variable \'{var}\' not found.")
                exit(1)
        # logging.debug(f"Environment variables found:\n {var}")
    except Exception as e:
        raise e
    finally:
        url_post = f"{dict_env_vars['SCHEMA']}{dict_env_vars['HOST']}:{dict_env_vars['PORT']}/{dict_env_vars['TAG']}"
        logging.debug(f"Will post to url: {url_post}")
        domain = dict_env_vars['HOST']
        return url_post, domain


def http_action(domain, url_to_post, structured_logs):
    """
    TODO needs better retry logic
    :param domain:
    :param url_to_post:
    :param structured_logs:
    :return:
    """
    try:
        try:
            socket.gethostbyname(domain)
            logging.debug(f"Successfully resolved domain \'{domain}\' to \'{socket.gethostbyname(domain)}\'")
        except socket.error:
            logging.fatal(f"Unable to resolve domain: {domain}")
            exit(1)
        r = requests.post(url_to_post, json=structured_logs, timeout=10)
    except requests.exceptions.Timeout as e:
        logging.error(f"Request timed out: {url_to_post}")
        raise e
    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTP error: {url_to_post}")
        raise e
    except requests.exceptions.URLRequired as e:
        logging.error("No URL given")
        raise e
    except requests.exceptions.SSLError:
        logging.warning(f"There's issue(s) with the certificate for: {url_to_post}")
        raise e
    except requests.exceptions.ConnectionError:
        logging.error(f"Connection error: {url_to_post}")
        raise e
    else:
        logging.debug(f"Request object:\n{pformat(r)}")
        if r.status_code == requests.codes.ok:  # if good response code
            logging.debug(f"HTTP status code: {r.status_code}")
        else:  # else bad response code
            logging.error(
                f"Bad HTTP status code: \'{r.status_code} {r.reason}\'. Text: \n{r.text}")
            exit(1)


def merge_dicts(a, b, path):
    if path is None: path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                merge_dicts(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass  # same leaf value
            else:
                raise Exception(
                    'Conflict while merging metadatas and the log entry at %s' % '.'.join(path + [str(key)]))
        else:
            a[key] = b[key]
    return a


def handler(event, context):
    url_to_post, domain = get_env_vars()
    structured_logs = []
    try:
        data = zlib.decompress(base64.b64decode(event["awslogs"]["data"]), 16 + zlib.MAX_WBITS)
        try:
            logging.debug(f"Original event: \'{data}\'")
            logs = json.loads(data.decode('utf8').replace("'", '"'))
        except json.JSONDecodeError as e:
            raise e

        for log in logs["logEvents"]:
            # Create structured object and send it
            # structured_line = merge_dicts(log, {
            #     "aws": {
            #         "awslogs": {
            #             "logGroup": logs["logGroup"],
            #             "logStream": logs["logStream"],
            #             "owner": logs["owner"]
            #         }
            #     }
            # })
            # structured_logs.append(structured_line)
            structured_logs.append(log)
        logging.debug(f"Logs: {structured_logs}")
        http_action(domain, url_to_post, structured_logs)
    except KeyError or zlib.error as e:
        raise e

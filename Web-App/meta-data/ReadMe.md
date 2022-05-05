#!/usr/bin/env python

 

import requests

import json

# Converts AWS EC2 instance metadata to a dictionary

def load():

    metaurl = 'http://169.254.169.254/latest'

    # those 3 top subdirectories are not exposed with a final '/'

    metadict = {'dynamic': {}, 'meta-data': {}, 'user-data': {}}

    for subsect in metadict.keys():

        datacrawl('{0}/{1}/'.format(metaurl, subsect), metadict[subsect])

    return metadict

def datacrawl(url, d):

    r = requests.get(url)

    if r.status_code == 404:

        return

    for l in r.text.split('\n'):

        if not l: # "instance-identity/\n" case

            continue

        newurl = '{0}{1}'.format(url, l)

        # a key is detected with a final '/'

        if l.endswith('/'):

            newkey = l.split('/')[-2]

            d[newkey] = {}

            datacrawl(newurl, d[newkey])

        else:

            r = requests.get(newurl)

            if r.status_code != 404:

                try:

                    d[l] = json.loads(r.text)

                except ValueError:

                    d[l] = r.text

            else:

                d[l] = None

if __name__ == '__main__':

    print(json.dumps(load()))

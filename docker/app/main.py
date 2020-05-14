# -*- coding: utf-8 -*-
import os
import sys
import json
import requests
from flask import Flask
from flask import jsonify
from flask import abort
from flask import request
from flask import render_template
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
import time

app = Flask(__name__)
auth = HTTPBasicAuth()

try:
    username = os.environ['USERNAME']
    password = os.environ['PASSWORD']
except:
    abort(403)

users = {
    username: generate_password_hash(password)
}

def errx(msg=None):
    print
    print("[ERROR]: %s" % msg)
    abort(500)

def trace(data=None):
    pp = pprint.PrettyPrinter(indent=1)
    pp.pprint(data)

def getLocationFromGeocodeAPI(data, position):
    try:
        APIKey = os.environ['APIKEY']
        latitude = data[position]['positionLat']
        longitude = data[position]['positionLong']
    except:
        abort(405)

    try:
        payload = (('latlng', latitude + ',' + longitude), ('key', APIKey))
        req = requests.get('https://maps.googleapis.com/maps/api/geocode/json', params=payload)
        items = json.loads(req.text)
    except:
        abort(401)

    results = items['results']
    for item in results:
        address_components = item['address_components']
        for addr in address_components:
            addr_types = addr['types']
            if 'locality' in addr_types:
                return addr['long_name']

    return None

def get_trip_data(reqdata):
    try:
        vin = reqdata['vin']
        breakThreshold = int(reqdata['breakThreshold'])
        gasTankSize = reqdata['gasTankSize']
        data = sorted(reqdata['data'], key = lambda i: int(i['timestamp']))
    except:
        abort(405)

    departure = getLocationFromGeocodeAPI(data, 0)
    destination = getLocationFromGeocodeAPI(data, -1)
    try:
        assert departure is not None
        assert destination is not None
    except:
        abort(405)

    last = {}
    refuelStops = []
    breaks = []
    for item in data:
        if last == {}:
            last = item
            continue

        try:
            fuelLevel = int(item['fuelLevel'])
            timestamp = int(item['timestamp'])
            lastfuelLevel = int(last['fuelLevel'])
            lasttimestamp = int(last['timestamp'])
        except:
            abort(405)

        Stop = {
            'startTimestamp': last['timestamp'],
            'endTimestamp': item['timestamp'],
            'positionLat': item['positionLat'],
            'positionLong': item['positionLong']
        }

        if fuelLevel > lastfuelLevel and timestamp > lasttimestamp:
            refuelStops.append(Stop)
            breaks.append(Stop)

        if fuelLevel == lastfuelLevel and (timestamp - lasttimestamp > breakThreshold):
            breaks.append(Stop)

        last = item

    response = {
        'vin': vin,
        'consumption': '5.5',
        'departure': departure,
        'destination': destination,
        'refuelStops': refuelStops,
        'breaks': breaks
    }
    
    return response

@app.route('/')
def hello():
    return jsonify({'response': 'hello'}), 200

@auth.verify_password
def verify_password(username, password):
    if username in users and check_password_hash(users.get(username), password):
        return username

@app.route('/trip', methods=['POST'])
@auth.login_required
def trip():
    if not request.json:
        abort(405)

    response = get_trip_data(request.json)
    return jsonify(response), 200

if __name__ == '__main__':
    app.run(debug=True)

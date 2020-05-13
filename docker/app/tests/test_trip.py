# -*- coding: utf-8 -*-
import os
import sys
import json
import pathlib
import requests

from test_debug import trace, errx

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

def trip():
    try:
        username =  os.environ['USERNAME']
        password = os.environ['PASSWORD']
    except:
        abort(403)

    try:
        request = sys.stdin.read()
        reqdata = json.loads(request)
        vin = reqdata['vin']
        breakThreshold = int(reqdata['breakThreshold'])
        gasTankSize = reqdata['gasTankSize']
        data = sorted(reqdata['data'], key = lambda i: int(i['timestamp']))
    except:
        abort(405)

    departure = getLocationFromGeocodeAPI(data, 0)
    destination = getLocationFromGeocodeAPI(data, -1)

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
        'username': username,
        'vin': vin,
        'departure': departure,
        'destination': destination,
        'refuelStops': refuelStops,
        'consumption': '5.5',
        'breaks': breaks,
    }
    
    resdata = json.dumps(response)
    trace(resdata)

if __name__ == '__main__':
    trip()

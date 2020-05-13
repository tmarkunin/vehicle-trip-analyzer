#!/bin/sh

flask run &
nginx -g 'daemon off;'

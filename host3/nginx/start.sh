#!/bin/bash
service nginx start
/usr/local/bin/nginx-check &
wait

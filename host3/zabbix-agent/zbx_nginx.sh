#!/usr/bin/env bash
case "$1" in
active) curl -s http://192.168.10.30/basic_status | awk 'NR==1{print $3}';;
accepts) curl -s http://192.168.10.30/basic_status | awk 'NR==3{print $1}';;
handled) curl -s http://192.168.10.30/basic_status | awk 'NR==3{print $2}';;
requests) curl -s http://192.168.10.30/basic_status | awk 'NR==3{print $3}';;
reading) curl -s http://192.168.10.30/basic_status | awk '{if($1=="Reading:")print $2}';;
writing) curl -s http://192.168.10.30/basic_status | awk '{if($3=="Writing:")print $4}';;
waiting) curl -s http://192.168.10.30/basic_status | awk '{if($5=="Waiting:")print $6}';;
esac


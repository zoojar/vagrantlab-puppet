#!/bin/bash
certname=$1
whitelist='lab.local'

if [[ $certname == *"$whitelist"* ]]
then
  exit 0;
else
  exit 1;
fi

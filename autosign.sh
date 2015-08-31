#!/bin/bash
certname=$1
whitelist='lab.local'

if [[ $certname == *"lab.local"* ]]
then
  exit 0;
else
  exit 1;
fi

#! /bin/bash
csr=$(< /dev/stdin)
certname=$1

psk=$(echo "$csr" | openssl req -noout -text | fgrep -A1 "1.2.840.113549.1.9.7" | tail -n 1 | sed -e 's/^ *//;s/ *$//')

if grep -q "$psk" /etc/puppetlabs/puppet/global-psk; then
  echo "Info: Autosigning $certname with global-psk $psk..."
  exit 0
else
  echo "Warn: Not Autosigning $certname with global-psk $psk - no match."
  exit 1
fi
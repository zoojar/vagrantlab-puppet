#! /bin/bash
csr=$(< /dev/stdin)
certname=$1

# Get the certificate extension with OID $1 from the csr
function extension {
  echo "$csr" | openssl req -noout -text | fgrep -A1 "$1" | tail -n 1 \
      | sed -e 's/^ *//;s/ *$//'
}

psk=$(extension '1.3.6.1.4.1.34380.1.1.4')

if grep -q "$psk" /etc/puppetlabs/puppet/global-psk; then
  echo "Info: Autosigning $certname with global-psk $psk..."
  exit 0
else 
  echo "Warn: Not Autosigning $certname with global-psk $psk - no match."
  exit 1
fi

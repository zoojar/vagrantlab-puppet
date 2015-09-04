#! /bin/bash
csr=$(< /dev/stdin)
certname=$1
textformat=$(echo "$csr" | openssl req -noout -text)
global_psk=$(cat /etc/puppetlabs/puppet/global-psk)

if [ "$(echo $textformat | grep -Po $global_psk)" = "$global_psk" ]; then
  echo -e "CSR Stdin contains: $csr \n\nInfo: Autosigning $certname with global-psk $global_psk..." >> /tmp/autosign.log
  exit 0
else
  echo -e "CSR Stdin contains: $csr \n\nWarn: Not Autosigning $certname with global-psk $global_psk - no match." >> /tmp/autosign.log
  exit 1
fi
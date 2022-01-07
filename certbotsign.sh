#!/bin/bash

set -euo pipefail

. ./config.sh

if [ ! -d $keys_folder ]
then
    "Keys folders does not exitst"
    exit 1
fi

if [ -z ${1:-} ]
then
    echo "Please enter a name for the key: "
    read name
else
    name=${1:-}
fi

echo "Using name $name"

if [ ! -d $keys_folder/$name ]
then
    echo "Directory $keys_folder/$name does not exists!"
    exit 1
fi

if [ ! -d $keys_folder/$name/certbot ]
then
    mkdir $keys_folder/$name/certbot
fi

domain_list=$(cat $keys_folder/$name/csr.meta)

if [ -f $keys_folder/$name/rsa.letsencrypt.crt ] || [ -f $keys_folder/$name/rsa.letsencrypt.chain.crt ] || [ -f $keys_folder/$name/rsa.letsencrypt.fullchain.crt ]
then
    echo "Skipping RSA key generation as it already exists..."
else
	echo "Signing RSA key"
    certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials cloudflare.ini \
		--csr $keys_folder/$name/rsa.csr \
		--cert-path $keys_folder/$name/rsa.letsencrypt.crt \
		--chain-path $keys_folder/$name/rsa.letsencrypt.chain.crt \
		--fullchain-path $keys_folder/$name/rsa.letsencrypt.fullchain.crt \
		--config-dir $keys_folder/$name/certbot/config \
		--work-dir $keys_folder/$name/certbot/work \
		--logs-dir $keys_folder/$name/certbot/logs \
		-d $domain_list
fi


if [ -f $keys_folder/$name/ec.letsencrypt.crt ] || [ -f $keys_folder/$name/ec.letsencrypt.chain.crt ] || [ -f $keys_folder/$name/ec.letsencrypt.fullchain.crt ]
then
    echo "Skipping RSA key generation as it already exists..."
else
	echo "Signing EC key"
	certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials cloudflare.ini \
		--csr $keys_folder/$name/ec.csr \
		--cert-path $keys_folder/$name/ec.letsencrypt.crt \
		--chain-path $keys_folder/$name/ec.letsencrypt.chain.crt \
		--fullchain-path $keys_folder/$name/ec.letsencrypt.fullchain.crt \
		--config-dir $keys_folder/$name/certbot/config \
		--work-dir $keys_folder/$name/certbot/work \
		--logs-dir $keys_folder/$name/certbot/logs \
		-d $domain_list
fi

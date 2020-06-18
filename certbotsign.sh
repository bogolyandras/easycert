#!/bin/bash

. ./config.sh

if [ ! -d $keys_folder ]
then
    "Keys folders does not exitst"
    exit 1
fi

if [ -z $1 ]
then
    echo "Please enter a name for the key: "
    read name
else
    name=$1
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

echo "Signing RSA key"

docker run \
	--rm -it \
	-v `pwd`/cloudflare.ini:/cloudflare.ini \
	-v `pwd`/$keys_folder/$name/certbot:/etc/letsencrypt \
	-v `pwd`/$keys_folder/$name:/data \
	certbot/dns-cloudflare certonly \
	--dns-cloudflare --dns-cloudflare-credentials /cloudflare.ini \
	--csr /data/rsa.csr \
	--cert-path /data/rsa.letsencrypt.crt \
	--chain-path /data/rsa.letsencrypt.chain.crt \
	--fullchain-path /data/rsa.letsencrypt.fullchain.crt \
	-d $domain_list

echo "Signing EC key"

docker run \
	--rm -it \
	-v `pwd`/cloudflare.ini:/cloudflare.ini \
	-v `pwd`/$keys_folder/$name/certbot:/etc/letsencrypt \
	-v `pwd`/$keys_folder/$name:/data \
	certbot/dns-cloudflare certonly \
	--dns-cloudflare --dns-cloudflare-credentials /cloudflare.ini \
	--csr /data/ec.csr \
	--cert-path /data/ec.letsencrypt.crt \
	--chain-path /data/ec.letsencrypt.chain.crt \
	--fullchain-path /data/ec.letsencrypt.fullchain.crt \
	-d $domain_list
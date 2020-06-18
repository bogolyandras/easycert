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

openssl x509 \
	-extfile $keys_folder/$name/csr.cnf \
	-extensions v3_req \
	-req -signkey $keys_folder/$name/rsa.key \
	-in $keys_folder/$name/rsa.csr -out $keys_folder/$name/rsa.selfsigned.crt

openssl x509 \
	-extfile $keys_folder/$name/csr.cnf \
	-extensions v3_req \
	-req -signkey $keys_folder/$name/ec.key \
	-in $keys_folder/$name/ec.csr -out $keys_folder/$name/ec.selfsigned.crt
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

if [ ! -d $packages_folder ]
then
    mkdir $packages_folder
fi

cd $keys_folder/$name
tar -czf ../../$packages_folder/$name.tar.gz rsa.key rsa.letsencrypt.fullchain.crt ec.key ec.letsencrypt.fullchain.crt
cd ../..
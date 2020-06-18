#!/bin/bash

# Generates
# - RSA and EC private keys
# - Correspoinding Certificate signing requests

. ./config.sh

if [ ! -d $keys_folder ]
then
    mkdir $keys_folder
fi

if [ -z $1 ]
then
    echo "Please enter a name for the key: "
    read name
else
    name=$1
fi

echo "Using name $name"

if [ -d $keys_folder/$name ]
then
    echo "Directory $keys_folder/$name already exists!"
    exit 1
fi

mkdir $keys_folder/$name

openssl genrsa -out  $keys_folder/$name/rsa.key 2048
openssl ecparam -genkey -name prime256v1 -out $keys_folder/$name/ec.key

echo "Please define common name"
read common_name

alternative_names=()
echo "Please define alternative names"
while read line
do
    if [ -z $line ]
    then
        # empty input
        break
    else
        alternative_names+=( $line )
    fi
done

cat libs/req_1.cnf > $keys_folder/$name/req.cnf
echo -e "\ncommonName = $common_name" >> $keys_folder/$name/req.cnf
echo -e "" >> $keys_folder/$name/req.cnf
cat libs/req_2.cnf >> $keys_folder/$name/req.cnf
cat libs/req_2.cnf >> $keys_folder/$name/csr.cnf


if [ ${#alternative_names[@]} -eq 0 ]
then
    echo "INFO: No alternative names provided."
else
    # Alternative names provided
    echo -e "" >> $keys_folder/$name/req.cnf
    echo -e "" >> $keys_folder/$name/csr.cnf
    cat libs/req_3.cnf >> $keys_folder/$name/req.cnf
    cat libs/req_3.cnf >> $keys_folder/$name/csr.cnf
    echo -e "" >> $keys_folder/$name/req.cnf
    echo -e "" >> $keys_folder/$name/csr.cnf
    i=1
    for alternative_name in "${alternative_names[@]}"
    do
        echo -e "DNS.$i = $alternative_name" >> $keys_folder/$name/req.cnf
        echo -e "DNS.$i = $alternative_name" >> $keys_folder/$name/csr.cnf
        if [ $i -gt 1 ]; then
            printf "," >> $keys_folder/$name/csr.meta
        fi
        printf "$alternative_name" >> $keys_folder/$name/csr.meta
        i=$((i+1))
    done

fi

openssl req -new \
    -key $keys_folder/$name/rsa.key \
    -sha256 \
    -config $keys_folder/$name/req.cnf \
    -out $keys_folder/$name/rsa.csr

openssl req -new \
    -key $keys_folder/$name/ec.key \
    -sha256 \
    -config $keys_folder/$name/req.cnf \
    -out $keys_folder/$name/ec.csr

rm $keys_folder/$name/req.cnf

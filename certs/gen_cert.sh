#!/bin/bash

function gen_key() {
    keytool \
        -keystore keystores/${KEYSTORE_NAME}.keystore.jks \
        -alias ${KEY_NAME} \
        -dname "CN=${KEY_NAME}, OU=Administration, O=Docler Holding, L=Luxemborug, S=Luxembourg, C=LU" \
        -validity 3650 \
        -genkey \
        -keyalg RSA \
        -storetype pkcs12 \
        -ext SAN=DNS:${DNS_NAME},IP:${IP},IP:127.0.0.1
}

function gen_csr() {
    keytool \
        -certreq \
        -alias ${KEY_NAME} \
        -keyalg RSA \
        -file csrs/${KEY_NAME}.csr \
        -keystore keystores/${KEYSTORE_NAME}.keystore.jks \
        -ext SAN=DNS:${DNS_NAME},IP:${IP},IP:127.0.0.1
}

function sign_cert() {
    openssl \
        ca \
        -config openssl-ca.cnf \
        -policy signing_policy \
        -extensions signing_req -out certs/${KEY_NAME}.pem \
        -infiles csrs/${KEY_NAME}.csr
}

function import_cert() {
    keytool \
        -keystore keystores/${KEYSTORE_NAME}.keystore.jks \
        -alias ${KEY_NAME} \
        -import -file certs/${KEY_NAME}.pem
}

function import_root_ca() {
    keytool \
        -keystore keystores/${KEYSTORE_NAME}.keystore.jks \
        -alias CARoot \
        -import -file ca/cacert.pem
}

function init() {
    read -p "!!!This will remove all keys, keystores, certs, csrs and the root CA!!! Are you sure? (y/n)" -n 1 -r
    echo 
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
    # Cleanup
    rm -f keystores/*
    rm -f csrs/*
    rm -f certs/*
    rm -f ca/*
    rm -f keys/*
    rm -f serial.*
    rm -f index.*
    rm -f *.pem

    # Create dirs
    mkdir keystores/ csrs/ certs/ ca/ keys/
    > index.txt
    echo "01" > serial.txt

    echo "Generating root CA"
    openssl req -x509 -days 3650 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out ca/cacert.pem -outform PEM -keyout ca/cakey.pem
    chmod 0400 ca/cakey.pem
    chmod 0400 ca/cacert.pem

    echo "Importing CA to client truststore"
    keytool -keystore keystores/client.truststore.jks -alias CARoot -import -file ca/cacert.pem
    echo "Importing CA to server truststore"
    keytool -keystore keystores/server.truststore.jks -alias CARoot -import -file ca/cacert.pem

    echo 
    echo "Root CA cert: ca/cacert.pem"
    echo "Root CA key:  ca/cacert.key"
    echo "Server Truststore: keystores/server.truststore.jks"
    echo "Client Truststore: keystores/client.truststore.jks"
    echo
}

function generate_jks() {
    # Key, csr and cert for brokers
    echo "Key name: ${KEY_NAME}"
    echo "Keystore name: ${KEYSTORE_NAME}"
    echo "SAN DNS name: ${DNS_NAME}"
    echo "SAN IP: ${IP}"

    read -p "Is it OK? (y/n)" -n 1 -r
    echo  
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi

    echo "Generating key for ${KEY_NAME}"
    gen_key
    echo "Generating csr for ${KEY_NAME}"
    gen_csr
    echo "Signing the csr for ${KEY_NAME}"
    sign_cert
    echo "Importing CA to ${KEY_NAME} keystore"
    import_root_ca
    echo "Importing signed cert for ${KEY_NAME}"
    import_cert

    echo 
    echo "Generated keystore: keystores/${KEYSTORE_NAME}.kestore.jks"
    echo
}

function generate_pem() {
    echo "Key name: ${KEY_NAME}.key"
    echo "Cert name: ${KEY_NAME}.crt"

    read -p "Is it OK? (y/n)" -n 1 -r
    echo  
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
    echo "Generating key and csr"
    openssl req -config openssl-ca.cnf -newkey rsa:2048 -nodes -keyout keys/${KEY_NAME}.key -out csrs/${KEY_NAME}.csr
    echo "Signing csr"
    sign_cert
}

function show_help() {
    echo "Generate cert and jks files to use with kafka"
    echo "Usage: ${0} init|broker|client|client-pem"
    echo
    echo "  init        Cleans up everything and initializes a new root CA, server and client truststores"
    echo "  broker      Generates broker keystore with a key. Broker name and SAN defaults to local hostname and ip"
    echo "              Values can be overwritten by ENV variables:"
    echo "                  BROKER_NAME     Name of the broker, defaults to local hostname"
    echo "                  BROKER_KEYSTORE Filename of the keystore, without keystore.jks extension, defaults to BROKER_NAME"
    echo "                  BROKER_DNS      SAN DNS name, defaults to local hostname"
    echo "                  BROKER_IP       SAN IP, defaults to local ip address"
    echo "  client      Generates client keystore with a key. Client name and SAN defaults to local hostname and ip"
    echo "              Values can be overwritten by ENV variables:"
    echo "                  CLIENT_NAME     Name of the client, defaults to local hostname"
    echo "                  CLIENT_KEYSTORE Filename of the keystore, without keystore.jks extension, defaults to CLIENT_NAME"
    echo "                  CLIENT_DNS      SAN DNS name, defaults to local hostname"
    echo "                  CLIENT_IP       SAN IP, defaults to local ip address"
    echo "  client-pem  Generates client cert in pem format." 
    echo "              Values can be overwritten by ENV variables:"
    echo "                  CLIENT_NAME     Name of the client, defaults to 'client'"
    exit 1
}

if [ "${#}" -ne 1 ]; then
    show_help
fi

case "${@}" in
    "init" )
        init
        ;;
    "broker" )
        KEY_NAME=${BROKER_NAME:-$(hostname)}
        KEYSTORE_NAME=${BROKER_KEYSTORE:-${KEY_NAME}}
        DNS_NAME=${BROKER_HOSTNAME:-localhost}
        IP=${BROKER_IP:-$(hostname -i)}
        generate_jks
        ;;
    "client" )
        KEY_NAME=${CLIENT_NAME:-client}
        KEYSTORE_NAME=${CLIENT_KEYSTORE:-${KEY_NAME}}
        DNS_NAME=${CLIENT_HOSTNAME:-$(hostname)}
        IP=${CLIENT_IP:-$(hostname -i)}
        generate_jks
        ;;
    "client-pem" )
        KEY_NAME=${CLIENT_NAME:-client}
        generate_pem
        ;;
    * )
        show_help
        ;;
esac

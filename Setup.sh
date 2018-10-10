#!/bin/bash

# if [ "$EUID" -ne 0 ]
#  then echo "Please run as root eg. (sudo Setup.sh)"
#  exit
#fi

domainProvided=0
emailProvided=0
userProvided=0
passwordProvided=0

amountOfParameters="$#"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--domain)
    DOMAIN="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--email)
    EMAIL="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--user)
    USER="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z ${DOMAIN+x} ]; then echo "Domain was not supplied"; else domainProvided=1; fi
if [ -z ${EMAIL+x} ]; then echo "Email was not supplied"; else emailProvided=1; fi
if [ -z ${USER+x} ]; then echo "User was not supplied"; else userProvided=1; fi
if [ -z ${PASSWORD+x} ]; then echo "Password was not supplied"; else passwordProvided=1; fi

if [ "$emailProvided" -ne 1 ] || [ "$domainProvided" -ne 1 ] || [ "$userProvided" -ne 1 ] || [ "$passwordProvided" -ne 1 ] ; then
  echo "Error: both variables must be provided, and only one of each"
  echo "Usage: sudo Setup.sh -domain mysite.com -email my@email.com -u user -p password"
  exit 1
fi

echo DOMAIN             = "${DOMAIN}"
echo EMAIL              = "${EMAIL}"
echo USER               = "${USER}"
echo PASSWORD           = "${PASSWORD}"

echo Create docker network
docker network create web

echo Creating the folder /opt/traefik
mkdir -p /opt/traefik

echo Copying files to the new folder
yes | cp -rf ./Setup/acme.json /opt/traefik/acme.json
yes | cp -rf ./Setup/traefik.toml /opt/traefik/traefik.toml

echo Running CHMOD 600 on the acme.json file
chmod 600 /opt/traefik/acme.json

firstPartEmail='s*YourMail*'
lastPartEmail='*'
emailConcat=$firstPartEmail$EMAIL$lastPartEmail

firstPartDomain='s*YourDomain*'
lastPartDomain='*'
domainConcat=$firstPartDomain$DOMAIN$lastPartDomain

basicUserAuthInfo=$(htpasswd -nb $USER $PASSWORD)

echo $basicUserAuthInfo

firstPartUser='s*ApiUser*'
lastPartUser='*'
userConcat=$firstPartUser$basicUserAuthInfo$lastPartUser

echo $userConcat

sed -i "$emailConcat" /opt/traefik/traefik.toml
sed -i "$domainConcat" /opt/traefik/traefik.toml
sed -i "$userConcat" /opt/traefik/traefik.toml

docker-compose up -d traefik


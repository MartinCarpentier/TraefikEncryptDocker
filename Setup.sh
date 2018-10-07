#!/bin/bash

# if [ "$EUID" -ne 0 ]
#  then echo "Please run as root eg. (sudo Setup.sh)"
#  exit
#fi

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
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z ${DOMAIN+x} ]; then echo "Domain was not supplied"; else domainProvided=1; fi
if [ -z ${EMAIL+x} ]; then echo "Email was not supplied"; else emailProvided=1; fi

if [ "$amountOfParameters" -ne 4 ] || [ "$emailProvided" -ne 1 ] || [ "$domainProvided" -ne 1 ] ; then
  echo "Error: both variables must be provided, and only one of each"
  echo "Usage: sudo Setup.sh -domain mysite.com -email my@email.com"
  exit 1
fi

echo DOMAIN          = "${DOMAIN}"
echo EMAIL           = "${EMAIL}"

echo Create docker network
docker network create web

echo Creating the folder /opt/traefik
mkdir -p /opt/traefik

echo Copying files to the new folder
yes | cp -rf ./Setup/docker-compose.yml /opt/traefik/docker-compose.yml
yes | cp -rf ./Setup/acme.json /opt/traefik/acme.json
yes | cp -rf ./Setup/traefik.toml /opt/traefik/traefik.toml

echo Running CHMOD 600 on the acme.json file
chmod 600 /opt/traefik/acme.json

echo 's/email = "YourMail"/email = "$DOMAIN"/'
echo 's/email = "YourMail"/email = "$DOMAIN"/'

sed -i 's/email = "YourMail"/email = "$DOMAIN"/' /opt/traefik/traefik.toml
sed -i 's/domain = "YourDomain"/email = "$EMAIL"/' /opt/traefik/traefik.toml


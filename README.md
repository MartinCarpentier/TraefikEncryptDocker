# Træfik - Lets Encrypt - Docker
Skeleton of a træfik setup with automatic creation of letsencrypt certificates for domains. In this setup traefik is used as an edge router.

The setup is made to be easily used by cloning and running few commands.

The guide linked below is the primary source of this setup.

[Traefik and LetsEncrypt tutorial](https://docs.traefik.io/user-guide/docker-and-lets-encrypt/)

_Versions used_

Software    | Versions
-------     | -------
Traefik     | 1.7.2
Docker      | 18.06.1-ce
Ubuntu      | Xenial (16.04 LTS)

## Quickstart

Start by cloning this repository.

``` bash
git clone https://github.com/MartinCarpentier/TraefikEncryptDocker.git
```

Then run the following bash script as a sudo user, to setup the correct files on the computer.

Both domain and email must be provided, else the script fails.

``` bash
sudo Setup.sh -d mydomain.com -e my@email.com
```
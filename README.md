# Fatec Estágios Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge&logo=appveyor)](https://opensource.org/licenses/MIT)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Traefik](https://img.shields.io/badge/traefik-EE732C?style=for-the-badge&logo=traefik&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Minio](https://img.shields.io/badge/minio-00C8FF?style=for-the-badge&logo=minio&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/rabbitmq-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)

This repository contains a set of Docker Compose containers to set up the infrastructure for Fatec Estágios.

## Prerequisites

Make sure you have Docker and Docker Compose installed on your machine.

## Usage

### 1. Clone the repository:

   ```bash
   git clone git@github.com:lotaviods/link-fatec-infra.git
   ```

### 2. Navigate to the project directory:
   ```bash
   cd fatec-estagios-infrastructure
   ```

### 3. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```
   - This command starts the necessary containers in detached mode, allowing the process to run in the background.


## Infrastructure

The infrastructure includes the following services:

### CoreDNS
- Image: coredns/coredns
- Container name: estagio-fatec-coredns
- Ports: 53/udp, 53/tcp
- Volumes: `./coredns/Corefile:/Corefile`, `./coredns/etc/:/coredns-config/`

### Traefik
- Image: traefik:v2.5
- Container name: estagio-fatec-traefik
- Ports: 80, 443, 8080
- Volumes: `/var/run/docker.sock:/var/run/docker.sock:ro`, `./traefik/config:/var/traefik/config`, `./traefik/certs:/var/traefik/certs`, `./traefik/log:/var/traefik/log`, `./traefik/traefik.yml:/etc/traefik/traefik.yml`

### Database
- Image: mysql:8.0-debian
- Container name: fatec-db
- Ports: MySQL_PORT (default: 3306)
- Volumes: `${MYSQL_VOLUME_PATH_HOST}:/var/lib/mysql`
- Environment variables: `MYSQL_ROOT_PASSWORD`, `LINK_FATEC_DB_PASSWORD`
- Labels for Traefik: `HostSNI(db.fatec.estagio.com)`, `entrypoints=db`

### Minio S3
- Image: quay.io/minio/minio:RELEASE.2023-04-07T05-28-58Z.fips
- Container name: estagio-fatec-minio
- Ports: LINK_FATEC_MINIO_PORT (default: 9090), LINK_FATEC_MINIO_PORT_CONSOLE (default: 9091)
- Volumes: `minio_storage:/data`
- Environment variables: `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_HTTP_ENABLE`
- Command: `server /data --console-address ":${LINK_FATEC_MINIO_PORT_CONSOLE}"`

### RabbitMQ
- Image: rabbitmq:3.8-management
- Container name: estagio-fatec-rabbitmq
- Ports: LINK_FATEC_RABBIT_PORT (default: 5672), LINK_FATEC_RABBIT_WEB_PORT (default: 15672)
- Environment variables: `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS`
- Labels for Traefik: `Host(rabbitmq.fatec.estagio.com)`, `entrypoints=default`

### Environment Variables
Make sure to set the following environment variables either in your local environment or in a `.env` file:

- `MYSQL_ENTRYPOINT_INITDB`
- `MYSQL_VOLUME_PATH_HOST`
- `MYSQL_PORT`
- `LINK_FATEC_DB_PASSWORD`
- `LINK_FATEC_XDEBUG_PORT`
- `LINK_FATEC_MINIO_ROOT_USER`
- `LINK_FATEC_MINIO_ROOT_PASSWORD`
- `LINK_FATEC_MINIO_PORT`
- `LINK_FATEC_MINIO_PORT_CONSOLE`
- `LINK_FATEC_RABBIT_WEB_PORT`
- `LINK_FATEC_RABBIT_PORT`
- `LINK_FATEC_RABBIT_PASSWORD`
- `LINK_FATEC_RABBIT_USER`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

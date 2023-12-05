#!/bin/bash
if [ !"$(docker ps -a -q -f name=postgres_boundary)" ]; then
    docker pull postgres:latest
    docker run \
    --detach \
    --name postgres_boundary \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=rootpassword \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
	-v $HOME/pgdata:/var/lib/postgresql/data \
    -p 5432:5432 \
    --rm \
    postgres
fi
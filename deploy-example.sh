#!/bin/sh

# SSH info
USER=exampleUser
HOST=example.com
PORT=1234
DIR=docker/caddy/site/   # the directory where your web site files should go

hugo && echo "deploying to website..." && rsync -avz -e "ssh -p ${PORT}" --delete public/ ${USER}@${HOST}:~/${DIR} && echo "Sucessful deployment." # this will delete everything on the server that's not in the local public folder 

exit 0


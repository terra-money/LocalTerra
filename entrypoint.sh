#!/bin/sh

set -eux

# Start the nginx process
nginx -g "daemon off" &

exec $@
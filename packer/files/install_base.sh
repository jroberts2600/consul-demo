#! /bin/bash

set -e

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo 'Waiting for cloud-init to finish...'
  sleep 1
done

echo "Updating and installing required software..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -qq -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y unzip wget jq python3-pip

echo "Package update & install finished!"


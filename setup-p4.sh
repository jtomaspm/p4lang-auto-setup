#!/bin/bash

cp -r patches ~

chmod +x ./base-dependencies.sh
chmod +x ./p4-repos.sh
chmod +x ./dev-dependencies.sh

sudo ./base-dependencies.sh
sudo ./p4-repos.sh
sudo ./dev-dependencies.sh

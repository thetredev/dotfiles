#!/bin/bash

apt-get -y autoclean
apt-get -y clean
rm -rf /var/lib/apt/lists/*

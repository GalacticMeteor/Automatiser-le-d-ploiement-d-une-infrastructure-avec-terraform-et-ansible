#!/bin/bash

# Define a list of servers (hostnames or IPs)
servers=("172.31.42.95" "172.31.41.36")

# Iterate through the list
for server in "${servers[@]}"; do
        sudo ssh-copy-id -i ~/.ssh/id_rsa.pub $server
done
#!/bin/bash
# 01-resource-group.sh
# Creates the resource group for the secure web app project
# All project resources will be deployed into this group

set -e

RESOURCE_GROUP="rg-secure-web-app"
LOCATION="australiaeast"

echo "Creating resource group: $RESOURCE_GROUP in $LOCATION"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags \
    Environment=Production \
    Project=secure-web-app \
    Owner=Dominic

echo "✓ Resource group created successfully"
echo "  Name:     $RESOURCE_GROUP"
echo "  Location: $LOCATION"

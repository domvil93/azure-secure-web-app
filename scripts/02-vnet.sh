#!/bin/bash
# 02-vnet.sh
# Creates the VNet and three-tier subnet architecture
# subnet-web:  public facing web tier
# subnet-app:  internal application tier
# subnet-data: data tier — no internet access

set -e

RESOURCE_GROUP="rg-secure-web-app"
VNET_NAME="vnet-secure-web-app"
LOCATION="australiaeast"

echo "================================================"
echo "Creating VNet and subnets"
echo "================================================"
echo ""

# Create VNet with address space
echo "Step 1: Creating VNet..."
az network vnet create \
  --name $VNET_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --tags \
    Environment=Production \
    Project=secure-web-app

echo "✓ VNet created: $VNET_NAME (10.0.0.0/16)"
echo ""

# Create subnet-web — public facing tier
echo "Step 2: Creating subnet-web..."
az network vnet subnet create \
  --name subnet-web \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.1.0/24
echo "✓ subnet-web created: 10.0.1.0/24"

# Create subnet-app — application tier
echo "Step 3: Creating subnet-app..."
az network vnet subnet create \
  --name subnet-app \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.2.0/24
echo "✓ subnet-app created: 10.0.2.0/24"

# Create subnet-data — data tier
echo "Step 4: Creating subnet-data..."
az network vnet subnet create \
  --name subnet-data \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.3.0/24
echo "✓ subnet-data created: 10.0.3.0/24"

echo ""
echo "================================================"
echo "VNet deployment complete"
echo ""
echo "Network topology:"
echo "  VNet:        $VNET_NAME (10.0.0.0/16)"
echo "  subnet-web:  10.0.1.0/24 (251 usable IPs)"
echo "  subnet-app:  10.0.2.0/24 (251 usable IPs)"
echo "  subnet-data: 10.0.3.0/24 (251 usable IPs)"
echo ""
echo "Next step: Create NSGs to enforce tier isolation"
echo "================================================"

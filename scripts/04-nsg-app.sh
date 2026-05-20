#!/bin/bash
# 04-nsg-app.sh
# Creates and configures NSG for subnet-app
# Allows: inbound from subnet-web on 8080, outbound to subnet-data on 1433
# Blocks: all internet inbound, all internet outbound

set -e

RESOURCE_GROUP="rg-secure-web-app"
NSG_NAME="nsg-app"
LOCATION="australiaeast"

echo "================================================"
echo "Creating NSG for subnet-app"
echo "================================================"
echo ""

# Create the NSG
echo "Step 1: Creating NSG..."
az network nsg create \
  --name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --tags Environment=Production Project=secure-web-app
echo "✓ NSG created: $NSG_NAME"
echo ""

# Inbound rule — allow from subnet-web on 8080
echo "Step 2: Adding inbound rules..."
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Allow-From-WebTier \
  --priority 100 \
  --direction Inbound \
  --source-address-prefixes 10.0.1.0/24 \
  --destination-port-ranges 8080 \
  --protocol Tcp \
  --access Allow \
  --description "Allow app tier to receive from web tier on 8080 only"
echo "✓ Rule added: Allow inbound from subnet-web:8080 (priority 100)"

# Inbound rule — deny all internet
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Deny-Internet-Inbound \
  --priority 110 \
  --direction Inbound \
  --source-address-prefixes Internet \
  --destination-port-ranges "*" \
  --protocol "*" \
  --access Deny \
  --description "Block all direct internet access to app tier"
echo "✓ Rule added: Deny all internet inbound (priority 110)"
echo ""

# Outbound rule — allow to subnet-data on 1433
echo "Step 3: Adding outbound rules..."
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Allow-To-DataTier \
  --priority 100 \
  --direction Outbound \
  --destination-address-prefixes 10.0.3.0/24 \
  --destination-port-ranges 1433 \
  --protocol Tcp \
  --access Allow \
  --description "Allow app tier to reach data tier on SQL port 1433"
echo "✓ Rule added: Allow outbound to subnet-data:1433 (priority 100)"

# Outbound rule — deny internet
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Deny-Internet-Outbound \
  --priority 110 \
  --direction Outbound \
  --destination-address-prefixes Internet \
  --destination-port-ranges "*" \
  --protocol "*" \
  --access Deny \
  --description "Block app tier from reaching internet directly"
echo "✓ Rule added: Deny internet outbound (priority 110)"
echo ""

# Associate NSG with subnet-app
echo "Step 4: Associating NSG with subnet-app..."
az network vnet subnet update \
  --name subnet-app \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-secure-web-app \
  --network-security-group $NSG_NAME
echo "✓ NSG associated with subnet-app"

echo ""
echo "================================================"
echo "nsg-app deployment complete"
echo ""
echo "Rules summary:"
echo "  Inbound:  Allow 8080 from subnet-web (100)"
echo "  Inbound:  Deny all from Internet (110)"
echo "  Outbound: Allow 1433 to subnet-data (100)"
echo "  Outbound: Deny all to Internet (110)"
echo "================================================"

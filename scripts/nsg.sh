cat > scripts/03-nsg-web.sh << 'EOF'
#!/bin/bash
# 03-nsg-web.sh
# Creates and configures NSG for subnet-web
# Allows: HTTP/HTTPS from internet, outbound to subnet-app on 8080
# Blocks: SSH from internet, direct access to subnet-data

set -e

RESOURCE_GROUP="rg-secure-web-app"
NSG_NAME="nsg-web"
LOCATION="australiaeast"

echo "================================================"
echo "Creating NSG for subnet-web"
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

# Inbound rule — allow HTTP
echo "Step 2: Adding inbound rules..."
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Allow-HTTP-Inbound \
  --priority 100 \
  --direction Inbound \
  --source-address-prefixes Internet \
  --destination-port-ranges 80 \
  --protocol Tcp \
  --access Allow \
  --description "Allow HTTP from internet to web tier"
echo "✓ Rule added: Allow HTTP inbound (priority 100)"

# Inbound rule — allow HTTPS
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Allow-HTTPS-Inbound \
  --priority 110 \
  --direction Inbound \
  --source-address-prefixes Internet \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow \
  --description "Allow HTTPS from internet to web tier"
echo "✓ Rule added: Allow HTTPS inbound (priority 110)"

# Inbound rule — block SSH from internet
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Deny-SSH-Internet \
  --priority 120 \
  --direction Inbound \
  --source-address-prefixes Internet \
  --destination-port-ranges 22 \
  --protocol Tcp \
  --access Deny \
  --description "Block SSH from internet — use jump server or Bastion"
echo "✓ Rule added: Deny SSH from internet (priority 120)"
echo ""

# Outbound rule — allow to subnet-app on 8080
echo "Step 3: Adding outbound rules..."
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Allow-To-AppTier \
  --priority 100 \
  --direction Outbound \
  --destination-address-prefixes 10.0.2.0/24 \
  --destination-port-ranges 8080 \
  --protocol Tcp \
  --access Allow \
  --description "Allow web tier to reach app tier on 8080 only"
echo "✓ Rule added: Allow outbound to subnet-app:8080 (priority 100)"

# Outbound rule — block direct access to subnet-data
az network nsg rule create \
  --nsg-name $NSG_NAME \
  --resource-group $RESOURCE_GROUP \
  --name Deny-Direct-To-Data \
  --priority 110 \
  --direction Outbound \
  --destination-address-prefixes 10.0.3.0/24 \
  --destination-port-ranges "*" \
  --protocol "*" \
  --access Deny \
  --description "Block web tier from directly reaching data tier"
echo "✓ Rule added: Deny outbound to subnet-data (priority 110)"
echo ""

# Associate NSG with subnet-web
echo "Step 4: Associating NSG with subnet-web..."
az network vnet subnet update \
  --name subnet-web \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-secure-web-app \
  --network-security-group $NSG_NAME
echo "✓ NSG associated with subnet-web"

echo ""
echo "================================================"
echo "nsg-web deployment complete"
echo ""
echo "Rules summary:"
echo "  Inbound:  Allow 80 from Internet (100)"
echo "  Inbound:  Allow 443 from Internet (110)"
echo "  Inbound:  Deny 22 from Internet (120)"
echo "  Outbound: Allow 8080 to subnet-app (100)"
echo "  Outbound: Deny all to subnet-data (110)"
echo "================================================"
EOF

chmod +x scripts/03-nsg-web.sh

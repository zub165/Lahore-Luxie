#!/bin/bash

# Local server deployment script for Lahore Luxie

# Configuration - update these values
LOCAL_SERVER_USER="newgen"
LOCAL_SERVER_IP="192.168.4.151"
LOCAL_SERVER_PATH="/var/www/html/lahore-luxie"
NODE_PATH="/usr/bin/node"  # Update this to the correct path on your server

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting deployment to local server...${NC}"

# Ensure the directory exists on the server
echo "Creating directory if it doesn't exist..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "mkdir -p $LOCAL_SERVER_PATH"

# Copy files to the server
echo "Copying files to server..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.github' ./ $LOCAL_SERVER_USER@$LOCAL_SERVER_IP:$LOCAL_SERVER_PATH

# Install dependencies on the server
echo "Installing dependencies on server..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && npm install --production"

# Start or restart the server
echo "Starting/restarting the server..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && pm2 restart lahore-luxie || $NODE_PATH $LOCAL_SERVER_PATH/server.js > /dev/null 2>&1 &"

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "Your site should be available at: ${GREEN}http://$LOCAL_SERVER_IP:3000${NC}" 
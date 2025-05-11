#!/bin/bash

# Local server deployment script for Lahore Luxie (Python version)

# Configuration - update these values
LOCAL_SERVER_USER="newgen"
LOCAL_SERVER_IP="192.168.4.151"
LOCAL_SERVER_PATH="~/lahore-luxie"  # Using home directory instead of /var/www/html
BACKEND_PORT=5000  # Using a less common port
FRONTEND_PORT=5001  # Using a less common port
PYTHON_PATH="/usr/bin/python3"  # Update this to the correct Python path on your server

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting deployment to local server...${NC}"

# Setup SSH key for passwordless login
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Setting up SSH key for passwordless login..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub | ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
    echo "SSH key setup complete. You may need to enter your password one more time."
fi

# Check if we can connect to the server
echo "Checking connection to server..."
if ! ssh -o ConnectTimeout=5 $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "echo 'Connection successful'" > /dev/null 2>&1; then
    echo -e "${RED}Cannot connect to server. Please check your credentials and try again.${NC}"
    exit 1
fi

# Check Python version
echo "Checking Python version on server..."
PYTHON_VERSION=$(ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "python3 --version" 2>&1)
echo -e "Found: ${YELLOW}$PYTHON_VERSION${NC}"

# Check if pip is installed
echo "Checking if pip is installed..."
if ! ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "which pip3" > /dev/null 2>&1; then
    echo -e "${RED}pip3 is not installed on the server. Please install pip3 and try again.${NC}"
    exit 1
fi

# Ensure the directory exists on the server
echo "Creating directory if it doesn't exist..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "mkdir -p $LOCAL_SERVER_PATH/uploads"

# Copy files to the server
echo "Copying files to server..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.github' ./ $LOCAL_SERVER_USER@$LOCAL_SERVER_IP:$LOCAL_SERVER_PATH

# Install Python dependencies on the server
echo "Installing Python dependencies on server..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pip3 install --user fastapi uvicorn python-multipart"

# Update the API URLs in the HTML file for the new port
echo "Updating API URLs in index.html..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "sed -i 's/:8000/':$BACKEND_PORT'/g' $LOCAL_SERVER_PATH/index.html"

# Check if the servers are already running
echo "Checking for existing servers..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pkill -f 'uvicorn backend.main:app' || true"
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pkill -f 'python3 -m http.server' || true"

# Start the FastAPI backend server
echo "Starting the FastAPI backend server..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && nohup uvicorn backend.main:app --host 0.0.0.0 --port $BACKEND_PORT > server.log 2>&1 &"

# Set up a simple HTTP server for the static files
echo "Setting up HTTP server for static files..."
ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && nohup python3 -m http.server $FRONTEND_PORT > frontend.log 2>&1 &"

# Verify that the servers are running
echo "Verifying servers are running..."
sleep 2
if ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'uvicorn backend.main:app'" > /dev/null 2>&1; then
    echo -e "${GREEN}FastAPI backend is running.${NC}"
else
    echo -e "${RED}Warning: FastAPI backend may not have started. Check server.log on the server.${NC}"
fi

if ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'python3 -m http.server'" > /dev/null 2>&1; then
    echo -e "${GREEN}Frontend server is running.${NC}"
else
    echo -e "${RED}Warning: Frontend server may not have started. Check frontend.log on the server.${NC}"
fi

echo -e "${GREEN}Deployment completed!${NC}"
echo -e "Your backend API should be available at: ${GREEN}http://$LOCAL_SERVER_IP:$BACKEND_PORT${NC}"
echo -e "Your frontend should be available at: ${GREEN}http://$LOCAL_SERVER_IP:$FRONTEND_PORT/index.html${NC}" 
#!/bin/bash

# Script to check the status of deployed services for Lahore Luxie

# Configuration - update these values to match deploy-local.sh
LOCAL_SERVER_USER="newgen"
LOCAL_SERVER_IP="192.168.4.151"
LOCAL_SERVER_PATH="~/lahore-luxie"
BACKEND_PORT=5000
FRONTEND_PORT=5001

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check services
check_services() {
    echo -e "${YELLOW}Checking status of Lahore Luxie deployment...${NC}"

    # Check if backend is running
    echo "Checking if FastAPI backend is running..."
    if ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'uvicorn backend.main:app'" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ FastAPI backend is running.${NC}"
        BACKEND_PID=$(ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'uvicorn backend.main:app'")
        echo -e "  Backend process ID: ${YELLOW}$BACKEND_PID${NC}"
    else
        echo -e "${RED}✗ FastAPI backend is not running.${NC}"
    fi

    # Check if frontend server is running
    echo "Checking if frontend HTTP server is running..."
    if ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'python3 -m http.server $FRONTEND_PORT'" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Frontend HTTP server is running.${NC}"
        FRONTEND_PID=$(ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pgrep -f 'python3 -m http.server $FRONTEND_PORT'")
        echo -e "  Frontend process ID: ${YELLOW}$FRONTEND_PID${NC}"
    else
        echo -e "${RED}✗ Frontend HTTP server is not running.${NC}"
    fi

    # Display URLs
    echo -e "\n${YELLOW}Service URLs:${NC}"
    echo -e "Backend API: ${GREEN}http://$LOCAL_SERVER_IP:$BACKEND_PORT${NC}"
    echo -e "Frontend: ${GREEN}http://$LOCAL_SERVER_IP:$FRONTEND_PORT/index.html${NC}"
}

# Function to restart frontend
restart_frontend() {
    echo -e "\n${YELLOW}Restarting frontend...${NC}"
    ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pkill -f 'python3 -m http.server $FRONTEND_PORT' || true"
    ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && nohup python3 -m http.server $FRONTEND_PORT > frontend.log 2>&1 &"
    echo -e "${GREEN}Frontend restarted.${NC}"
}

# Function to restart backend
restart_backend() {
    echo -e "\n${YELLOW}Restarting backend...${NC}"
    ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "pkill -f 'uvicorn backend.main:app' || true"
    ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cd $LOCAL_SERVER_PATH && source venv/bin/activate && nohup uvicorn backend.main:app --host 0.0.0.0 --port $BACKEND_PORT > server.log 2>&1 &"
    echo -e "${GREEN}Backend restarted.${NC}"
}

# Check if an argument was provided
if [ "$1" != "" ]; then
    case $1 in
        "status")
            check_services
            ;;
        "restart-frontend")
            restart_frontend
            check_services
            ;;
        "restart-backend")
            restart_backend
            check_services
            ;;
        "restart-all")
            restart_backend
            restart_frontend
            check_services
            ;;
        "logs-backend")
            echo -e "\n${YELLOW}Backend logs:${NC}"
            ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cat $LOCAL_SERVER_PATH/server.log"
            ;;
        "logs-frontend")
            echo -e "\n${YELLOW}Frontend logs:${NC}"
            ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cat $LOCAL_SERVER_PATH/frontend.log"
            ;;
        *)
            echo -e "${RED}Invalid argument. Use: status, restart-frontend, restart-backend, restart-all, logs-backend, logs-frontend${NC}"
            exit 1
            ;;
    esac
    exit 0
fi

# Interactive mode
check_services

# Options for user
echo -e "\n${YELLOW}What would you like to do?${NC}"
echo "1) View backend logs"
echo "2) View frontend logs"
echo "3) Restart backend"
echo "4) Restart frontend"
echo "5) Restart both services"
echo "6) Exit"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo -e "\n${YELLOW}Backend logs:${NC}"
        ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cat $LOCAL_SERVER_PATH/server.log"
        ;;
    2)
        echo -e "\n${YELLOW}Frontend logs:${NC}"
        ssh $LOCAL_SERVER_USER@$LOCAL_SERVER_IP "cat $LOCAL_SERVER_PATH/frontend.log"
        ;;
    3)
        restart_backend
        ;;
    4)
        restart_frontend
        ;;
    5)
        restart_backend
        restart_frontend
        ;;
    6)
        echo -e "${GREEN}Exiting.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac 
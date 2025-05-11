# Lahore Luxie

A web application for showcasing a premium fashion and home decor brand with file upload capabilities.

## Project Structure

```
lahore-luxie/
├── backend/
│   ├── main.py (FastAPI backend)
│   └── uploads/ (media storage directory)
├── images/
│   └── zelle-qr.svg (Payment QR code)
├── index.html (Frontend)
├── server.js (Express server for deployment)
├── deploy-local.sh (Deployment script for local server)
├── package.json (Node.js dependencies)
└── README.md (This file)
```

## Prerequisites

- Python 3.7+
- pip (Python package manager)
- Node.js 14+ (for deployment)
- npm (Node.js package manager)
- SSH and rsync (for deployment to local server)

## Setup Instructions

1. Install the required Python dependencies:

```bash
pip install fastapi uvicorn python-multipart
```

2. Start the FastAPI backend:

```bash
# Run from the project root directory
uvicorn backend.main:app --reload
```

3. For local development:
   - Simply open the `index.html` file in a web browser, or
   - Use the included Express server:

```bash
npm install
npm start
```

## Features

- **Media Upload**: Upload images and videos with category and description
- **Gallery View**: View all uploaded media items with proper categorization
- **Responsive Design**: Works on desktop and mobile devices
- **Category Filtering**: Backend supports filtering media by category
- **Payment Options**: Multiple payment methods including Zelle with QR code
- **Contact Form**: Comprehensive contact section with form submission

## API Endpoints

- `POST /upload/`: Upload a new media file
- `GET /media/`: Get all media items
- `GET /media/{category}`: Get media items by category
- `DELETE /media/{media_id}`: Delete a media item

## Deployment to Local Server

The project includes a deployment script for a local server at `192.168.4.151`:

1. Make sure you have SSH access to the server:
```bash
ssh newgen@192.168.4.151
```

2. Ensure Node.js and npm are installed on the server.

3. Optionally, install PM2 on the server for process management:
```bash
npm install -g pm2
```

4. Run the deployment script:
```bash
./deploy-local.sh
```

5. Access your website at `http://192.168.4.151:3000`

### Customizing Local Deployment

If needed, you can modify the `deploy-local.sh` script to adjust:
- User and server IP address
- Deployment path on the server
- Node.js binary path
- Other deployment preferences

## Production Considerations

- Replace the in-memory storage with a proper database
- Add user authentication for upload/delete operations
- Use secure HTTPS connections
- Configure proper backups
- Add logging and monitoring 
# Lahore Luxie

A web application for showcasing a premium fashion and home decor brand with file upload capabilities.

## Project Structure

```
lahore-luxie/
├── backend/
│   ├── main.py (FastAPI backend)
│   └── uploads/ (media storage directory)
├── index.html (Frontend)
└── README.md (This file)
```

## Prerequisites

- Python 3.7+
- pip (Python package manager)

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

3. Open the frontend:
   - Simply open the `index.html` file in a web browser, or
   - Use a local development server to serve it

## Features

- **Media Upload**: Upload images and videos with category and description
- **Gallery View**: View all uploaded media items with proper categorization
- **Responsive Design**: Works on desktop and mobile devices
- **Category Filtering**: Backend supports filtering media by category

## API Endpoints

- `POST /upload/`: Upload a new media file
- `GET /media/`: Get all media items
- `GET /media/{category}`: Get media items by category
- `DELETE /media/{media_id}`: Delete a media item

## Production Considerations

- Replace the in-memory storage with a proper database
- Add user authentication for upload/delete operations
- Use cloud storage for media files
- Implement proper security measures
- Add pagination for the media endpoints 
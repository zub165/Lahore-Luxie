from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from typing import List
import os
import shutil
from datetime import datetime
import uuid

app = FastAPI(title="Lahore Luxie API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create upload directory if it doesn't exist
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Database simulation (in a real app, use a proper database)
media_db = []

# Mount static files directory
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.post("/upload/")
async def upload_media(
    category: str = Form(...),
    description: str = Form(None),
    file: UploadFile = File(...)
):
    # Validate file type
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in [".jpg", ".jpeg", ".png", ".gif", ".mp4", ".mov"]:
        raise HTTPException(status_code=400, detail="Invalid file type")
    
    # Generate unique filename
    file_id = str(uuid.uuid4())
    filename = f"{file_id}{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)
    
    # Save file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Create media record
    media_type = "image" if file_ext in [".jpg", ".jpeg", ".png", ".gif"] else "video"
    media_record = {
        "id": file_id,
        "filename": filename,
        "category": category,
        "description": description,
        "type": media_type,
        "upload_date": datetime.now().isoformat()
    }
    
    # Add to "database"
    media_db.append(media_record)
    
    return {"message": "File uploaded successfully", "data": media_record}

@app.get("/media/", response_model=List[dict])
async def get_all_media():
    return media_db

@app.get("/media/{category}", response_model=List[dict])
async def get_media_by_category(category: str):
    return [item for item in media_db if item["category"] == category]

@app.delete("/media/{media_id}")
async def delete_media(media_id: str):
    global media_db
    media_item = next((item for item in media_db if item["id"] == media_id), None)
    
    if not media_item:
        raise HTTPException(status_code=404, detail="Media not found")
    
    # Remove file
    file_path = os.path.join(UPLOAD_DIR, media_item["filename"])
    if os.path.exists(file_path):
        os.remove(file_path)
    
    # Remove from database
    media_db = [item for item in media_db if item["id"] != media_id]
    
    return {"message": "Media deleted successfully"}
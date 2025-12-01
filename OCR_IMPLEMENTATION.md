# OCR Image Upload Implementation

## Overview

Added image upload with OCR (Optical Character Recognition) functionality to extract text from images and include it in the conversation.

## What Was Implemented

### Backend

1. **OCR Service** (`backend/app/services/ocr.py`)
   - Uses `pytesseract` (Tesseract OCR wrapper)
   - Extracts text from images (PNG, JPEG, etc.)
   - Supports base64-encoded images
   - Formats OCR text for inclusion in prompts

2. **API Updates** (`backend/app/main.py`)
   - Added OCR processing in `/v1/chat/completions` endpoint
   - Processes images from `req.image` field
   - Extracts text and prepends to user message
   - Works with both local and cloud models

3. **Schema Updates** (`backend/app/schemas.py`)
   - Added `image` field to `Message` model
   - Added `image` field to `ChatRequest` model

4. **Dependencies** (`backend/requirements.txt`)
   - Added `pytesseract>=0.3.10`
   - Added `Pillow>=10.0.0`
   - Added `python-multipart>=0.0.6`

### Frontend

1. **Image Upload UI** (`frontend/src/components/Chat.tsx`)
   - Added image upload button (📷 icon)
   - Image preview before sending
   - Remove image button
   - Base64 encoding of images
   - File size validation (max 10MB)
   - Image type validation

2. **Message Handling**
   - Images attached to messages
   - Images sent to backend in request
   - OCR text automatically included in conversation

## How It Works

### Flow

1. **User uploads image** → Frontend converts to base64
2. **User types message** → Message + image sent to backend
3. **Backend processes OCR** → Extracts text from image
4. **OCR text prepended** → Added to user message content
5. **Model receives** → Message with OCR text + user query
6. **Model answers** → Using OCR text and user query

### Example

**User uploads image of a document with text:**
```
"Here is a document I need help with"
```

**Backend extracts OCR text:**
```
Text extracted from attached image using OCR:

[Extracted text from image]

User's question: Here is a document I need help with
Please answer based on the extracted text and the user's question.
```

**Model sees:**
- OCR extracted text
- User's question
- Can answer based on both

## Requirements

### System Requirements

**Tesseract OCR must be installed:**

**macOS:**
```bash
brew install tesseract
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install tesseract-ocr
```

**Windows:**
Download from: https://github.com/UB-Mannheim/tesseract/wiki

### Python Dependencies

Install with:
```bash
pip install -r backend/requirements.txt
```

## Usage

1. Click the 📷 button in the chat input
2. Select an image file (PNG, JPEG, etc.)
3. Image preview appears
4. Type your message
5. Click Send
6. OCR text is automatically extracted and included

## Limitations

- **Tesseract required**: Must be installed on system
- **File size**: Max 10MB
- **Image quality**: Better quality = better OCR results
- **Languages**: Defaults to English (can configure Tesseract for other languages)

## Future Enhancements

- Support for multiple images
- Language detection and selection
- OCR confidence scores
- Image preprocessing (enhancement, rotation)
- Support for PDFs
- OCR result preview before sending


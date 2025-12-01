"""
OCR service for extracting text from images.
Uses Tesseract OCR via pytesseract.
"""

try:
    import pytesseract
    from PIL import Image
    OCR_AVAILABLE = True
    
    # Try to find Tesseract in common locations if not in PATH
    import os
    import platform
    tesseract_paths = []
    
    if platform.system() == "Windows":
        # Windows common locations
        tesseract_paths = [
            r'C:\Program Files\Tesseract-OCR\tesseract.exe',
            r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            os.path.expanduser(r'~\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'),
        ]
    else:
        # macOS/Linux common locations
        tesseract_paths = [
            '/opt/homebrew/bin/tesseract',  # Apple Silicon Homebrew
            '/usr/local/bin/tesseract',     # Intel Homebrew
            '/usr/bin/tesseract',           # System default
        ]
    
    for path in tesseract_paths:
        if os.path.exists(path):
            pytesseract.pytesseract.tesseract_cmd = path
            print(f"OCR: Using Tesseract at {path}")
            break
except ImportError:
    OCR_AVAILABLE = False
    print("Warning: pytesseract or Pillow not installed. OCR functionality will be disabled.")
    print("Install with: pip install pytesseract Pillow")
    print("Also install Tesseract OCR: brew install tesseract (macOS)")

import io
from typing import Optional, Tuple
import base64


def extract_text_from_image(image_data: bytes, image_format: str = "PNG") -> Tuple[Optional[str], bool]:
    """
    Extract text from an image using OCR.
    
    Args:
        image_data: Raw image bytes
        image_format: Image format (PNG, JPEG, etc.)
        
    Returns:
        Tuple of (extracted_text, success)
        - extracted_text: The extracted text, or None if extraction failed
        - success: True if extraction succeeded, False otherwise
    """
    if not OCR_AVAILABLE:
        print("OCR not available: pytesseract or Pillow not installed")
        return None, False
    
    try:
        # Open image from bytes
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary (Tesseract works best with RGB)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Perform OCR
        extracted_text = pytesseract.image_to_string(image)
        
        # Clean up the text
        extracted_text = extracted_text.strip()
        
        if not extracted_text:
            return None, False
        
        return extracted_text, True
        
    except Exception as e:
        print(f"OCR error: {e}")
        return None, False


def extract_text_from_base64(image_base64: str) -> Tuple[Optional[str], bool]:
    """
    Extract text from a base64-encoded image.
    
    Args:
        image_base64: Base64-encoded image string (with or without data URL prefix)
        
    Returns:
        Tuple of (extracted_text, success)
    """
    try:
        # Remove data URL prefix if present (e.g., "data:image/png;base64,")
        if ',' in image_base64:
            image_base64 = image_base64.split(',')[1]
        
        # Decode base64
        image_data = base64.b64decode(image_base64)
        
        return extract_text_from_image(image_data)
        
    except Exception as e:
        print(f"Base64 OCR error: {e}")
        return None, False


def format_ocr_text_for_prompt(ocr_text: str, original_query: str = "") -> str:
    """
    Format OCR-extracted text for inclusion in a prompt.
    
    Args:
        ocr_text: The extracted text from OCR
        original_query: The original user query (optional)
        
    Returns:
        Formatted string to include in prompt
    """
    if not ocr_text:
        return ""
    
    formatted = "Text extracted from attached image using OCR:\n\n"
    formatted += f"{ocr_text}\n\n"
    if original_query:
        formatted += f"User's question: {original_query}\n"
    formatted += "Please answer based on the extracted text and the user's question."
    
    return formatted


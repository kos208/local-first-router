# User API Key Setup - Complete Guide

## Overview

Users need to be able to easily add their Anthropic API key to enable cloud fallback. Here's how the system handles this:

## Current Implementation

### 1. Settings (Backend)
- ✅ API key is **Optional** (`Optional[str] = None`)
- ✅ Defaults to empty/None if not set
- ✅ Loads from `.env` file automatically

### 2. Installer
- ✅ Creates `.env` file with placeholder: `ANTHROPIC_API_KEY=your-key-here`
- ✅ Shows instructions on how to add the key
- ✅ Explains it's optional (local-only mode works without it)

### 3. User Instructions
- ✅ README includes step-by-step guide
- ✅ `API_KEY_SETUP.md` with detailed instructions
- ✅ Installer prints instructions after creating .env

### 4. UI Feedback
- ✅ Shows warning in sidebar when API key is missing
- ✅ Explains how to add it
- ✅ Cloud model option only appears when API key is set

### 5. Error Messages
- ✅ Clear error if cloud is requested but no key
- ✅ Includes link to get API key

## User Flow

### Installation
1. User runs `./install.sh`
2. Installer creates `.env` with `ANTHROPIC_API_KEY=your-key-here`
3. Installer prints: "You can add your ANTHROPIC_API_KEY later..."

### Adding API Key
1. User gets key from https://console.anthropic.com/
2. User edits `.env` file
3. Replaces `your-key-here` with actual key
4. Restarts router: `./stop.sh && ./start.sh`

### Using Without API Key
- ✅ Router works in local-only mode
- ✅ UI shows warning about missing API key
- ✅ Low confidence answers stay local (no cloud fallback)
- ✅ User can still use all features except cloud fallback

## Files Updated

1. **backend/app/settings.py**: API key is Optional
2. **END_USER_README.md**: Clear instructions
3. **install-full.sh**: Shows instructions after creating .env
4. **frontend/src/App.tsx**: UI warning when key missing
5. **backend/app/main.py**: Better error messages
6. **package.sh**: Updated .env.example with instructions

## Testing

To test without API key:
1. Remove or comment out `ANTHROPIC_API_KEY` in `.env`
2. Restart backend
3. UI should show warning
4. Cloud model should not appear in selector
5. Router should work in local-only mode

## Future Enhancements (Optional)

- Add UI form to input API key directly (requires backend endpoint)
- Add API key validation endpoint
- Show API key status in settings panel
- Add "Setup Wizard" on first run


# API Key Setup Guide

## How Users Add Their API Key

### Method 1: Edit .env File (Recommended)

1. After installation, edit the `.env` file:
   ```bash
   nano .env
   # or
   open .env  # macOS
   ```

2. Find this line:
   ```bash
   ANTHROPIC_API_KEY=your-key-here
   ```

3. Replace `your-key-here` with your actual API key:
   ```bash
   ANTHROPIC_API_KEY=sk-ant-api03-...
   ```

4. Save the file

5. Restart the router:
   ```bash
   ./stop.sh
   ./start.sh
   ```

### Method 2: Environment Variable

Set it before starting:
```bash
export ANTHROPIC_API_KEY=sk-ant-api03-...
./start.sh
```

### Getting an API Key

1. Go to: https://console.anthropic.com/
2. Sign up or log in
3. Go to API Keys
4. Create a new key
5. Copy it (starts with `sk-ant-api03-`)

## Important Notes

- **API key is optional**: The router works without it (local-only mode)
- **Cloud fallback requires API key**: Without it, low-confidence queries will use local answers
- **Never commit API keys**: The `.env` file is gitignored
- **Security**: Keep your API key private

## Current Status

The router will:
- ✅ Work without API key (local models only)
- ✅ Show warning if cloud is requested but no key
- ✅ Automatically use cloud when API key is set and confidence is low


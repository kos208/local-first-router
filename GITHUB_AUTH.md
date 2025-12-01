# GitHub Authentication Setup

## The Problem

GitHub no longer accepts passwords for Git operations. You need to use either:
1. **Personal Access Token (PAT)** - Easier for HTTPS
2. **SSH Key** - More secure, one-time setup

---

## Solution 1: Personal Access Token (Recommended - Easier)

### Step 1: Create a Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. **Note:** Give it a name like "local-first-router"
4. **Expiration:** Choose how long (90 days, 1 year, or no expiration)
5. **Scopes:** Check these:
   - ✅ `repo` (Full control of private repositories)
6. Click **"Generate token"**
7. **IMPORTANT:** Copy the token immediately! It looks like: `ghp_xxxxxxxxxxxxxxxxxxxx`

### Step 2: Use Token Instead of Password

When you run `git push`, it will ask for:
- **Username:** `kos208`
- **Password:** Paste your **Personal Access Token** (not your GitHub password!)

```bash
git push -u origin main
# Username: kos208
# Password: <paste your token here>
```

### Step 3: Save Token (Optional - Avoid Re-entering)

You can save the token so you don't have to enter it every time:

```bash
# Store token in Git credential helper
git config --global credential.helper osxkeychain

# Then push (will ask once, then save)
git push -u origin main
```

---

## Solution 2: SSH Key (More Secure)

### Step 1: Check if You Have SSH Key

```bash
ls -la ~/.ssh/id_ed25519.pub
# or
ls -la ~/.ssh/id_rsa.pub
```

### Step 2: Generate SSH Key (if needed)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to accept default location
# Press Enter for no passphrase (or set one)
```

### Step 3: Add SSH Key to GitHub

1. Copy your public key:
```bash
cat ~/.ssh/id_ed25519.pub
# or
cat ~/.ssh/id_rsa.pub
```

2. Go to: https://github.com/settings/keys
3. Click **"New SSH key"**
4. **Title:** "MacBook Air" (or any name)
5. **Key:** Paste the key you copied
6. Click **"Add SSH key"**

### Step 4: Change Remote to SSH

```bash
# Remove HTTPS remote
git remote remove origin

# Add SSH remote
git remote add origin git@github.com:kos208/local-first-router.git

# Test connection
ssh -T git@github.com
# Should say: "Hi kos208! You've successfully authenticated..."

# Push
git push -u origin main
```

---

## Quick Fix for Right Now

Since you already added the remote, just use a Personal Access Token:

1. **Create token:** https://github.com/settings/tokens (see Solution 1 above)
2. **Push again:**
```bash
git push -u origin main
# Username: kos208
# Password: <paste your token>
```

---

## Which Method to Use?

- **Personal Access Token:** Easier, works immediately, good for beginners
- **SSH Key:** More secure, one-time setup, better for long-term use

Both work perfectly! Choose what's easier for you.


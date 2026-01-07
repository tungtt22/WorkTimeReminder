# Homebrew Tap Setup Guide

This guide explains how to set up a Homebrew tap to distribute Work Time Reminder.

## Step 1: Create Homebrew Tap Repository

1. Create a new GitHub repository named `homebrew-tap` at:
   ```
   https://github.com/tungtt22/homebrew-tap
   ```

2. Clone the repository:
   ```bash
   git clone git@github.com:tungtt22/homebrew-tap.git
   cd homebrew-tap
   ```

3. Create the Casks directory:
   ```bash
   mkdir -p Casks
   ```

4. Copy the formula:
   ```bash
   cp /path/to/WorkTimeReminder/homebrew/work-time-reminder.rb Casks/
   ```

5. Create a README.md:
   ```markdown
   # tungtt22/tap
   
   Homebrew tap for my applications.
   
   ## Installation
   
   ```bash
   brew tap tungtt22/tap
   ```
   
   ## Available Casks
   
   | Cask | Description |
   |------|-------------|
   | work-time-reminder | macOS menu bar app for break reminders |
   
   ### Install Work Time Reminder
   
   ```bash
   brew install --cask work-time-reminder
   ```
   ```

6. Commit and push:
   ```bash
   git add .
   git commit -m "Add work-time-reminder cask"
   git push origin main
   ```

## Step 2: Create GitHub Personal Access Token

For automatic updates, create a Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` scope
3. Copy the token

## Step 3: Add Secret to WorkTimeReminder Repository

1. Go to `https://github.com/tungtt22/WorkTimeReminder/settings/secrets/actions`
2. Add new secret:
   - Name: `HOMEBREW_TAP_TOKEN`
   - Value: (paste the token from Step 2)

## Step 4: Create Auto-Update Workflow in Tap Repository

Create `.github/workflows/update-cask.yml` in `homebrew-tap`:

```yaml
name: Update Cask

on:
  repository_dispatch:
    types: [update-cask]

jobs:
  update:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Update cask formula
        run: |
          CASK="${{ github.event.client_payload.cask }}"
          VERSION="${{ github.event.client_payload.version }}"
          SHA256="${{ github.event.client_payload.sha256 }}"
          
          # Update version
          sed -i "s/version \".*\"/version \"$VERSION\"/" "Casks/$CASK.rb"
          
          # Update sha256
          sed -i "s/sha256 \".*\"/sha256 \"$SHA256\"/" "Casks/$CASK.rb"

      - name: Commit and push
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "Update ${{ github.event.client_payload.cask }} to v${{ github.event.client_payload.version }}"
          git push
```

## Step 5: Create a Release

1. Tag a new version:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. The GitHub Actions will:
   - Build the app
   - Create DMG and ZIP files
   - Create a GitHub Release
   - Auto-update the Homebrew tap (if configured)

## Usage

After setup, users can install the app with:

```bash
# Add the tap
brew tap tungtt22/tap

# Install the app
brew install --cask work-time-reminder

# Update the app
brew upgrade --cask work-time-reminder

# Uninstall the app
brew uninstall --cask work-time-reminder
```

## Manual Update

If auto-update is not set up, manually update the tap after each release:

1. Get the SHA256 from the release notes
2. Update `Casks/work-time-reminder.rb`:
   - Change `version` to the new version
   - Change `sha256` to the new hash
3. Commit and push to the tap repository


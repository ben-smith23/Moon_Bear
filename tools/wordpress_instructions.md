# Moon Bear — WordPress Deployment Guide

## Step 1: Install Web Export Templates

1. Open the project in **Godot 4.6**
2. Go to **Editor → Manage Export Templates**
3. Click **Download and Install** (if you haven't already)
4. Wait for the download to complete (~600MB one-time download)

## Step 2: Export for Web

1. Go to **Project → Export…**
2. Select the **Web** preset (already configured)
3. Click **Export Project…**
4. Choose a folder (default: `moon_bear_web/` next to your project)
5. Name the file `index.html` and click **Save**
6. Wait for the export to complete

You'll get these files in your export folder:

```
moon_bear_web/
├── index.html          ← Main page
├── index.wasm          ← Game engine (WebAssembly)
├── index.pck           ← Game data
├── index.js            ← Loader script
├── index.icon.png      ← Favicon
├── index.apple-touch-icon.png
└── index.audio.worklet.js
```

## Step 3: Upload to Your Web Host

### Option A: WordPress Server (FTP/cPanel)
1. Connect to your WordPress server via FTP or cPanel File Manager
2. Navigate to your site's `public_html` directory
3. Create a folder: `games/moon-bear/`
4. Upload **all files** from `moon_bear_web/` into that folder
5. Your game URL will be: `https://yourdomain.com/games/moon-bear/index.html`

### Option B: GitHub Pages (Free)
1. Create a new GitHub repository (e.g., `moon-bear-web`)
2. Upload all files from `moon_bear_web/` to the repo
3. Go to **Settings → Pages → Source → main branch**
4. Your game URL will be: `https://yourusername.github.io/moon-bear-web/index.html`

### Option C: itch.io
1. Go to [itch.io](https://itch.io) and create a new project
2. Upload a `.zip` of the `moon_bear_web/` folder
3. Set "Kind of project" to **HTML**
4. Set viewport to **1280 × 720**
5. Your embed URL will be shown on the project page

## Step 4: Add to WordPress

1. Open the WordPress post/page editor
2. Add a **Custom HTML** block (click `+` → search "Custom HTML")
3. Open `tools/wordpress_embed.html` from your project
4. Copy the entire contents and paste into the Custom HTML block
5. Find this line in the pasted code:
   ```js
   const MOON_BEAR_GAME_URL = "YOUR_GAME_URL/index.html";
   ```
6. Replace `YOUR_GAME_URL/index.html` with your actual game URL from Step 3
   - Example: `"https://yourdomain.com/games/moon-bear/index.html"`
7. Click **Publish** or **Update**

## Step 5: Test It

1. View the published page in your browser
2. You should see the Moon Bear loading screen with a **PLAY GAME** button
3. Click it — the game should load in the iframe
4. Test the **Fullscreen** button in the bottom-right

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Game won't load / blank screen | Check browser console (F12) for errors. Ensure all files were uploaded. |
| "Mixed content" error | Your game URL must use `https://`, not `http://`. |
| CORS errors | If game is on a different domain, add CORS headers to your server config. |
| Very slow loading | Normal for first load (~10-50MB). Subsequent loads use browser cache. |
| No audio | Browsers require user interaction first. The "Click to Play" overlay handles this. |
| Game too small on mobile | The game is designed for desktop. Mobile users see a notice. |

## Server Headers (If Needed)

If your server requires specific headers for `.wasm` files, add this to your `.htaccess`:

```apache
<IfModule mod_headers.c>
  <FilesMatch "\.wasm$">
    Header set Content-Type "application/wasm"
  </FilesMatch>
  <FilesMatch "\.(js|wasm|pck)$">
    Header set Cache-Control "public, max-age=604800"
  </FilesMatch>
</IfModule>
```

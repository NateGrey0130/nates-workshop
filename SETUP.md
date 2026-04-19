# Nate's Workshop — Deployment Guide

## Project Structure

```
nates-apps/
├── index.html                        ← Dashboard landing page
├── apps/
│   └── filament-forge/
│       └── index.html                ← FilamentForge (refactored)
└── functions/
    └── api/
        └── claude.js                 ← Cloudflare Worker proxy (auto-detected)
```

Cloudflare Pages automatically detects the `functions/` directory and deploys those files as serverless Workers. The `claude.js` file becomes an endpoint at `/api/claude` — no extra config needed.

---

## Step 1: Create a GitHub Repo

1. Go to https://github.com/new
2. Name it something like `nates-workshop` (can be private)
3. On your local machine, open a terminal:

```bash
cd /path/to/nates-apps
git init
git add .
git commit -m "Initial commit — FilamentForge + dashboard"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nates-workshop.git
git push -u origin main
```

If you don't have git installed: https://git-scm.com/downloads

---

## Step 2: Set Up Cloudflare Pages

1. Go to https://dash.cloudflare.com and create a free account (or log in)
2. In the sidebar, click **Workers & Pages**
3. Click **Create** → **Pages** → **Connect to Git**
4. Authorize GitHub and select your `nates-workshop` repo
5. Configure the build:
   - **Project name**: `nates-workshop` (this becomes `nates-workshop.pages.dev`)
   - **Production branch**: `main`
   - **Build command**: _(leave blank — no build step needed)_
   - **Build output directory**: _(leave blank or enter `/`)_
6. Click **Save and Deploy**

Your site will be live at `https://nates-workshop.pages.dev` within a minute.

---

## Step 3: Add Your Anthropic API Key as a Secret

This is how the Worker proxy gets your key without it ever being in the code.

1. In Cloudflare dashboard, go to **Workers & Pages** → click your project
2. Go to **Settings** → **Environment variables**
3. Click **Add variable**:
   - **Variable name**: `ANTHROPIC_API_KEY`
   - **Value**: your `sk-ant-...` key
4. Click **Encrypt** (makes it a secret — nobody can read it, not even you after saving)
5. Click **Save**
6. Go to **Deployments** → click the three dots on your latest deploy → **Retry deployment**
   (The secret only takes effect on new deployments)

---

## Step 4: Set Up Cloudflare Access (Login Wall)

This puts an email-based login in front of your entire site. Free for up to 50 users.

### 4a: Enable Zero Trust

1. In Cloudflare dashboard, click **Zero Trust** in the left sidebar
2. If it's your first time, it'll walk you through setup — pick the free plan
3. You'll land on the Zero Trust dashboard

### 4b: Create an Access Application

1. Go to **Access** → **Applications** → **Add an application**
2. Choose **Self-hosted**
3. Configure:
   - **Application name**: `Nate's Workshop`
   - **Session duration**: `24 hours` (or `1 week` for convenience)
   - **Application domain**: `nates-workshop.pages.dev`
     - Leave the path blank (protects the whole site)
4. Click **Next**

### 4c: Create a Policy

1. **Policy name**: `Friends Only`
2. **Action**: `Allow`
3. **Add a rule**:
   - **Selector**: `Emails`
   - **Value**: Add each friend's email, one at a time
   
   Example:
   ```
   nate@example.com
   friend1@gmail.com
   friend2@yahoo.com
   lori@example.com
   ```

4. Click **Next** → **Add application**

### How it works for your friends:

1. They go to `nates-workshop.pages.dev`
2. Cloudflare shows a login screen asking for their email
3. They enter their email → get a one-time code sent to their inbox
4. They enter the code → they're in for 24 hours (or whatever you set)
5. Emails not on your list get blocked — no code is sent

---

## Step 5: Test It

1. Open an incognito window
2. Go to `https://nates-workshop.pages.dev`
3. You should see the Cloudflare Access login screen
4. Enter your email → check for the code → enter it
5. You should see the dashboard → click FilamentForge
6. Select a printer + filament → hit Generate
7. It should work without any API key prompt

---

## Adding More Apps Later

1. Create a new folder under `apps/`:
   ```
   apps/
   ├── filament-forge/
   │   └── index.html
   └── keep-3/
       └── index.html
   ```

2. Add a card to `index.html` (uncomment the Keep 3 card or copy the pattern)

3. If the new app also calls the Anthropic API, point its fetch to `/api/claude` — the same proxy works for all apps.

4. Commit and push:
   ```bash
   git add .
   git commit -m "Add Keep 3 Cut 5"
   git push
   ```
   Cloudflare auto-deploys on push.

---

## Optional: Custom Domain

If you want something like `workshop.naterapert.com`:

1. In Cloudflare Pages → your project → **Custom domains**
2. Click **Set up a custom domain**
3. Enter your domain
4. Cloudflare will tell you what DNS record to add
5. Update your Access Application domain to match

---

## Cost Summary

| Service                  | Cost    | Limits                        |
|--------------------------|---------|-------------------------------|
| Cloudflare Pages         | Free    | Unlimited static sites        |
| Cloudflare Functions     | Free    | 100K requests/day             |
| Cloudflare Access        | Free    | Up to 50 users                |
| GitHub (private repo)    | Free    | Unlimited                     |
| Anthropic API            | Usage   | ~$0.003 per FilamentForge run |

Your only cost is the Anthropic API usage, which for a handful of friends will be pennies.

---

## Troubleshooting

**"API key not configured on server"**
→ You haven't set the `ANTHROPIC_API_KEY` environment variable, or you need to redeploy after setting it.

**FilamentForge loads but Generate does nothing**
→ Open browser console (F12) and check for errors. Most likely the `/api/claude` endpoint isn't resolving — make sure the `functions/` directory is at the project root.

**Cloudflare Access screen doesn't appear**
→ Make sure the application domain exactly matches your Pages URL. Check Zero Trust → Access → Applications.

**Friends don't get the email code**
→ Have them check spam. Also verify their exact email is in your Access policy.

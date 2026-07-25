# Our Card — setup guide (Supabase + Vercel)

A shared ledger for your 3% cash-back card. One-time setup takes about ten minutes, and everything runs on free tiers with no Google account anywhere in the stack. (Fonts are served by Bunny Fonts, a privacy-focused CDN, rather than Google Fonts.)

## Step 1 — Create the database (Supabase)

1. Go to https://supabase.com and sign up (GitHub login or email).
2. Click **New project**. Name it anything, e.g. `ourcard`, pick the region closest to you, and set a database password. (This database password is Supabase admin plumbing — it is *not* the app password you and your partner will use. Let it generate a random one and move on.)
3. Wait a minute for the project to provision, then open the **SQL Editor** from the left sidebar. Paste the entire contents of the `setup.sql` file from this folder and click **Run**. You should see "Success. No rows returned".
4. Go to **Project Settings → API** (on newer projects the section is called **API Keys**). Copy two things: the **Project URL** (looks like `https://abcd1234.supabase.co`) and the **anon** key (newer projects label it the **publishable** key — same job).

## Step 2 — Paste the config

Open `index.html` from this folder in any text editor. Near the top of the `<script>` section you'll find:

```js
const SUPABASE_URL = "PASTE_ME";
const SUPABASE_KEY = "PASTE_ME";
```

Replace the two `"PASTE_ME"` values with the URL and key from step 1.4, and save. (Neither value is a secret — the key is designed to be public. The security comes from the SQL setup and your password.)

## Step 3 — Put it online (Vercel)

The easiest path is the Vercel CLI, which needs Node.js installed (https://nodejs.org, LTS version):

1. Open a terminal in this folder.
2. Run `npx vercel` — it will ask you to log in (free account), then ask a few questions. Accept the defaults (it's a static site, no build step).
3. Run `npx vercel --prod` to push it to your permanent URL, something like `https://ourcard.vercel.app`.

Prefer not to use a terminal? Alternative: put this folder in a GitHub repository, then on https://vercel.com click **Add New → Project**, import the repo, and deploy with default settings. Future updates then deploy automatically when you push.

## Step 4 — Get it on your phones

1. Open the URL in Chrome on your phone.
2. Tap **Create new**, enter your two names and a shared password, and you're in.
3. Send the URL and password to your partner — she taps **Open existing** and enters the password once. Her phone stays unlocked after that.
4. On both phones: Chrome menu (⋮) → **Add to Home screen**. It installs like an app, with an icon and no browser bar.

## How the password works here

Your password isn't stored anywhere — not even hashed in a user table. Instead, it's hashed into a long unguessable ID, and your data lives *at* that ID in the database. The SQL setup seals the table completely: the browser can only go through functions that require the exact ID, so no password means no way to even locate the data, and nothing can be listed or browsed. Practical implications:

- **Pick a decent passphrase.** Something like `mango-bicycle-thursday` beats `1234` — the password is literally the key to the data. Six characters minimum, longer is better.
- **Changing the password** (footer of the app) moves the data to a new ID and locks out every device within seconds — your kill switch if the link and old password both ever leak. Whoever's still legit just enters the new password once.
- **If you both forget the password, the data is unrecoverable through the app.** Write it down somewhere safe. (Worst case, you *can* see the raw data as the project owner in Supabase's Table Editor — the ledger is yours, after all.)

This is solid for keeping strangers and snoops out. It is not bank-grade: entries aren't end-to-end encrypted, so treat it as a grocery ledger, not a vault.

## One quirk of the free tier

Supabase pauses free projects after 7 days with no database activity. Logging purchases resets the timer, so normal use keeps it alive — but if you're both away for a couple of weeks, it may pause. Nothing is lost: the app will show "Can't connect", and restoring takes one click in the Supabase dashboard (available for 90 days after pausing). If that ever gets annoying, a free uptime-monitor pinging the site daily, or Supabase Pro, makes it permanent.

## Updating the site later

Edit the files, then run `npx vercel --prod` again from the folder (or push to GitHub if you used the repo route). Same URL, new version.

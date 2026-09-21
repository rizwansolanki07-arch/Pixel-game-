# Pixel Quest — get it running on Android

Your game, packaged to run **fully offline** with no browser, no internet and no
perchance page. Pick whichever line below fits you.

---

## ⭐ Option 1 — Get a real `.apk` without any PC (3 minutes, GitHub does the build)

You do not need Android Studio. GitHub will compile the APK for you and hand you
the finished file; you can do all of this from your phone's browser.

1. **Download `PixelQuest-Mobile.zip`** (from the chat) to your phone.
2. Make a free account at **github.com** and create a **new repository**
   (any name, e.g. `pixel-quest`; Public or Private both work).
3. In the repository: **Add file → Upload files** → upload `PixelQuest-Mobile.zip`
   → *Commit changes*.
4. In the repository: **Add file → Create new file**. In the filename box type
   exactly `.github/workflows/build-apk.yml` (typing the slashes creates the
   folders). Paste the contents of **`BUILD-APK.yml`** (it is in this zip, and also
   in the chat message). → *Commit changes*.
5. Open the **Actions** tab → tap **Build Pixel Quest APK** → **Run workflow**.
6. Wait ~3 minutes. When it turns green, the finished APK is on your repo's
   **Releases** page (right-hand side of the main page) — tap it and download the
   `.apk`. (It is also inside the run's *Artifacts* zip.)
7. On the phone: tap the downloaded `.apk` → allow *"Install unknown apps"* for
   your browser/file manager → Install. Done: offline game, its own icon.

The APK requests **no permissions at all** — no internet, no storage, no ads,
nothing. Everything (code + artwork + sound) is inside the app.

## Option 2 — Play it instantly, right now

Open **`PixelQuest.html`** (in this zip, or attached separately in the chat) on the
phone. It is the complete game in one file and works in airplane mode. On Android
you may need to open Chrome and type `file:///sdcard/Download/PixelQuest.html`.

## Option 3 — Build it on a PC (Android Studio)

`android/` is a complete project. `File → Open…` → select the folder → wait for the
Gradle sync → `Build → Build Bundle(s) / APK(s) → Build APK(s)`. The APK lands in
`android/app/build/outputs/apk/debug/`. From a terminal: `cd android && ./gradlew assembleDebug`.

## Option 4 — Install it as a web app (no build, no account needed for the files)

Host the **`web-app/`** folder on any HTTPS static host (GitHub Pages, Netlify,
Cloudflare Pages…) keeping the `icons/` subfolder, open that URL in Chrome on
Android, then **⋮ → Install app**. Chrome generates and installs a real Android app
for it (fullscreen, own icon, offline after the first load).

### Notes

- The APK/build needs Android 7.0+ with a reasonably current Android System WebView
  (Chrome/WebView 89+, i.e. 2021 or newer) — every updated phone qualifies.
- Saves are stored in the app's own storage; uninstalling removes them.
- Icons were generated from the game's own pixel art.
- `source/` holds the build script + template that generate `PixelQuest.html`;
  regenerate from the generator workspace with `node src/mobile/build.mjs`.

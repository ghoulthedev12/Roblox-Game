"""Uploads the game's music and sound effects (assets/audio/*.ogg) to Roblox and wires them in.

What it does:
  1. Uploads each .ogg as an Audio asset through Roblox Open Cloud (skips ones already done, so
     you can stop and re-run it any time; progress is kept in assets/audio/uploaded.json).
  2. Writes src/shared/AudioAssets.lua with the id of every track and sound effect.
  3. Rebuilds InstallInStudio.lua so you can paste the update into Studio.
Until you run it the game uses Roblox's built-in sounds for effects and plays no music.

You need a Roblox Open Cloud API key (create.roblox.com > Open Cloud > API Keys):
  - Access permissions: add "Assets" with Read + Write
  - Accepted IP addresses: 0.0.0.0/0 (or your own IP)
The key is typed in when the script asks for it; it is never saved to a file.
Upload the audio as the same owner as the game (your user, or the game's group), otherwise
Roblox won't let the game play it.

Run from the repo folder (Windows: use "py" instead of "python3"):
    python3 tools/upload_audio.py --user-id 123456789
    python3 tools/upload_audio.py --group-id 987654      (if the game belongs to a group)
Only standard Python is needed (no pip installs). The audio itself is made by tools/make_audio.py.
"""
import argparse, getpass, json, os, shutil, subprocess, sys, time, urllib.error, urllib.request, uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO = os.path.join(ROOT, "assets", "audio")
PROGRESS = os.path.join(AUDIO, "uploaded.json")
OUT_LUA = os.path.join(ROOT, "src", "shared", "AudioAssets.lua")
API = os.environ.get("ROBLOX_ASSETS_API", "https://apis.roblox.com/assets/v1/")  # override only for testing

NICE_NAMES = {
    "sfx_dig": "Dig Crunch", "sfx_find": "Artifact Chime", "sfx_click": "Soft Click", "sfx_clang": "Rock Tink",
    "sfx_combo": "Combo Blip",
}


def request(method, url, key, body=None, content_type=None):
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("x-api-key", key)
    req.add_header("User-Agent", "MemeArchaeologist-AudioUploader/1.0")
    if content_type:
        req.add_header("Content-Type", content_type)
    for attempt in range(10):
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                return json.loads(resp.read().decode("utf-8") or "{}")
        except urllib.error.HTTPError as e:
            text = e.read().decode("utf-8", "replace")
            if e.code == 429 or e.code >= 500:  # rate limited or Roblox hiccup: wait and retry
                wait = 5 * (attempt + 1)
                print("   Roblox says wait (%d), retrying in %ds..." % (e.code, wait))
                time.sleep(wait)
                continue
            refused(e.code, text)
        except (urllib.error.URLError, OSError) as e:  # OSError: connection aborted/reset mid-transfer
            wait = min(5 * (attempt + 1), 30)
            print("   Network problem (%s), retrying in %ds..." % (getattr(e, "reason", e), wait))
            time.sleep(wait)
    raise NetworkGaveUp()


class NetworkGaveUp(Exception):
    pass


CURL = shutil.which("curl")  # built into Windows 10/11; handles big uploads better than Python does


def refused(code, text):
    raise SystemExit("\nRoblox refused the upload (%s): %s\n"
                     "Check the API key has Assets Read+Write, its allowed IPs include 0.0.0.0/0,\n"
                     "and the --user-id is yours. (Roblox also limits audio uploads per month.)" % (code, text))


def post_with_curl(url, key, meta, path, name):
    """Uploads with curl. The key goes to curl through stdin, so it never shows up in a command line or file."""
    cmd = [CURL, "-sS", "-X", "POST", url, "-H", "@-", "--max-time", "300",
           "--form-string", "request=" + json.dumps(meta),
           "-F", "fileContent=@%s;type=audio/ogg;filename=%s.ogg" % (path, name),
           "-w", "\n%{http_code}"]
    for attempt in range(10):
        run = subprocess.run(cmd, input="x-api-key: %s\n" % key, capture_output=True, text=True)
        if run.returncode == 0:
            text, _, code = run.stdout.rpartition("\n")
            code = int(code or 0)
            if 200 <= code < 300:
                return json.loads(text or "{}")
            if code == 429 or code >= 500:
                wait = 5 * (attempt + 1)
                print("   Roblox says wait (%d), retrying in %ds..." % (code, wait))
                time.sleep(wait)
                continue
            refused(code, text)
        wait = min(5 * (attempt + 1), 30)
        print("   Network problem (%s), retrying in %ds..." % (run.stderr.strip() or "curl exit %d" % run.returncode, wait))
        time.sleep(wait)
    raise NetworkGaveUp()


def upload(path, name, key, creator):
    title = NICE_NAMES.get(name) or ("Meme Archaeologist World " + name.replace("music_world", "") + " Theme")
    meta = {
        "assetType": "Audio",
        "displayName": title[:50],
        "description": "Meme Archaeologist " + ("sound effect" if name.startswith("sfx") else "background music"),
        "creationContext": {"creator": creator},
    }
    if CURL:
        op = post_with_curl(API + "assets", key, meta, path, name)
    else:
        op = post_with_urllib(meta, path, name, key)
    # uploads finish in the background: poll the operation until Roblox gives us the asset id
    for _ in range(80):
        if op.get("done") and op.get("response", {}).get("assetId"):
            return int(op["response"]["assetId"])
        time.sleep(2)
        op = request("GET", API + op["path"], key)
    raise SystemExit("Upload of %s never finished; run the script again to retry." % name)


def post_with_urllib(meta, path, name, key):
    boundary = uuid.uuid4().hex
    with open(path, "rb") as f:
        data = f.read()
    body = b"".join([
        ("--%s\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n" % boundary).encode(),
        json.dumps(meta).encode(), b"\r\n",
        ("--%s\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"%s.ogg\"\r\n"
         "Content-Type: audio/ogg\r\n\r\n" % (boundary, name)).encode(),
        data, ("\r\n--%s--\r\n" % boundary).encode(),
    ])
    return request("POST", API + "assets", key, body, "multipart/form-data; boundary=" + boundary)


def write_lua(done):
    lines = [
        "-- AudioAssets (ModuleScript in ReplicatedStorage)",
        "-- Written by tools/upload_audio.py: the uploaded id of every music track and sound effect.",
        "-- GameConfig uses these; anything missing falls back to Roblox's built-in sounds (or no music).",
        "",
        "return {",
    ]
    for name in sorted(done):
        lines.append('\t%s = "rbxassetid://%d",' % (name, done[name]))
    lines.append("}")
    with open(OUT_LUA, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    who = parser.add_mutually_exclusive_group(required=True)
    who.add_argument("--user-id", help="your Roblox user id (the number in your profile URL)")
    who.add_argument("--group-id", help="the group id, if the game belongs to a group")
    args = parser.parse_args()
    creator = {"userId": str(args.user_id)} if args.user_id else {"groupId": str(args.group_id)}

    key = os.environ.get("ROBLOX_API_KEY") or getpass.getpass("Paste your Roblox Open Cloud API key (hidden): ").strip()
    if not key:
        raise SystemExit("No API key given.")

    done = {}
    if os.path.exists(PROGRESS):
        with open(PROGRESS, encoding="utf-8") as f:
            done = json.load(f)
    # small sound effects first, then the bigger music tracks
    files = sorted((n for n in os.listdir(AUDIO) if n.endswith(".ogg")),
                   key=lambda n: (not n.startswith("sfx"), os.path.getsize(os.path.join(AUDIO, n)), n))
    todo = [n for n in files if n[:-4] not in done]
    print("%d audio files, %d already uploaded, %d to go." % (len(files), len(files) - len(todo), len(todo)))

    failed = []
    for i, filename in enumerate(todo, 1):
        name = filename[:-4]
        print("[%d/%d] uploading %s (%d KB)..." % (i, len(todo), name, os.path.getsize(os.path.join(AUDIO, filename)) // 1024))
        try:
            asset_id = upload(os.path.join(AUDIO, filename), name, key, creator)
        except NetworkGaveUp:
            print("   Skipping %s for now (the connection keeps getting cut)." % name)
            failed.append(name)
            continue
        done[name] = asset_id
        with open(PROGRESS, "w", encoding="utf-8") as f:
            json.dump(done, f, indent=1, sort_keys=True)
        print("[%d/%d] %s -> %d" % (i, len(todo), name, asset_id))
        time.sleep(1)  # stay well under Roblox's upload rate limit

    if failed:
        print("\n%d file(s) didn't upload: %s" % (len(failed), ", ".join(failed)))
        print("Your PC closed the connection (often antivirus HTTPS/web scanning or a VPN).")
        print("Run the same command again to retry just those; everything else is saved.")
    write_lua(done)
    print("\nWrote %s with %d sounds." % (os.path.relpath(OUT_LUA, ROOT), len(done)))
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "build_installer.py")], cwd=ROOT, check=False)
    print("Done! Paste InstallInStudio.lua into Studio's Command Bar again to put the audio in the game.")
    print("(New audio can take a few minutes to pass Roblox moderation before it plays.)")


if __name__ == "__main__":
    main()

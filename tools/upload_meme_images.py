"""Uploads every meme picture in assets/meme_images/ to Roblox and wires them into the game.

What it does:
  1. Uploads each <ArtifactId>.png as a Decal through Roblox Open Cloud (skips ones already done,
     so you can stop and re-run it any time; progress is kept in assets/meme_images/uploaded.json).
  2. Writes src/shared/ArtifactImages.lua with the picture for every artifact.
  3. Rebuilds InstallInStudio.lua so you can paste the update into Studio.

You need a Roblox Open Cloud API key (create.roblox.com > Open Cloud > API Keys):
  - Access permissions: add "Assets" with Read + Write
  - Accepted IP addresses: 0.0.0.0/0 (or your own IP)
The key is typed in when the script asks for it; it is never saved to a file.

Run from the repo folder (Windows: use "py" instead of "python3"):
    python3 tools/upload_meme_images.py --user-id 123456789
    python3 tools/upload_meme_images.py --group-id 987654      (if the game belongs to a group)
Only standard Python is needed (no pip installs).
"""
import argparse, getpass, json, os, subprocess, sys, time, urllib.error, urllib.request, uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "assets", "meme_images")
PROGRESS = os.path.join(IMAGES, "uploaded.json")
OUT_LUA = os.path.join(ROOT, "src", "shared", "ArtifactImages.lua")
API = os.environ.get("ROBLOX_ASSETS_API", "https://apis.roblox.com/assets/v1/")  # override only for testing


def request(method, url, key, body=None, content_type=None):
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("x-api-key", key)
    if content_type:
        req.add_header("Content-Type", content_type)
    for attempt in range(6):
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return json.loads(resp.read().decode("utf-8") or "{}")
        except urllib.error.HTTPError as e:
            text = e.read().decode("utf-8", "replace")
            if e.code == 429 or e.code >= 500:  # rate limited or Roblox hiccup: wait and retry
                wait = 5 * (attempt + 1)
                print("   Roblox says wait (%d), retrying in %ds..." % (e.code, wait))
                time.sleep(wait)
                continue
            raise SystemExit("\nRoblox refused the request (%d): %s\n"
                             "Check the API key has Assets Read+Write and the right --user-id/--group-id." % (e.code, text))
        except urllib.error.URLError as e:
            print("   Network problem (%s), retrying..." % e.reason)
            time.sleep(3)
    raise SystemExit("Gave up after several retries.")


def upload(path, name, key, creator):
    boundary = uuid.uuid4().hex
    meta = {
        "assetType": "Decal",
        "displayName": ("Meme " + name)[:50],
        "description": "Meme Archaeologist artifact picture",
        "creationContext": {"creator": creator},
    }
    with open(path, "rb") as f:
        png = f.read()
    body = b"".join([
        ("--%s\r\nContent-Disposition: form-data; name=\"request\"\r\n\r\n" % boundary).encode(),
        json.dumps(meta).encode(), b"\r\n",
        ("--%s\r\nContent-Disposition: form-data; name=\"fileContent\"; filename=\"%s.png\"\r\n"
         "Content-Type: image/png\r\n\r\n" % (boundary, name)).encode(),
        png, ("\r\n--%s--\r\n" % boundary).encode(),
    ])
    op = request("POST", API + "assets", key, body, "multipart/form-data; boundary=" + boundary)
    # uploads finish in the background: poll the operation until Roblox gives us the asset id
    for _ in range(60):
        if op.get("done") and op.get("response", {}).get("assetId"):
            return int(op["response"]["assetId"])
        time.sleep(1.5)
        op = request("GET", API + op["path"], key)
    raise SystemExit("Upload of %s never finished; run the script again to retry." % name)


def write_lua(done):
    lines = [
        "-- ArtifactImages (ModuleScript in ReplicatedStorage)",
        "-- Written by tools/upload_meme_images.py: the uploaded meme picture for each artifact.",
        "-- Any artifact without a picture here shows its 3D figure instead (see ArtifactModels).",
        "",
        "return {",
    ]
    for artifact_id in sorted(done):
        lines.append('\t%s = "rbxthumb://type=Asset&id=%d&w=420&h=420",' % (artifact_id, done[artifact_id]))
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
    files = sorted(n for n in os.listdir(IMAGES) if n.endswith(".png"))
    todo = [n for n in files if n[:-4] not in done]
    print("%d pictures, %d already uploaded, %d to go." % (len(files), len(files) - len(todo), len(todo)))

    for i, filename in enumerate(todo, 1):
        artifact_id = filename[:-4]
        asset_id = upload(os.path.join(IMAGES, filename), artifact_id, key, creator)
        done[artifact_id] = asset_id
        with open(PROGRESS, "w", encoding="utf-8") as f:
            json.dump(done, f, indent=1, sort_keys=True)
        print("[%d/%d] %s -> %d" % (i, len(todo), artifact_id, asset_id))
        time.sleep(1)  # stay well under Roblox's upload rate limit

    write_lua(done)
    print("\nWrote %s with %d pictures." % (os.path.relpath(OUT_LUA, ROOT), len(done)))
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "build_installer.py")], cwd=ROOT, check=False)
    print("Done! Paste InstallInStudio.lua into Studio's Command Bar again to put the pictures in the game.")
    print("(New uploads can take a few minutes to pass Roblox moderation before they show up.)")


if __name__ == "__main__":
    main()

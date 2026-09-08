---
name: youtube-transcript
description: Fetch transcripts from YouTube videos for summarization and analysis.
---

# YouTube Transcript

Fetch transcripts from YouTube videos.

## Setup

```bash
cd <base-dir>/scripts   # base-dir shown at the bottom of this skill
npm install
```

## Usage

```bash
node <base-dir>/scripts/transcript.js <video-id-or-url>
```

Accepts video ID or full URL:
- `EBw7gsDPAYQ`
- `https://www.youtube.com/watch?v=EBw7gsDPAYQ`
- `https://youtu.be/EBw7gsDPAYQ`

## Output

Timestamped transcript entries:

```
[0:00] All right. So, I got this UniFi Theta
[0:04] camera painted.
[0:07] I took the camera out, painted it
```

One line per caption segment, offset ascending; a ~22 minute video yields ~460 lines.

## Notes

- Requires the video to have captions/transcripts available
- Works with auto-generated and manual transcripts

## Gotchas

- **`{baseDir}` is not substituted by OpenCode.** Construct the full script path using the "Base directory" value injected at the bottom of this skill.
- **Not all videos have transcripts.** The script will fail if transcripts are disabled by the uploader or the video is private. Check manually on YouTube first if uncertain.
- **Auto-generated transcripts have lower accuracy** for technical terms, proper nouns, and non-English words. Review these manually.
- **Run `npm install` in `scripts/`, never the skill root.** The manifest lives at `scripts/package.json`. Installing from the skill root leaves a stray empty `package-lock.json` plus an orphan `node_modules/` one level above the script, where Node's upward resolution silently uses it. Missing `node_modules` in `scripts/` causes a "module not found" error.
- **`youtube-transcript-plus` is pinned to an exact version (`1.2.0`), not a `^` range.** 1.0.x reported `offset` in milliseconds; 1.2.0 reports it in **seconds**. A floating range let a minor release silently change units and print `[0:00]` for every line. Verify `offset`'s scale against a long video before bumping the pin.
- **Output is large** — a 22-minute video is ~460 lines and will be truncated by most agent harnesses. Pipe through `head`/`sed`, or grep for the section you need, rather than capturing it all.

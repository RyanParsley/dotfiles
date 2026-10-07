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
node <base-dir>/scripts/transcript.js <video-id-or-url> [lang]
```

Accepts video ID or full URL, optional language code (default: `en`):
- `EBw7gsDPAYQ`
- `https://www.youtube.com/watch?v=EBw7gsDPAYQ`
- `https://youtu.be/EBw7gsDPAYQ`
- `node transcript.js EBw7gsDPAYQ en`
- `node transcript.js EBw7gsDPAYQ fr`

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
- **Defaults to English (`lang: 'en'`)** — avoids grabbing first-available track (often non-English auto-captions)

## Gotchas

- **`{baseDir}` is not substituted by OpenCode.** Construct the full script path using the "Base directory" value injected at the bottom of this skill.
- **Not all videos have transcripts.** The script will fail if transcripts are disabled by the uploader or the video is private. Check manually on YouTube first if uncertain.
- **Auto-generated transcripts have lower accuracy** for technical terms, proper nouns, and non-English words. Review these manually.
- **Run `npm install` in `scripts/`, never the skill root.** The manifest lives at `scripts/package.json`. Installing from the skill root leaves a stray empty `package-lock.json` plus an orphan `node_modules/` one level above the script, where Node's upward resolution silently uses it. Missing `node_modules` in `scripts/` causes a "module not found" error.
- **`youtube-transcript-plus` is pinned to an exact version (`1.2.0`), not a `^` range.** 1.0.x reported `offset` in milliseconds; 1.2.0 reports it in **seconds**. A floating range let a minor release silently change units and print `[0:00]` for every line. Verify `offset`'s scale against a long video before bumping the pin.
- **Output is large** — a 22-minute video is ~460 lines and will be truncated by most agent harnesses. Pipe through `head`/`sed`, or grep for the section you need, rather than capturing it all.

Base directory for this skill: /Users/ryan/.agents/skills/youtube-transcript
Relative paths in this skill (e.g., scripts/, reference/) are relative to this base directory.
Note: file list is sampled.

<skill_files>
<file>/Users/ryan/.agents/skills/youtube-transcript/scripts/package.json</file>
<file>/Users/ryan/.agents/skills/youtube-transcript/scripts/package-lock.json</file>
<file>/Users/ryan/.agents/skills/youtube-transcript/scripts/transcript.js</file>
<file>/Users/ryan/.agents/skills/youtube-transcript/.gitignore</file>
</skill_files>
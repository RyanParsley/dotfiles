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
[0:15] I took the camera out, painted it
[1:23] And here's the final result
```

## Notes

- Requires the video to have captions/transcripts available
- Works with auto-generated and manual transcripts

## Gotchas

- **`{baseDir}` is not substituted by OpenCode.** Construct the full script path using the "Base directory" value injected at the bottom of this skill.
- **Not all videos have transcripts.** The script will fail if transcripts are disabled by the uploader or the video is private. Check manually on YouTube first if uncertain.
- **Auto-generated transcripts have lower accuracy** for technical terms, proper nouns, and non-English words. Review these manually.
- **Run `npm install` in the skill directory before first use.** Missing `node_modules` causes a "module not found" error.

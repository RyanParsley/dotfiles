---
name: transcribe
description: Speech-to-text transcription using Groq Whisper API. Supports m4a, mp3, wav, ogg, flac, webm.
---

# Transcribe

Speech-to-text using Groq Whisper API.

## Setup

The script needs `GROQ_API_KEY` environment variable. Check if already set:
```bash
echo $GROQ_API_KEY
```

If not set, guide the user through setup:
1. Ask if they have a Groq API key
2. If not, have them sign up at https://console.groq.com/ and create an API key
3. Have them add to their shell profile (~/.zshrc or ~/.bashrc):
   ```bash
   export GROQ_API_KEY="<their-api-key>"
   ```
4. Then run `source ~/.zshrc` (or restart terminal)

## Usage

```bash
bash <base-dir>/scripts/transcribe.sh <audio-file>
# <base-dir> is shown at the bottom of this skill
```

## Supported Formats

- m4a, mp3, wav, ogg, flac, webm
- Max file size: 25MB

## Output

Returns plain text transcription with punctuation and proper capitalization to stdout.

## Gotchas

- **`{baseDir}` is not substituted by OpenCode.** Construct the full script path using the "Base directory" value injected at the bottom of this skill.
- **Max file size is 25MB.** Files larger than this are rejected with a 413 error — split or compress the audio first.
- **`GROQ_API_KEY` must be in the current shell's environment.** Running from a new terminal session may not have it if only added to `.zshrc` without sourcing. Check with `echo $GROQ_API_KEY`.
- **Technical terms, acronyms, and proper nouns have lower accuracy** in auto-generated transcription. Review these manually.

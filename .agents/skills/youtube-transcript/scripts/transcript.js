#!/usr/bin/env node

import { YoutubeTranscript } from 'youtube-transcript-plus';

const videoId = process.argv[2];
const lang = process.argv[3] || 'en';

if (!videoId) {
  console.error('Usage: transcript.js <video-id-or-url> [lang]');
  console.error('Example: transcript.js EBw7gsDPAYQ');
  console.error('Example: transcript.js https://www.youtube.com/watch?v=EBw7gsDPAYQ en');
  console.error('Example: transcript.js EBw7gsDPAYQ fr');
  process.exit(1);
}

// Extract video ID if full URL is provided
let extractedId = videoId;
if (videoId.includes('youtube.com') || videoId.includes('youtu.be')) {
  const match = videoId.match(/(?:v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/);
  if (match) {
    extractedId = match[1];
  }
}

try {
  const transcript = await YoutubeTranscript.fetchTranscript(extractedId, { lang });
  
  for (const entry of transcript) {
    const timestamp = formatTimestamp(entry.offset);
    console.log(`[${timestamp}] ${entry.text}`);
  }
} catch (error) {
  console.error('Error fetching transcript:', error.message);
  process.exit(1);
}

function formatTimestamp(seconds) {
  seconds = Math.max(0, Math.floor(Number(seconds) || 0));
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  
  if (h > 0) {
    return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }
  return `${m}:${s.toString().padStart(2, '0')}`;
}
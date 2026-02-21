# Audio Guide

This document explains how to add and replace pronunciation audio in Echoes of Us.

## Playback Behavior
1. The app checks `Resources/audio_manifest.json` for cue metadata.
2. It tries to play the matching local `.m4a` clip.
3. If the clip file is missing or fails to decode, it uses helper narration fallback (offline).

## Required Folders
- `Resources/Audio/Phrases/`
- `Resources/Audio/Missions/`

## Naming Rules
- Phrase clip: `<phrase_id>.m4a`
  - Example: `Resources/Audio/Phrases/nv_1.m4a`
- Mission prompt clip: `<mission_id>_prompt.m4a`
  - Example: `Resources/Audio/Missions/mission_1_prompt.m4a`
- Mission option clip: `<mission_id>_option_<index>.m4a`
  - Example: `Resources/Audio/Missions/mission_1_option_0.m4a`

## Encoding Recommendation
- Codec: AAC LC
- Sample rate: 22.05 kHz
- Channels: mono
- Bitrate: 32 kbps

## Responsible Audio Notes
- Native recordings should be preferred whenever possible.
- Helper narration must remain clearly labeled as non-authoritative.
- Do not represent fallback narration as native-speaker output.

## Clip Import Checklist
1. Add clip files to the correct folder using exact names.
2. Confirm `audio_manifest.json` includes matching cue keys and file paths.
3. Build and test each major surface:
   - Learn (Guided Deck + Library)
   - Mastery Sprint
   - Mission prompt and mission options
   - Learning Studio
4. Verify fallback still works for intentionally missing files.

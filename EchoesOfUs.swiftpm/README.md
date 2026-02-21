# Echoes of Us (v3)

Echoes of Us is an offline-first iOS app playground for the Swift Student Challenge focused on education, inclusivity, and AI equity for low-resource languages.

## What v3 Adds
1. Dashboard-first home with multiple entry points.
2. Guided flow with back navigation and completed-step jump.
3. Mastery Sprint with review/edit before final grading.
4. Full offline audio pipeline (clips-first + helper fallback).
5. De-cluttered intro and improved product clarity.

## App Structure
### Routes
- `dashboard`: Product home with quick actions.
- `guided`: Official judged flow.
- `studio`: Optional deep-dive Learning Studio.

### Guided Flow (Judged Path)
1. Intro
2. Inclusion Setup
3. Learn (Guided Deck)
4. Mastery Sprint
5. Mission Scenarios
6. AI Fairness Lab
7. Impact Summary

## Navigation Model
- Launch lands on Dashboard.
- Guided flow always shows:
  - `Back`
  - `Home`
  - step rail with lock/unlock indicators
- Step-jump rule in judged mode:
  - can jump to current or completed steps only
  - forward locked steps remain unavailable

## Audio Architecture
- Local clip playback: `AVAudioPlayer`
- Fallback playback: `AVSpeechSynthesizer` (helper narration)
- Strict labeling in UI:
  - `Native clip`
  - `Helper narration (auto-generated)`
- Fully offline; no network usage.

### Audio Manifest
`Resources/audio_manifest.json` includes complete cue coverage for:
- All phrase cards
- All mission prompts
- All mission options

If a referenced clip file is missing, the app gracefully falls back to helper narration.

## Clip Naming Convention
- Phrase: `Resources/Audio/Phrases/<phrase_id>.m4a`
- Mission prompt: `Resources/Audio/Missions/<mission_id>_prompt.m4a`
- Mission option: `Resources/Audio/Missions/<mission_id>_option_<index>.m4a`

## Fairness Simulation
- `lowResourceScore = min(82, 54 + contributions * 0.28)`
- `highResourceScore = min(96, 92 + contributions * 0.05)`

## Key Files
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/App/EchoesOfUsApp.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/Core/Models.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/Core/AppState.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/Core/Services/AudioPlaybackService.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/Core/Services/LocalAudioPlaybackService.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Sources/Features/Home/HomeDashboardView.swift`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/Resources/audio_manifest.json`
- `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm/AUDIO_GUIDE.md`

## Run
1. Open `/Users/Aadi/Desktop/playground/swiftchallenge/EchoesOfUs.swiftpm` in Xcode.
2. Select scheme **Echoes of Us**.
3. Choose iPhone/iPad simulator and run.

## Submission Notes
- Zip the entire `.swiftpm` package.
- Keep final ZIP below 25 MB.
- App functions completely offline.

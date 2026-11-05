# Audio

- `glide-elevenlabs-sustain.wav`: 0.57-second seamless water loop, edited from an ElevenLabs sound generation. It follows actual movement, at fixed pitch, with short attack/release envelopes.
- `mistbound-harbor-bgm.wav`: original 48-second, 90 BPM, 3/4 miniature. Reproduce with `python3 tools/compose_harbor_bgm.py`; no external samples.
- `chart.wav`, `dock.wav`, `wood.wav`, `impact.wav`, `ui.wav`: locally synthesized event cues.

`scripts/sea_audio.gd` handles looping, pause, mute, and reset. No API credentials or online services are needed to build or play.

# EpochSonar

**DEVELOPMENT VERSION - NOT FUNCTIONAL**

This addon is incomplete and does not work as intended. Do not use in production gameplay.

## Description

Audio alert addon for World of Warcraft 3.3.5 (WotLK). Intended to play sounds when approaching previously discovered gathering nodes.

## Status

Version 2.0.0-dev - Active development, core functionality incomplete.

## Installation

1. Copy EpochSonar folder to WoW/Interface/AddOns/
2. Restart WoW or /reload
3. Enable in addon menu

## Commands

- /es - Toggle alerts
- /es sound - Toggle audio
- /es test - Play test sound
- /es debug - Debug output
- /es reset - Clear data

## Current Implementation

- Event-based node learning via LOOT_OPENED
- Proximity detection using map coordinates
- Audio alerts via MapPing.wav
- 2-second alert cooldown
- Zone-based node storage

## Requirements

- Interface version 30300
- Active minimap tracking (Find Minerals/Herbs)

## Known Issues

- Node detection unreliable
- Audio alerts may not trigger
- Learning system incomplete
- Range detection experimental

## Technical Notes

- Saved variables: EpochSonarDB
- Alert range: 0.08 map units
- Detection method: Player-driven learning
- File structure: Single .lua file

## Development Status

This is a development build. Functionality is incomplete and unstable.
# 🚨 **DEVELOPMENT VERSION - NOT READY FOR USE** 🚨

## **⚠️ WARNING: THIS ADDON IS STILL IN ACTIVE DEVELOPMENT ⚠️**

**This addon is currently being developed and WILL NOT WORK as intended. It is NOT ready for regular use. Features may be broken, incomplete, or subject to major changes. Use at your own risk.**

---

# EpochSonar - Audio Alert Addon

A simple audio alert addon for gathering nodes in World of Warcraft: Wrath of the Lich King (3.3.5).

## Current Status

**Version 2.0.0-dev** - Audio alert system with node learning functionality

## Features (In Development)

- **Audio Alerts**: Plays a sound when you get close to learned gathering nodes
- **Node Learning**: Records locations when you loot gathering nodes 
- **Simple Commands**: Basic toggle and configuration commands
- **Persistent Memory**: Remembers node locations across sessions

## Installation

1. Copy the `EpochSonar` folder to your WoW AddOns directory:
   - Windows: `World of Warcraft\Interface\AddOns\`
   - Mac: `Applications/World of Warcraft/Interface/AddOns/`

2. Restart World of Warcraft or reload your UI (`/reload`)

3. Enable the addon in the AddOns menu at character selection

## Commands

- `/epochsonar` or `/es` - Enable/disable audio alerts
- `/es sound` - Toggle sound on/off  
- `/es test` - Play test sound
- `/es debug` - Show debug information (for development)
- `/es reset` - Reset all learned node data

## How It's Supposed to Work (When Complete)

1. **Learning Phase**: Target and loot gathering nodes (mining veins, herbs, etc.)
2. **Audio Alerts**: When you get close to previously learned node locations, hear an audio ping
3. **Cooldown**: Alerts have a 2-second cooldown to prevent spam

## Known Issues

- **Node detection may not work reliably**
- **Audio alerts may not trigger correctly**  
- **Learning system needs refinement**
- **Range detection requires calibration**
- **Many features are experimental**

## Technical Details

- **Interface Version**: 30300 (WotLK 3.3.5)
- **Alert Range**: 0.08 map coordinate units (experimental)

## Development Notes

This addon is being actively developed. The current approach uses:
- Event-driven node learning (LOOT_OPENED events)
- Proximity-based audio alerts
- Simple coordinate-based distance calculations


## Version History

- **v2.0.0-dev**: Complete rewrite as audio alert system (IN DEVELOPMENT)
- **v1.0.0**: Initial visual overlay version (deprecated)

## Credits

Created for the Epoch WoW community. Built specifically for WotLK 3.3.5 private servers.

---

# **🚨 REMINDER: THIS IS A DEVELOPMENT VERSION 🚨**

**This addon is not finished and may not work correctly. Please wait for a stable release before using in normal gameplay.**
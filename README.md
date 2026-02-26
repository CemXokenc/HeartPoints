# 💗 HeartPoints

A lightweight World of Warcraft addon that replaces the default combo point and soul shard displays with custom heart icons.

**Supported classes:**
- 🐱 **Druid** — hearts appear in Cat Form, tracking combo points
- 🟣 **Warlock** — hearts always visible, tracking soul shards (all specs)

---

## Features

- Custom heart textures replace Blizzard's native power display
- Glow/bloom layer behind each heart for a polished look
- Class-aware: only activates for Druid and Warlock, zero overhead for other classes
- Druid: hearts shown only in Cat Form, hidden otherwise
- Warlock: TotemFrame (guardians/pets) repositioned to avoid overlap with hearts
- Druid: TotemFrame shifts down automatically when entering Cat Form and restores on exit
- All guardians (Grimoire of Sacrifice, Infernal, Tyrant, Wild Imps, Darkglare, etc.) correctly follow the repositioned TotemFrame
- Survives zone changes, reloads, and guardian spawns

---

## Installation

1. Download or clone this repository
2. Copy the `HeartPoints` folder into your addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/HeartPoints/
   ```
3. Make sure the folder contains:
   ```
   HeartPoints/
   ├── HeartPoints.toc
   ├── HeartPoints.lua
   ├── heart.tga        ← your active heart texture
   └── heart_grey.tga   ← your inactive heart texture
   ```
4. Enable the addon in the character select screen

---

## Configuration

All visual settings are in the `CFG` table at the top of `HeartPoints.lua`:

| Setting | Description |
|---|---|
| `heartSize` | Heart icon size in pixels |
| `heartSpacing` | Distance between heart centers |
| `heartOffsetX/Y` | Position of the heart bar relative to PlayerFrame |
| `glowEnabled` | Enable/disable the glow layer |
| `glowMultiplier` | Glow size relative to heart size |
| `glowAlpha` | Glow opacity |
| `druidActiveColor` | Active heart color for Druid |
| `lockActiveColor` | Active heart color for Warlock |
| `inactiveColor` | Inactive heart color (both classes) |
| `druidTotemShiftY` | How far down to move TotemFrame in Cat Form |
| `warlockTotemShiftX/Y` | TotemFrame offset for Warlock |

---

## Compatibility

- WoW Retail (The War Within / Midnight)
- Does not conflict with ElvUI, SUF, or other unit frame replacements
- No dependencies

---

## License

MIT

# Changelog

## 1.3.8
- Reverted the 1.3.7 HUD change: the center HUD is sent every tick again. Sending it only on change or once a second froze the new-mode countdown (stuck at "10 seconds"), because the client does not refresh the text of an already-visible panel from sparse sends.

## 1.3.7
- The center HUD (custom mode message and countdown) is sent when its text changes or once a second, instead of to every player on every tick. Each send makes the client re-layout the panel, so this is lighter on players' FPS.

## 1.3.6
- First release from the mrc4tt/CS2-Deathmatch fork (fshost build), identical to NockyCZ/CS2-Deathmatch 1.3.6.
- Built against CounterStrikeSharp 1.0.407 (mrc4tt/CounterStrikeSharp); release zip without .pdb files.

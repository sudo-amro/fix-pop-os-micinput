# 🎧 Fix: Pop!_OS / PipeWire Audio & Microphone Crash Recovery

This guide provides a step-by-step solution for fixing heavy audio distortion (alternating good sound, loud crackling, poor quality) and recovering from a total audio system crash (missing input/output devices) under Pop!_OS using PipeWire.

## 🔴 The Problem
1. **Audio Loop of Death:** The sound quality constantly cycles between good audio, heavy crackling/scratching noises, and extremely low-quality output/input.
2. **Total Audio Loss:** After attempting to restart configuration files, all input and output devices disappear from the Pop!_OS control panel, even though PipeWire shows as active.
---
## Quick Fix
## 🚀 Quick Automated Fix

If your microphone or headphones are acting up, cutting out, or missing completely from your settings panel, you can use the automated script included in this repository to repair the audio stack instantly.

### One-Line Instant Execution (No Cloning Required)

You can download and run the script instantly with a single terminal command. This safe method temporarily downloads the script, runs the fix, and cleans up after itself so your desktop stays clean.

```bash
curl -sSL https://raw.githubusercontent.com/sudo-amro/fix-pop-os-micinput/refs/heads/main/audio-fix.sh -o audio-fix.sh && chmod +x audio-fix.sh && ./audio-fix.sh && rm audio-fix.sh
```

*Note: Since the script reloads kernel-level audio drivers, it will prompt you for your `sudo` password during execution.*

---

## 🛠️ Step 1: Nuclear Reset (Recover Missing Input/Output Devices)
If your audio devices disappeared completely from the settings menu, the session manager (`WirePlumber`) has locked up or cached corrupted device states. 

Run these commands in your terminal to wipe the broken state caches and force a clean hardware re-discovery:

```bash
# 1. Clear all temporary PipeWire and WirePlumber state caches
rm -rf ~/.config/pipewire ~/.config/wireplumber ~/.local/state/wireplumber/ ~/.local/state/pipewire/

# 2. Force reload the kernel-level ALSA sound driver
sudo alsa force-reload

# 3. Reload daemon configurations and restart the entire audio stack in correct order
systemctl --user daemon-reload
systemctl --user restart wireplumber pipewire-pulse pipewire
```

---

## 🎤 Step 2: Unmute and Force-Activate the Microphone
If your output (speakers/headphones) works again but the microphone is still missing or silent, Pop!_OS likely muted the channel during the crash.

### Option A: Quick Terminal Unmute
Force the default system audio source to 100% volume and unmute it:
```bash
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 100%
```

### Option B: Hardware Level Check via AlsaMixer
If the terminal command doesn't work, check the hardware mixer:
1. Open terminal and type: `alsamixer`
2. Press **`F6`** to select your actual sound card (e.g., *Realtek*, *Intel*, or your USB Device).
3. Press **`F4`** to switch to the **Capture (Input)** view.
4. Use arrow keys to navigate to `Capture` or `Mic`. If you see **`MM`** at the bottom, it is muted. Press **`M`** or **Spacebar** to change it to **`CAPTUR`** (enabled) and push the volume up.
5. Press `ESC` to exit.

### Option C: GUI Route via PulseAudio Volume Control
The native Pop!_OS settings app sometimes bugs out. Use the advanced volume control utility instead:
```bash
# Install the advanced controller
sudo apt install pavucontrol

# Launch the app
pavucontrol
```
* Go to the **Input Devices** tab.
* Look for your microphone and check if the blue volume bar moves when you speak.
* Click the **green checkmark icon** ("Set as fallback") on the far right to force Pop!_OS to use this microphone globally.

---

## 🔍 Why did this happen?
* **Buffer Underruns:** The dynamic buffer configuration in modern Linux audio can fall out of sync with certain USB/3.5mm sound chips, creating a vicious cycle of crackling while trying to resync.
* **Locked States:** When an audio server process is killed or modified incorrectly, `WirePlumber` safely locks the hardware routing, which looks like "deleted devices" in the graphical user interface. Wiping the state directories (`~/.local/state/*`) completely resets this behavior without risking hardware damage.

---
License: MIT - Feel free to share this fix with fellow Linux users! 🐧

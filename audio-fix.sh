#!/bin/bash

# Colors for a clean and readable terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0;0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   Pop!_OS / PipeWire Audio Auto-Fix Script       ${NC}"
echo -e "${BLUE}==================================================${NC}"

# Step 1: Clear corrupted configuration and state caches
echo -e "\n${YELLOW}[1/5] Clearing corrupted audio server caches...${NC}"
rm -rf ~/.config/pipewire ~/.config/wireplumber ~/.local/state/wireplumber/ ~/.local/state/pipewire/
echo -e "${GREEN}✔ Caches successfully cleared.${NC}"

# Step 2: Reset the ALSA kernel-level driver
echo -e "\n${YELLOW}[2/5] Resetting ALSA hardware drivers (Sudo password required)...${NC}"
if sudo alsa force-reload; then
    echo -e "${GREEN}✔ Soundcard successfully re-initialized.${NC}"
else
    echo -e "${RED}⚠ ALSA reset failed or skipped. Continuing anyway...${NC}"
fi

# Step 3: Restart user-space audio daemons
echo -e "\n${YELLOW}[3/5] Restarting PipeWire and WirePlumber services...${NC}"
systemctl --user daemon-reload
systemctl --user restart wireplumber pipewire-pulse pipewire
sleep 2 # Brief pause to allow services to initialize completely

# Step 4: Check and install Pavucontrol if missing
echo -e "\n${YELLOW}[4/5] Checking for advanced volume control utility (pavucontrol)...${NC}"
if dpkg -l | grep -q pavucontrol; then
    echo -e "${GREEN}✔ pavucontrol is already installed.${NC}"
else
    echo -e "${YELLOW}pavucontrol is missing. Installing it now...${NC}"
    sudo apt update && sudo apt install -y pavucontrol
fi

# Step 5: Unmute and maximize default microphone volume
echo -e "\n${YELLOW}[5/5] Activating and maximizing default microphone channel...${NC}"
if wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 100% 2>/dev/null; then
    echo -e "${GREEN}✔ Microphone unmuted and set to 100% volume.${NC}"
else
    echo -e "${YELLOW}⚠ Default microphone could not be reached via wpctl.${NC}"
    echo -e "Please verify your input devices manually using pavucontrol.${NC}"
fi

# Final Service Verification
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${BLUE}               SERVICE STATUS CHECK               ${NC}"
echo -e "${BLUE}==================================================${NC}"

PIPEWIRE_STATUS=$(systemctl --user is-active pipewire)
WIREPLUMBER_STATUS=$(systemctl --user is-active wireplumber)

if [ "$PIPEWIRE_STATUS" = "active" ]; then
    echo -e "PipeWire:    ${GREEN}RUNNING (Active)${NC}"
else
    echo -e "PipeWire:    ${RED}FAILED (Please reboot your PC)${NC}"
fi

if [ "$WIREPLUMBER_STATUS" = "active" ]; then
    echo -e "WirePlumber: ${GREEN}RUNNING (Active)${NC}"
else
    echo -e "WirePlumber: ${RED}FAILED (Please reboot your PC)${NC}"
fi

echo -e "\n${GREEN}🎉 Done! Test your headset and microphone now.${NC}"
echo -e "${YELLOW}Note: If devices are still missing, open the Pop!_OS Control Panel or pavucontrol.${NC}\n"

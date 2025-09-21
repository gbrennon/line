# Line MIDI Sequencer - Docker & DAW Integration Guide

## Overview

This guide explains how to run the `line` MIDI sequencer in Docker and integrate it with Digital Audio Workstations (DAWs) like Reaper, Ableton Live, and other free DAWs.

## Prerequisites

- Docker and Docker Compose installed
- MIDI interface or virtual MIDI ports
- DAW software (Reaper, Ardour, LMMS, etc.)

## Docker Setup

### 1. Build and Run with Docker Compose

```bash
# Basic setup (ALSA MIDI)
docker-compose up line

# With JACK support
docker-compose --profile jack up line-with-jack
```

### 2. Manual Docker Build

```bash
# Build the image
docker build -t line-sequencer .

# Run with MIDI device access
docker run -it --rm \
  --privileged \
  --network host \
  -v /dev/snd:/dev/snd \
  -v /dev/midi:/dev/midi:rw \
  -v $(pwd)/saved_phrases:/app/saved_phrases \
  --group-add audio \
  line-sequencer
```

## DAW Integration

### Reaper (Free 60-day trial, $60 license)

1. **Setup Virtual MIDI Ports:**
   ```bash
   # Install virtual MIDI on Linux
   sudo modprobe snd-virmidi midi_devs=4
   
   # Or use a2jmidid for ALSA-JACK bridge
   a2jmidid -e &
   ```

2. **Configure Reaper:**
   - Go to Options → Preferences → Audio → MIDI Devices
   - Enable the virtual MIDI input ports
   - Create a new track and set input to the MIDI port line is using

3. **Start line in Docker:**
   ```bash
   docker-compose up line
   ```

4. **In line, set MIDI channel:**
   ```
   line> ch0  # Set to MIDI channel 0
   line> c4 e4 g4  # Play a C major chord
   ```

### Ardour (Free/Open Source)

1. **Start JACK:**
   ```bash
   jackd -d alsa -d hw:0 -r 44100 -p 1024 -n 2
   ```

2. **Run line with JACK profile:**
   ```bash
   docker-compose --profile jack up line-with-jack
   ```

3. **Configure Ardour:**
   - Create a new MIDI track
   - Connect line's MIDI output to Ardour's MIDI input using QJackCtl or Catia

### LMMS (Free/Open Source)

1. **Setup:**
   ```bash
   # Ensure ALSA MIDI is available
   aconnect -l  # List MIDI connections
   ```

2. **Configure LMMS:**
   - Go to Edit → Settings → MIDI
   - Enable ALSA MIDI interface
   - Create an instrument and set it to receive from the MIDI port

3. **Run line:**
   ```bash
   docker-compose up line
   ```

### Bitwig Studio (Free tier available)

1. **Configure Bitwig:**
   - Go to Settings → Controllers
   - Add Generic MIDI Keyboard
   - Set input to the MIDI port line uses

2. **Use Ableton Link sync:**
   - Enable Link in Bitwig (if available)
   - Line automatically connects via Ableton Link protocol

## MIDI Routing Options

### Option 1: Virtual MIDI Ports (Linux)

```bash
# Create virtual MIDI ports
sudo modprobe snd-virmidi midi_devs=4

# List available MIDI ports
aconnect -l

# Connect line output to DAW input
aconnect 20:0 128:0  # Example connection
```

### Option 2: JACK MIDI

```bash
# Start JACK
jackd -d alsa -d hw:0 -r 44100 -p 1024

# Use JACK-aware applications
docker-compose --profile jack up line-with-jack
```

### Option 3: Network MIDI (rtpMIDI/ipMIDI)

For wireless MIDI connections between containers and DAWs.

## Line Commands for DAW Integration

### Basic Commands
```
line> ls          # List commands
line> ch0         # Set MIDI channel 0
line> bpm120      # Set tempo to 120 BPM
line> c4 e4 g4    # Play C major chord
line> c4 - e4 -   # Play with rests
```

### Synchronization
```
line> bpm120      # Match DAW tempo
line> /2          # Set phrase duration (2 bars)
```

### Pattern Manipulation
```
line> r           # Reverse pattern
line> s           # Scramble pattern
line> x           # Cross-scramble
line> *4          # Repeat pattern 4 times
```

### Save/Load Patterns
```
line> sp          # Save current phrase
line> sp0         # Save to slot 0
line> :0          # Load from slot 0
line> sf mytrack  # Save to file
line> lf mytrack  # Load from file
```

## Troubleshooting

### MIDI Not Working
1. Check MIDI permissions:
   ```bash
   ls -la /dev/midi*
   groups $USER  # Ensure user is in audio group
   ```

2. List MIDI connections:
   ```bash
   aconnect -l
   ```

3. Test MIDI output:
   ```bash
   # Send test MIDI note
   echo -ne '\x90\x40\x7f' > /dev/midi1
   ```

### Docker Issues
1. Ensure privileged mode and device access
2. Check audio group membership
3. Verify MIDI device mounting

### Sync Issues
1. Ensure network_mode: host for Ableton Link
2. Check firewall settings for Link protocol
3. Verify DAW Link support

## Performance Tips

1. **Low Latency:** Use JACK for professional audio work
2. **CPU Usage:** Monitor container resources with `docker stats`
3. **MIDI Timing:** Adjust latency with `lt` command in line
4. **Buffer Sizes:** Optimize JACK buffer sizes for your system

## Example Workflow

1. Start your DAW
2. Configure MIDI routing
3. Launch line in Docker:
   ```bash
   docker-compose up line
   ```
4. Set up basic pattern:
   ```
   line> ch0
   line> bpm120
   line> c4 e4 g4 c5
   ```
5. Record in DAW or use as live input
6. Manipulate patterns in real-time:
   ```
   line> r    # Reverse
   line> s    # Scramble
   line> *2   # Double
   ```

This setup allows you to use line as a powerful live coding MIDI sequencer with any DAW that supports MIDI input.

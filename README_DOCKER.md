# Line MIDI Sequencer - Docker Setup

## Quick Start

1. **Setup and Build:**
   ```bash
   ./run-line.sh setup    # Setup MIDI environment
   ./run-line.sh build    # Build Docker image
   ```

2. **Run with ALSA MIDI:**
   ```bash
   ./run-line.sh alsa
   ```

3. **Run with JACK MIDI:**
   ```bash
   ./run-line.sh jack
   ```

## What's Included

- **Dockerfile**: Multi-stage build with all dependencies
- **docker-compose.yml**: Service definitions for ALSA and JACK modes
- **run-line.sh**: Convenient wrapper script with setup utilities
- **DOCKER_DAW_GUIDE.md**: Comprehensive DAW integration guide

## Docker Features

### MIDI Device Access
- Full access to `/dev/snd` and `/dev/midi` devices
- Proper audio group permissions
- Support for both ALSA and JACK MIDI

### Network Synchronization
- Host networking for Ableton Link protocol
- Automatic discovery of Link-enabled applications
- Low-latency synchronization with DAWs

### Persistent Storage
- `saved_phrases/` directory mounted as volume
- Phrase files persist between container runs
- Easy backup and sharing of musical patterns

## Supported DAWs

### Free/Open Source
- **Ardour**: Professional DAW with full JACK support
- **LMMS**: Easy-to-use with built-in instruments
- **Qtractor**: Lightweight MIDI/Audio sequencer
- **MusE**: Traditional MIDI sequencer
- **Rosegarden**: Notation and MIDI sequencing

### Commercial (with free tiers/trials)
- **Reaper**: 60-day free trial, $60 license
- **Bitwig Studio**: Free 8-track version available
- **Ableton Live**: Free Lite version (with Link support)

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   Line Docker   │    │ MIDI Routing │    │    DAW      │
│   Container     │───▶│   (ALSA/     │───▶│  (Reaper,   │
│                 │    │    JACK)     │    │   Ardour,   │
│                 │    │              │    │   LMMS...)  │
└─────────────────┘    └──────────────┘    └─────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌──────────────┐
│ Ableton Link    │    │ Virtual MIDI │
│ Sync Network    │    │   Devices    │
└─────────────────┘    └──────────────┘
```

## Performance Considerations

### Latency Optimization
- Use JACK for professional audio work
- Adjust buffer sizes based on your system
- Monitor CPU usage with `docker stats`

### MIDI Timing
- Line includes built-in latency compensation
- Adjust with `lt<value>` command in line
- Test timing with your specific DAW setup

## Troubleshooting

### Common Issues

1. **No MIDI Output:**
   ```bash
   ./run-line.sh test    # Check MIDI connectivity
   ./run-line.sh setup   # Setup virtual MIDI ports
   ```

2. **Permission Denied:**
   ```bash
   sudo usermod -a -G audio $USER
   # Log out and log back in
   ```

3. **Docker Issues:**
   ```bash
   ./run-line.sh clean   # Clean up containers
   ./run-line.sh build   # Rebuild image
   ```

### Debug Mode
```bash
./run-line.sh --debug alsa    # Run with verbose output
```

## Development

### Building from Source
```bash
# Traditional build (outside Docker)
./build.sh

# Docker build
./run-line.sh build
```

### Customizing the Container
Edit `Dockerfile` to:
- Add additional MIDI tools
- Include specific audio libraries
- Modify build configurations

### Adding DAW Support
1. Test MIDI connectivity with your DAW
2. Document the setup process
3. Add configuration examples to `DOCKER_DAW_GUIDE.md`

## Examples

### Basic Live Coding Session
```bash
# Start line
./run-line.sh alsa

# In line prompt:
line> ch0           # Set MIDI channel
line> bpm120        # Set tempo
line> c4 e4 g4 c5   # Play pattern
line> r             # Reverse
line> s             # Scramble
line> *2            # Double length
```

### Recording in Reaper
1. Setup virtual MIDI: `./run-line.sh setup`
2. Start line: `./run-line.sh alsa`
3. Configure Reaper MIDI input
4. Create patterns in line
5. Record MIDI in Reaper
6. Add instruments and effects

### Live Performance Setup
1. Start JACK: `jackd -d alsa -d hw:0 -r 44100 -p 256`
2. Start DAW with JACK
3. Start line: `./run-line.sh jack`
4. Connect MIDI routing in QJackCtl
5. Perform live coding with real-time pattern manipulation

## Contributing

To contribute Docker/DAW integration improvements:

1. Test with your DAW setup
2. Document the configuration process
3. Submit examples and troubleshooting tips
4. Report compatibility issues

## License

Same as the main line project - see LICENSE file.

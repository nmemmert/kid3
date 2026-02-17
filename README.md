# Kid3 Audio Tagger - Docker Container

This repository provides a containerized version of [Kid3](https://kid3.kde.org/), an efficient audio tagger that supports a large variety of file formats.

## Features

Kid3 allows you to:
- Edit ID3v1.1, ID3v2.3, and ID3v2.4 tags
- Support for MP3, Ogg/Vorbis, Opus, DSF, FLAC, MPC, APE, MP4/AAC, MP2, Speex, TrueAudio, WavPack, WMA, WAV, AIFF files
- Edit tags of multiple files simultaneously
- Generate tags from filenames
- Generate filenames from tags
- Import album data from MusicBrainz, Discogs, Amazon, and gnudb.org
- Export playlists

## What's Included

This container includes:
- **kid3-qt**: Qt-based GUI version (default)
- **kid3-cli**: Command-line interface version

The Docker images install Kid3 from Ubuntu packages for faster, more reliable builds.

## Prerequisites

- Docker
- Docker Compose (optional, but recommended)
- X11 server (for GUI mode) or a web browser (for noVNC mode)

### Linux Users
X11 should already be available. You may need to allow Docker to connect to your X server:
```bash
xhost +local:docker
```

### macOS Users
Install XQuartz:
```bash
brew install --cask xquartz
```

Start XQuartz and enable "Allow connections from network clients" in preferences.

### Windows Users
Install an X Server like:
- VcXsrv
- Xming
- X410

## Building the Container

### Using Docker
```bash
docker build -t kid3:latest .
```

### Using Docker Compose
```bash
docker compose build
```

## Running Kid3

### GUI Mode (kid3-qt)

#### Using Docker Compose (Recommended)
```bash
# Allow X11 connections
xhost +local:docker

# Set your music directory and run
export MUSIC_DIR=$HOME/Music
docker compose up
```

### Browser Mode (noVNC)

This mode runs Kid3 in a virtual display and exposes it in a browser.

```bash
export MUSIC_DIR=$HOME/Music
docker compose up kid3-vnc
```

Then open: `http://localhost:5879`

#### Using Docker directly
```bash
# Allow X11 connections
xhost +local:docker

# Run the container
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ~/Music:/music \
  -v kid3-config:/home/kid3user/.config \
  kid3:latest
```

### CLI Mode (kid3-cli)

```bash
docker run -it --rm \
  -v ~/Music:/music \
  kid3:latest \
  kid3-cli
```

#### Example CLI Commands

Once in the CLI:
```bash
# Navigate to music directory
cd /music

# Select a file
select "song.mp3"

# Get tags
get

# Set artist
set artist "Artist Name"

# Set album
set album "Album Name"

# Save changes
save

# Exit
quit
```

Or run commands directly:
```bash
docker run -it --rm \
  -v ~/Music:/music \
  kid3:latest \
  kid3-cli -c "cd /music" -c "select song.mp3" -c "set artist 'New Artist'" -c "save"
```

## Volume Mounts

The container uses the following volume mounts:

- `/music` - Your music files directory (configurable via MUSIC_DIR environment variable)
- `/home/kid3user/.config` - Kid3 configuration persistence (named volume)

## Environment Variables

- `DISPLAY` - X11 display (required for GUI)
- `MUSIC_DIR` - Path to your music directory (default: `./music` in docker-compose)
- `QT_X11_NO_MITSHM=1` - Fixes X11 shared memory issues
- `NOVNC_PORT` - Web port for noVNC (default: `5879`)
- `SCREEN` - Virtual screen size/depth (default: `1280x720x24`)
- `VNC_PASSWORD` - Optional password for VNC access

## Tips

### Persistent Configuration
The compose file creates a named volume for configuration persistence. To remove it:
```bash
docker compose down -v
```

### Access Multiple Directories
You can mount multiple music directories:
```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ~/Music:/music \
  -v ~/Downloads:/downloads \
  -v kid3-config:/home/kid3user/.config \
  kid3:latest
```

### Running as Interactive Shell
To explore the container:
```bash
docker run -it --rm \
  -v ~/Music:/music \
  kid3:latest \
  /bin/bash
```

## Troubleshooting

### GUI doesn't appear
1. Ensure X11 server is running
2. Check X11 permissions: `xhost +local:docker`
3. Verify DISPLAY variable: `echo $DISPLAY`

### Permission issues with files
The container runs as a non-root user (kid3user). Ensure your music files are readable:
```bash
chmod -R a+rX ~/Music
```

### Audio playback issues
The container is focused on tag editing. For audio playback, you may need to add additional volume mounts for audio devices.

## Security Note

Running `xhost +local:docker` allows all local Docker containers to access your X server. For better security, use:
```bash
xhost +local:$(docker inspect --format='{{ .Config.Hostname }}' kid3)
```

## License

Kid3 is licensed under GPL-2.0+. This Dockerfile is provided as-is for convenience.

## Links

- [Kid3 Official Website](https://kid3.kde.org/)
- [Kid3 Source Repository](https://invent.kde.org/multimedia/kid3)
- [Kid3 GitHub Mirror](https://github.com/KDE/kid3)

## Customizing the Image

If you need a different Kid3 version than the Ubuntu package, you can adapt the Dockerfile to build from source.

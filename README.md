# Kid3 Audio Tagger - Docker Container

This repository provides a containerized version of [Kid3](https://kid3.kde.org/), an efficient audio tagger that supports a large variety of file formats.

## Quick Start

**Pull and run the pre-built image from GitHub Container Registry:**

### Browser Mode - Recommended (No X11 Setup Required!)
The easiest way to use Kid3 - X11 runs inside the container, you just need a web browser.

```bash
docker run -d --name kid3-vnc \
  -p 5879:5879 \
  -v ~/Music:/music \
  ghcr.io/nmemmert/kid3:latest \
  /usr/local/bin/start-kid3-vnc.sh
```
Then open **http://localhost:5879** in your browser and click "Connect".

**No X11 configuration needed on your host!** The container includes Xvfb (virtual X server).

### GUI Mode (X11) - Requires Host X11
```bash
xhost +local:docker
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ~/Music:/music \
  ghcr.io/nmemmert/kid3:latest
```

### CLI Mode
```bash
docker run -it --rm \
  -v ~/Music:/music \
  ghcr.io/nmemmert/kid3:latest \
  kid3-cli
```

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
- **Xvfb**: Virtual X server (for browser mode - no host X11 needed!)
- **noVNC/websockify**: Web-based VNC client for browser access

The Docker images install Kid3 from Ubuntu packages for faster, more reliable builds.

## Prerequisites

### For Browser Mode (Recommended - Easiest)
- **Docker**
- **Web Browser** (that's it!)

No X11 or special configuration needed! The container includes its own X server (Xvfb).

### For X11 Mode (Advanced)
- Docker
- X11 server on your host machine

**X11 Setup Instructions (Only if using X11 mode):**

#### Linux Users
X11 should already be available. You may need to allow Docker to connect to your X server:
```bash
xhost +local:docker
```

#### macOS Users
Install XQuartz:
```bash
brew install --cask xquartz
```

Start XQuartz and enable "Allow connections from network clients" in preferences.

#### Windows Users
Install an X Server like:
- VcXsrv
- Xming
- X410

## Installation

### Option 1: Pull Pre-built Image (Recommended)

The easiest way to use Kid3 is to pull the pre-built image from GitHub Container Registry:

```bash
docker pull ghcr.io/nmemmert/kid3:latest
```

Then use it directly (see [Quick Start](#quick-start) above).

### Option 2: Build from Source

If you prefer to build the image yourself:

#### Using Docker
```bash
git clone https://github.com/nmemmert/kid3.git
cd kid3
docker build -t kid3:latest .
```

#### Using Docker Compose
```bash
git clone https://github.com/nmemmert/kid3.git
cd kid3
docker compose build
```

## Running Kid3

### GUI Mode (kid3-qt) - X11

**Note:** This mode requires X11 on your host system. If you don't want to configure X11, use [Browser Mode](#browser-mode-novnc---recommended) instead.

#### Using Docker Compose (Recommended)
```bash
# Allow X11 connections
xhost +local:docker

# Set your music directory and run
export MUSIC_DIR=$HOME/Music
docker compose up
```

### Browser Mode (noVNC) - Recommended

This mode runs Kid3 with its own X server (Xvfb) inside the container and exposes it through a web browser.

**No X11 configuration needed on your host!** Everything runs inside the container.

#### Using Docker Compose (Recommended)
```bash
export MUSIC_DIR=$HOME/Music
docker compose up kid3-vnc
```

#### Using Docker directly with pre-built image
```bash
docker run -d --name kid3-vnc \
  -p 5879:5879 \
  -v ~/Music:/music \
  -v kid3-config:/home/kid3user/.config \
  ghcr.io/nmemmert/kid3:latest \
  /usr/local/bin/start-kid3-vnc.sh
```

Then open: **http://localhost:5879**

Click the "Connect" button to start using Kid3 in your browser.

#### Using Docker directly
```bash
# Allow X11 connections
xhost +local:docker

# Run the container with pre-built image
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ~/Music:/music \
  -v kid3-config:/home/kid3user/.config \
  ghcr.io/nmemmert/kid3:latest
```

### CLI Mode (kid3-cli)

```bash
docker run -it --rm \
  -v ~/Music:/music \
  ghcr.io/nmemmert/kid3:latest \
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
  ghcr.io/nmemmert/kid3:latest \
  kid3-cli -c "cd /music" -c "select song.mp3" -c "set artist 'New Artist'" -c "save"
```

## Volume Mounts

The container uses the following volume mounts:

- `/music` - Your music files directory (configurable via MUSIC_DIR environment variable)
- `/home/kid3user/.config` - Kid3 configuration persistence (named volume)

## Managing Containers

### Stop a running container
```bash
docker stop kid3-vnc
```

### Remove a stopped container
```bash
docker rm kid3-vnc
```

### View container logs
```bash
docker logs kid3-vnc
```

### Restart a stopped container
```bash
docker start kid3-vnc
```

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
  ghcr.io/nmemmert/kid3:latest
```

### Running as Interactive Shell
To explore the container:
```bash
docker run -it --rm \
  -v ~/Music:/music \
  ghcr.io/nmemmert/kid3:latest \
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

- [Docker Image on GitHub Container Registry](https://github.com/nmemmert/kid3/pkgs/container/kid3)
- [GitHub Repository](https://github.com/nmemmert/kid3)
- [Kid3 Official Website](https://kid3.kde.org/)
- [Kid3 Source Repository](https://invent.kde.org/multimedia/kid3)
- [Kid3 GitHub Mirror](https://github.com/KDE/kid3)

## Customizing the Image

If you need a different Kid3 version than the Ubuntu package, you can adapt the Dockerfile to build from source.

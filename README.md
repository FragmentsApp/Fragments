# Fragments
[![GitHub release](https://img.shields.io/github/release/haecker-felix/fragments.svg)](https://github.com/haecker-felix/Fragments/releases/)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Packaging status](https://repology.org/badge/tiny-repos/fragments.svg)](https://repology.org/metapackage/fragments)

![screenshot](https://github.com/haecker-felix/Fragments/blob/master/data/screenshots/1.png)
    
Fragments is an easy to use BitTorrent client which follows the GNOME HIG and includes well thought-out features.

## Install
Make sure you have Flatpak installed. [Get more information](http://flatpak.org/getting.html)

### Stable
* Soon on Flathub available! 

### Nightly
* ``flatpak install --from https://repos.byteturtle.eu/fragments-master.flatpakref``

**GPG Details:**
* Fingerprint:  F97F 162A F540 FF52 B0D2 8C92 D703 6FBE A001 AC1A
* ID: D7036FBEA001AC1A

### Build introductions
```
git clone --recurse-submodules https://github.com/haecker-felix/Fragments
cd Fragments
mkdir build
cd build
meson ..
ninja
sudo ninja install
```

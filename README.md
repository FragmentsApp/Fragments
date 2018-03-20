<img src="https://github.com/haecker-felix/Fragments/raw/master/data/icons/hicolor/128x128/apps/org.gnome.Fragments.png" align="left" />

# Fragments
[![GitHub release](https://img.shields.io/github/release/haecker-felix/fragments.svg)](https://github.com/haecker-felix/Fragments/releases/)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Packaging status](https://repology.org/badge/tiny-repos/fragments.svg)](https://repology.org/metapackage/fragments)

![screenshot](https://i.imgur.com/UuIlpu9.png)

A new GTK3 BitTorrent Client, which is still under heavy development. Fragments does not aim to integrate as many features or settings as possible. There are plenty of other torrent clients for that. Fragments is an easy to use BitTorrent client which follows the GNOME HIG and includes well thought-out features.

You can try out the latest nightly build.
 Make sure you have Flatpak installed. [Get more information](http://flatpak.org/getting.html)

* ``flatpak install --from https://repos.byteturtle.eu/fragments-master.flatpakref``

**GPG Details:**
* Fingerprint:  F97F 162A F540 FF52 B0D2 8C92 D703 6FBE A001 AC1A
* ID: D7036FBEA001AC1A

## Build introductions
```
git clone --recurse-submodules https://github.com/haecker-felix/Fragments
cd Fragments
mkdir build
cd build
meson ..
ninja
sudo ninja install
```

# WiFi-channel-finder
Finds the best channel for your 2.4GHz WiFi

![GitHub last commit](https://img.shields.io/github/last-commit/thomasgruebl/WiFi-channel-finder?style=plastic) ![GitHub](https://img.shields.io/github/license/thomasgruebl/WiFi-channel-finder?style=plastic)

**Dependencies**
---

```
iwlist
iwgetid
```

**Usage**
---

```
Make executable: chmod +x channel_finder.sh
Usage: sudo ./channel_finder.sh [OPTIONS]

Arguments:
  [1]  --ssid    Optionally specify a different SSID to scan
```

**Description**
---

This short script provides a channel recommendation for your 2.4 GHz Wifi by simply scanning the network for neighbouring WiFis,
determining the occupied channels and the signal strength (using iwlist) and producing an estimate of the channels least affected by co-channel interference.

Commonly, co-channel interference (multiple networks using the same channel) is regarded less detrimental than adjacent channel interference (overlapping adjacent channels 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 14). Hence, this script only recommends non-overlapping channels (1, 6, 11) based on the severity of co-channel interference.

Since many routers enforce the auto-select channel option by default, it often happens that (at least) one of the channels 1, 6 and 11 is overcrowded.

5GHz WiFi, on the other hand, provides 24 non-overlapping channels which significantly reduces the likelihood
of interferences (unless you all happen to have the same router model with the same default settings).

You need access to your router admin panel to change the channel.


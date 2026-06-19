#!/bin/bash
# Comprehensive CrossOver/Wine teardown. The run_*_d9mt.sh scripts launch a game
# and leave it running (so you can play/observe). To avoid a growing WAVE of
# leftover wineservers/services/winedevice/games across runs, every run calls this
# FIRST — it kills ALL wine processes (one game at a time is the test model).
# Also usable standalone:  bash kill_all_wine.sh
for pat in wineserver wine-preloader wine64-preloader wineloader winewrapper '\.exe'; do
  pkill -9 -f "$pat" 2>/dev/null
done
sleep 1
# report leftovers (should be 0)
n=$(ps -axo comm 2>/dev/null | grep -iE "wine|\.exe" | grep -ivE "grep|claude" | wc -l | tr -d ' ')
echo "[kill_all_wine] wine procs remaining: $n"

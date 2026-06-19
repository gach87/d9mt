#!/bin/bash
# Run COD4 on the d9mt (DXVK-FE) driver, against our CUSTOM-location bottle.
# Mirrors ../dxmt/run_cod4.sh but deploys d9mt's d3d9fe.dll as d3d9.dll and wires
# the d9mtmetal/winemetal builtins. Build first: see README (3 steps).
set -u

CX_ROOT=/Applications/CrossOver.app/Contents/SharedSupport/CrossOver
WINEPREFIX="/Volumes/GachData/bottles/CrossOver/Bottles/COD4"
GAMEDIR="$WINEPREFIX/drive_c/Program Files (x86)/Call of Duty 4 - Modern Warfare"
D9MT=/Volumes/GachData/repos/personal/d9mt
DRIVER="$D9MT/build/d3d9fe.dll"
WAIT="${1:-40}"

[ -f "$DRIVER" ] || { echo "ERROR: build $DRIVER first (scripts/build-dxvkfe.sh)"; exit 1; }

# Comprehensive teardown first (no leftover-wine wave across runs).
bash "$D9MT/kill_all_wine.sh"

# d9mtmetal PE dlls into THIS bottle (the build-d9mtmetal prefix-copy step targets
# the default ~/Library bottle path; ours is custom, so do it here).
cp "$D9MT/build/d9mtmetal/d9mtmetal32.dll" "$WINEPREFIX/drive_c/windows/syswow64/d9mtmetal.dll"
cp "$D9MT/build/d9mtmetal/d9mtmetal64.dll" "$WINEPREFIX/drive_c/windows/system32/d9mtmetal.dll"

# d9mt driver as d3d9.dll (game dir + syswow64).
cp "$DRIVER" "$GAMEDIR/d3d9.dll"
cp "$DRIVER" "$WINEPREFIX/drive_c/windows/syswow64/d3d9.dll"

export WINEPREFIX CX_ROOT
export CX_BOTTLE=COD4
export CX_HOME="$HOME/Library/Application Support/CrossOver"
# d3d9 = our native driver; winemetal/d9mtmetal = wine builtins (bridge + unixlib).
export WINEDLLOVERRIDES="d3d9=n;winemetal=b;d9mtmetal=b"
export WINEDEBUG="${WINEDEBUG:-+err,+fixme}"
export D9MT_TRACE=1
export MTL_HUD_ENABLED="${MTL_HUD_ENABLED:-1}"
export MTL_HUD_ENABLED="${MTL_HUD_ENABLED:-1}"  # Apple Metal perf HUD = proof it's Metal + fps/frametime

LOG="$HOME/Desktop/COD4_d9mt.cxlog"
rm -f "$LOG"

"$CX_ROOT/bin/wineloader" \
  "$CX_ROOT/lib/wine/x86_64-windows/winewrapper.exe" \
  --workdir "C:\\Program Files (x86)\\Call of Duty 4 - Modern Warfare" \
  --start -- \
  "C:\\Program Files (x86)\\Call of Duty 4 - Modern Warfare\\iw3sp.exe" \
  +set fs_checkForCriticalErrors 0 \
  +set com_introPlayed 1 \
  +set r_fullscreen ${COD4_FS:-0} \
  +set r_aaSamples ${COD4_AA:-4} \
  +map ${COD4_MAP:-blackout} > "$LOG" 2>&1 &

echo "Launched d9mt COD4, waiting ${WAIT}s... (log: $LOG)"
sleep "$WAIT"
echo "=== log tail ==="
tail -25 "$LOG" 2>/dev/null

#!/bin/bash
# ############################################################
# run_openocd.command  -  STM32F103 debug helper (macOS)
#
# What this does:
#   Starts an OpenOCD GDB server on port 3333 using the
#   openocd_clone.cfg next to this file, so STM32CubeIDE can
#   attach with "GDB Hardware Debugging" (no ST device check).
#
# Comments are English on purpose. The Korean explanation
# lives in the .md manual (scripts stay ASCII-safe).
#
# Keep openocd_clone.cfg in the SAME folder as this script.
# First time only, make it runnable:  chmod +x run_openocd.command
# Then just double-click it in Finder.
# ############################################################

# [0] optional manual override (uncomment & set if auto-detect fails)
# OPENOCD="/Applications/STM32CubeIDE.app/Contents/Eclipse/plugins/com.st...openocd.macosaarch64_x/tools/bin/openocd"
# GDB="/Applications/STM32CubeIDE.app/Contents/Eclipse/plugins/com.st...gnu-tools-for-stm32...macosaarch64_x/tools/bin/arm-none-eabi-gdb"
OPENOCD="${OPENOCD:-}"
GDB="${GDB:-}"

# [1] this script's folder -> openocd_clone.cfg right next to it
DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$DIR/openocd_clone.cfg"
if [ ! -f "$CFG" ]; then
  echo "[ERROR] openocd_clone.cfg not found next to this script:"; echo "  $CFG"
  read -n1 -r -p "Press any key to close..."; exit 1
fi

# [2]+[3] auto-detect openocd + gdb inside STM32CubeIDE.app
#         (any version / any platform token; newest wins)
echo "Searching for OpenOCD inside STM32CubeIDE, please wait..."
for APP in "/Applications/STM32CubeIDE.app" "$HOME/Applications/STM32CubeIDE.app"; do
  [ -d "$APP" ] || continue
  P="$APP/Contents/Eclipse/plugins"
  [ -z "$OPENOCD" ] && OPENOCD="$(find "$P" -type f -name openocd -path '*externaltools.openocd*/tools/bin/*' 2>/dev/null | sort | tail -n1)"
  [ -z "$GDB" ]     && GDB="$(find "$P" -type f -name arm-none-eabi-gdb -path '*gnu-tools-for-stm32*/tools/bin/*' 2>/dev/null | sort | tail -n1)"
done

# [4] if openocd not found, stop with guidance
if [ -z "$OPENOCD" ]; then
  echo "[ERROR] openocd not found inside STM32CubeIDE.app."
  echo "Install STM32CubeIDE, or set OPENOCD manually at section [0]."
  read -n1 -r -p "Press any key to close..."; exit 1
fi

# [5] show findings, then start the server
echo "============================================================"
echo "  OpenOCD server for STM32F103 (macOS)"
echo "  OpenOCD : $OPENOCD"
echo "  GDB     : $GDB"
[ -z "$GDB" ] && echo "  (GDB not auto-found: set it by hand in CubeIDE, see manual)"
echo "  CFG     : $CFG"
echo "  -> paste GDB path into CubeIDE:"
echo "     GDB Hardware Debugging > Debugger > GDB Command"
echo "  -> wait for:  Listening on port 3333 for gdb connections"
echo "  -> keep this window OPEN while debugging"
echo "============================================================"

"$OPENOCD" -f "$CFG"

# [6] openocd has exited (you stopped debugging / unplugged USB)
echo
read -n1 -r -p "OpenOCD stopped. Press any key to close..."

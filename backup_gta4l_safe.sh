#!/bin/bash
set -u

echo "======================================"
echo " Backup seguro SM-T505 (gta4l)"
echo "======================================"

OUT="/sdcard/gta4l_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"

PARTS="
boot
recovery
dtbo
vbmeta
vbmeta_samsung
efs
sec_efs
modemst1
modemst2
persist
super
modem
apnhlos
fsg
fsc
cache
metadata
misc
param
"

for p in $PARTS; do
  SRC="/dev/block/by-name/$p"
  if [ -e "$SRC" ]; then
    echo "Backup $p..."
    dd if="$SRC" of="$OUT/$p.img" bs=4M
    sync
  else
    echo "AVISO: $p não existe, ignorando."
  fi
done

echo "======================================"
echo "Backup concluído em: $OUT"
echo "Agora, no PC, execute:"
echo "adb pull $OUT"
echo "======================================"

# COMANDOS.md

## Objetivo

Registar a ordem dos comandos usados no projeto, explicar o que cada comando faz e preservar os comandos necessários para retomar o trabalho com segurança.

## 1. Identificação Android

### Ver todas as propriedades Android

```bash
adb shell getprop
```

Lê as propriedades do Android.

### Codename do dispositivo

```bash
adb shell getprop ro.product.device
```

Resultado observado:

```text
gta4l
```

Significado:

Codename interno do dispositivo.

### Versão LineageOS

```bash
adb shell getprop ro.lineage.version
```

Usado para identificar a ROM atual.

### Plataforma base

```bash
adb shell getprop ro.boot.hardware
```

Resultado observado:

```text
qcom
```

Significado:

Plataforma Qualcomm.

## 2. Root ADB

### Reiniciar ADB como root

```bash
adb root
```

Resultado observado:

```text
adbd is already running as root
```

### Entrar no shell

```bash
adb shell
```

### Confirmar root

```bash
id
```

Resultado esperado:

```text
uid=0(root)
```

Significado:

O ADB tem acesso root. Isto permitiu copiar partições com `dd`.

## 3. Kernel

### Kernel em execução

```bash
adb shell uname -a
```

### Versão detalhada do kernel

```bash
adb shell cat /proc/version
```

Resultado observado:

```text
Linux version 4.19.325-cip128-st12-perf-g646d493c15ed
Android Clang 21.0.0
LLD 21.0.0
Sun Apr 5 10:01:17 UTC 2026
```

### Salvar info do kernel no PC

```bash
adb shell uname -a > kernel_info.txt
adb shell cat /proc/version > kernel_version.txt
```

### Salvar configuração do kernel

```bash
adb shell zcat /proc/config.gz > kernel.config
```

Verificações úteis:

```bash
ls -lh kernel.config
head -20 kernel.config
grep -E "CONFIG_ANDROID|CONFIG_BINDER|CONFIG_ASHMEM|CONFIG_CGROUP|CONFIG_NAMESPACES|CONFIG_OVERLAY_FS|CONFIG_VT|CONFIG_FB|CONFIG_DRM|CONFIG_INPUT|CONFIG_USB_CONFIGFS" kernel.config | sort
```

## 4. Linha de boot

```bash
adb shell cat /proc/cmdline
```

Salvar no PC:

```bash
adb shell cat /proc/cmdline > kernel_cmdline.txt
```

Descobertas relevantes:

```text
androidboot.hardware=qcom
androidboot.em.model=SM-T505
androidboot.bootloader=T505XXS8CXG1
androidboot.verifiedbootstate=orange
androidboot.warranty_bit=1
androidboot.dram_info=...3G
msm_drm.dsi_display0=qcom,mdss_dsi_ft8201ab_tianma_tianma_video
```

Significado:

Confirma Qualcomm, modelo SM-T505, bootloader desbloqueado, firmware base T505XXS8CXG1, 3 GB RAM e painel FT8201AB Tianma.

## 5. Device Tree

### Modelo do device tree

```bash
adb shell 'cat /proc/device-tree/model; echo'
```

Resultado:

```text
Qualcomm Technologies, Inc. Bengal QRD
```

### Compatibilidade do device tree

```bash
adb shell 'tr "\0" "\n" < /proc/device-tree/compatible'
```

Resultado:

```text
qcom,bengal-qrd
qcom,bengal
qcom,qrd
```

## 6. Partições

### Listar partições

```bash
adb shell ls -l /dev/block/by-name
```

### Verificar existência das partições críticas

```bash
adb root
adb shell 'for p in boot recovery dtbo vbmeta vbmeta_samsung efs sec_efs modemst1 modemst2 persist super modem apnhlos fsg fsc cache metadata misc param; do echo "$p -> $(readlink -f /dev/block/by-name/$p 2>/dev/null || echo AUSENTE)"; done'
```

Partições críticas confirmadas:

```text
boot -> /dev/block/mmcblk0p69
recovery -> /dev/block/mmcblk0p70
dtbo -> /dev/block/mmcblk0p57
vbmeta -> /dev/block/mmcblk0p11
vbmeta_samsung -> /dev/block/mmcblk0p19
efs -> /dev/block/mmcblk0p64
sec_efs -> /dev/block/mmcblk0p63
modemst1 -> /dev/block/mmcblk0p61
modemst2 -> /dev/block/mmcblk0p62
persist -> /dev/block/mmcblk0p37
super -> /dev/block/mmcblk0p73
modem -> /dev/block/mmcblk0p36
apnhlos -> /dev/block/mmcblk0p42
fsg -> /dev/block/mmcblk0p59
fsc -> /dev/block/mmcblk0p60
cache -> /dev/block/mmcblk0p76
metadata -> /dev/block/mmcblk0p45
misc -> /dev/block/mmcblk0p46
param -> /dev/block/mmcblk0p44
```

## 7. Backup

### Script usado

Arquivo:

```text
backup_gta4l_safe.sh
```

Conteúdo:

```bash
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
```

### Enviar e executar script

```bash
adb push backup_gta4l_safe.sh /sdcard/
adb shell chmod +x /sdcard/backup_gta4l_safe.sh
adb shell sh /sdcard/backup_gta4l_safe.sh
```

### Puxar backup para o PC

```bash
adb pull /sdcard/gta4l_backup_20260610_072545
```

### Verificar tamanhos

```bash
ls -lh gta4l_backup_20260610_072545
```

### Gerar hashes SHA256

```bash
sha256sum gta4l_backup_20260610_072545/*.img > gta4l_backup_20260610_072545/SHA256SUMS.txt
```

### Verificar hashes futuramente

```bash
cd gta4l_backup_20260610_072545
sha256sum -c SHA256SUMS.txt
```

## 8. Ambiente do PC

### Identificar sistema host

```bash
cat /etc/os-release
uname -a
```

Resultado observado:

```text
Fedora Linux 43 Workstation
Kernel 7.0.10-101.fc43.x86_64
```

### Verificar ferramentas

```bash
which lpunpack
which lpdump
which simg2img
which file
```

Resultado observado:

```text
/usr/bin/lpunpack
/usr/bin/simg2img
/usr/bin/file
```

## 9. Analisar `super.img`

### Tipo do arquivo

```bash
file gta4l_backup_20260610_072545/super.img
```

Resultado observado:

```text
data
```

### Cabeçalho

```bash
hexdump -C gta4l_backup_20260610_072545/super.img | head -20
```

### Metadata de partição lógica

```bash
lpdump gta4l_backup_20260610_072545/super.img | head -50
```

Resultado observado:

```text
Metadata version: 10.0
system
vendor
product
odm
```

## 10. Extrair `super.img`

```bash
mkdir extracted
lpunpack gta4l_backup_20260610_072545/super.img extracted
```

Verificar:

```bash
ls -lh extracted
```

Resultado observado:

```text
odm.img      1,7M
product.img  2,4G
system.img   1,5G
vendor.img   529M
```

## 11. Verificar sistema de ficheiros

```bash
file extracted/*.img
blkid extracted/*.img
```

Resultado:

```text
system.img  -> ext4
vendor.img  -> ext4
product.img -> ext4
odm.img     -> ext4
```

## 12. Montar imagens

Criar pontos de montagem:

```bash
sudo mkdir -p /mnt/system
sudo mkdir -p /mnt/vendor
sudo mkdir -p /mnt/product
sudo mkdir -p /mnt/odm
```

Montar:

```bash
sudo mount -o loop extracted/system.img /mnt/system
sudo mount -o loop extracted/vendor.img /mnt/vendor
sudo mount -o loop extracted/product.img /mnt/product
sudo mount -o loop extracted/odm.img /mnt/odm
```

Confirmar:

```bash
df -h | grep /mnt
```

Desmontar quando terminar:

```bash
sudo umount /mnt/system
sudo umount /mnt/vendor
sudo umount /mnt/product
sudo umount /mnt/odm
```

## 13. Inventários

### Estrutura básica

```bash
ls /mnt/system
ls /mnt/vendor
ls /mnt/product | head
ls /mnt/odm
```

### Contar bibliotecas vendor

```bash
sudo find /mnt/vendor -name "*.so" | wc -l
```

Resultado observado:

```text
1129
```

### HALs

```bash
sudo find /mnt/vendor/lib64/hw -maxdepth 1 -type f | sort > vendor_hw_lib64.txt
sudo find /mnt/vendor/lib/hw -maxdepth 1 -type f | sort > vendor_hw_lib.txt
wc -l vendor_hw_lib64.txt vendor_hw_lib.txt
```

Resultado:

```text
30 vendor_hw_lib64.txt
27 vendor_hw_lib.txt
57 total
```

### Binários vendor

```bash
sudo find /mnt/vendor/bin -maxdepth 1 -type f | sort > vendor_bins.txt
```

### Init scripts vendor

```bash
sudo find /mnt/vendor/etc/init -maxdepth 1 -type f | sort > vendor_init_rc.txt
```

### Inventários completos

```bash
sudo find /mnt/vendor -type f | sort > INVENTORY_vendor_files.txt
sudo find /mnt/product -type f | sort > INVENTORY_product_files.txt
sudo find /mnt/system/system -type f | sort > INVENTORY_system_files.txt
sudo find /mnt/odm -type f | sort > INVENTORY_odm_files.txt

wc -l INVENTORY_*_files.txt
```

## 14. system_ext

Verificar symlink:

```bash
sudo ls -la /mnt/system/system_ext
```

Ver conteúdo real:

```bash
sudo ls -la /mnt/system/system/system_ext
sudo find /mnt/system/system/system_ext -maxdepth 2 -type f | sort | head -80
```

Descoberta:

`/mnt/system/system_ext` aponta para `/system/system_ext`, e o conteúdo real fica em:

```text
/mnt/system/system/system_ext
```

## 15. VINTF

Localizar manifests e compatibility matrix:

```bash
sudo find /mnt/vendor/etc -name "*manifest*" -o -name "*matrix*"
```

Arquivos encontrados:

```text
/mnt/vendor/etc/vintf/manifest.xml
/mnt/vendor/etc/vintf/compatibility_matrix.xml
/mnt/vendor/etc/vintf/manifest/
```

Listar HAL names:

```bash
sudo grep -R "<name>" /mnt/vendor/etc/vintf/manifest.xml /mnt/vendor/etc/vintf/manifest/*.xml | sed 's/^[^:]*://' | sort -u
```

Listar transport/name/version/fqname:

```bash
sudo grep -R "<transport>\|<name>\|<version>\|<fqname>" /mnt/vendor/etc/vintf/manifest.xml /mnt/vendor/etc/vintf/manifest/*.xml | head -200
```

## 16. Propriedades Android completas

```bash
adb shell getprop | sort > all_props.txt
```

Este arquivo é útil para consultar propriedades de build, rádio, vendor, boot e compatibilidade.

## 17. Próximos comandos prováveis para Halium

Ainda não executados.

Instalar dependências no host Linux:

```bash
sudo dnf install git git-lfs python3 python3-pip java-11-openjdk-devel bc bison flex gcc gcc-c++ make ncurses-devel openssl-devel elfutils-libelf-devel lzop zip unzip rsync
```

Observação:

O pacote `repo` pode precisar ser instalado via distribuição, pipx, ou manualmente a partir do script oficial do Android.

Criar workspace:

```bash
mkdir -p ~/halium-gta4l
cd ~/halium-gta4l
```

Inicializar Halium:

```bash
repo init -u https://github.com/Halium/android.git -b halium-12.0
repo sync -j$(nproc)
```

Atenção:

Estes comandos ainda não foram executados no projeto. Só devem ser rodados depois de decidir a estratégia exata de device tree/kernel/vendor.


---

# Atualização de progresso — 2026-06-10
## 18. Reuso de código LineageOS

### Workspace de análise

```bash
cd ~/halium
mkdir -p reuse
cd ~/halium/reuse
```

### Clonar árvores LineageOS atuais

```bash
git clone https://github.com/LineageOS/android_device_samsung_gta4l.git
git clone https://github.com/LineageOS/android_device_samsung_gta4lwifi.git
git clone https://github.com/LineageOS/android_device_samsung_gta4l-common.git
git clone https://github.com/LineageOS/android_kernel_samsung_sm6115.git
```

Resultado observado:

```text
As árvores atuais estavam em lineage-23.2, compatíveis com a ROM atual LineageOS 23.x / Android 16.
```

### Comparar T500 Wi-Fi e T505 LTE

```bash
diff -ruN android_device_samsung_gta4lwifi android_device_samsung_gta4l > diff_gta4lwifi_vs_gta4l.txt

grep -R "gta4l\|gta4lwifi\|radio\|ril\|modem\|telephony\|vendor_boot\|dtbo\|super" \
  android_device_samsung_gta4l \
  android_device_samsung_gta4lwifi \
  android_device_samsung_gta4l-common \
  > reuse_keywords_report.txt
```

Conclusão:

```text
SM-T505 / gta4l é essencialmente SM-T500 / gta4lwifi + LTE/RIL/modem.
```

## 19. Branches LineageOS históricas

### Tentativa LineageOS 19.1

```bash
git clone https://github.com/LineageOS/android_device_samsung_gta4l -b lineage-19.1 android_device_samsung_gta4l_19_1
git clone https://github.com/LineageOS/android_device_samsung_gta4lwifi -b lineage-19.1 android_device_samsung_gta4lwifi_19_1
git clone https://github.com/LineageOS/android_device_samsung_gta4l-common -b lineage-19.1 android_device_samsung_gta4l-common_19_1
```

Resultado:

```text
fatal: ramo remoto lineage-19.1 não encontrado
```

Conclusão:

```text
Não há branch lineage-19.1 pública nessas árvores LineageOS.
```

### Listar branches disponíveis

```bash
cd ~/halium/reuse

git ls-remote --heads https://github.com/LineageOS/android_device_samsung_gta4l.git > branches_gta4l.txt
git ls-remote --heads https://github.com/LineageOS/android_device_samsung_gta4lwifi.git > branches_gta4lwifi.txt
git ls-remote --heads https://github.com/LineageOS/android_device_samsung_gta4l-common.git > branches_gta4l-common.txt

cat branches_gta4l.txt
cat branches_gta4lwifi.txt
cat branches_gta4l-common.txt
```

Resultado observado:

```text
lineage-20
lineage-21
lineage-22.0
lineage-22.1
lineage-22.2
lineage-23.0
lineage-23.1
lineage-23.2
```

### Clonar lineage-20

```bash
cd ~/halium/reuse

git clone https://github.com/LineageOS/android_device_samsung_gta4l -b lineage-20 android_device_samsung_gta4l_20
git clone https://github.com/LineageOS/android_device_samsung_gta4lwifi -b lineage-20 android_device_samsung_gta4lwifi_20
git clone https://github.com/LineageOS/android_device_samsung_gta4l-common -b lineage-20 android_device_samsung_gta4l-common_20
```

### Comparar lineage-20 com lineage-23.2

```bash
diff -ruN android_device_samsung_gta4l-common_20 android_device_samsung_gta4l-common > diff_common_20_vs_23_2.txt
diff -ruN android_device_samsung_gta4l_20 android_device_samsung_gta4l > diff_gta4l_20_vs_23_2.txt
diff -ruN android_device_samsung_gta4lwifi_20 android_device_samsung_gta4lwifi > diff_gta4lwifi_20_vs_23_2.txt
```

### Gerar resumo focado em Halium

```bash
cd ~/halium/reuse

grep -R "BOARD_SUPER\|BOARD_GTA4L_DYNAMIC\|TARGET_KERNEL\|DEVICE_MANIFEST\|DEVICE_MATRIX\|VINTF\|RIL\|radio\|rild\|secril\|vendor.prop\|init.vendor.ril" \
  android_device_samsung_gta4l_20 \
  android_device_samsung_gta4l \
  android_device_samsung_gta4l-common_20 \
  android_device_samsung_gta4l-common \
  > halium_relevant_20_vs_23_2.txt
```

Conclusão:

```text
A parte relevante para Halium quase não mudou entre lineage-20 e lineage-23.2.
A árvore gta4l lineage-20 já contém RIL, rild, secril_config_svc, vendor.samsung.hardware.radio, init.vendor.rilchip.rc e init.vendor.rilcommon.rc.
```

## 20. Procurar referências Halium/Ubuntu Touch existentes

```bash
cd ~/halium

grep -R "bengal\|sm6115\|gta4l\|gta4lwifi" reuse/* 2>/dev/null > sm6115_references.txt

find reuse -iname "*halium*" -o -iname "*ubuntu*" > possible_halium_refs.txt

cat possible_halium_refs.txt
```

Resultado:

```text
Nenhuma referência real a port Halium/Ubuntu Touch existente foi encontrada no material local.
```

## 21. Verificação do kernel source LineageOS

```bash
cd ~/halium/reuse/android_kernel_samsung_sm6115

grep -R "^VERSION =" .
grep -R "^PATCHLEVEL =" .

grep -R "CONFIG_ANDROID_BINDER_IPC" .
grep -R "CONFIG_ANDROID_BINDERFS" .
grep -R "CONFIG_ASHMEM" .
grep -R "CONFIG_ION" .
grep -R "CONFIG_DEVTMPFS" .
```

Resultados importantes:

```text
VERSION = 4
PATCHLEVEL = 19
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDERFS=y
CONFIG_ASHMEM=y
CONFIG_ION=y
CONFIG_DEVTMPFS=y
```

Conclusão:

```text
O kernel source é Linux 4.19 e contém recursos essenciais para Halium.
```

## 22. Confirmar base Android da branch lineage-20

```bash
cd ~/halium/reuse

grep -R "PRODUCT_SHIPPING_API_LEVEL" \
android_device_samsung_gta4l_20 \
android_device_samsung_gta4lwifi_20 \
android_device_samsung_gta4l-common_20
```

Resultado observado:

```text
android_device_samsung_gta4l-common_20/gta4l.mk:PRODUCT_SHIPPING_API_LEVEL := 29
```

Interpretação:

```text
O dispositivo foi lançado originalmente com Android 10, mas a árvore LineageOS 20 usa blobs Samsung Android 12.
```

### Fingerprint/base vendor LineageOS 20

```bash
cd ~/halium/reuse

grep -R "SP1A\|T505XX\|BUILD_FINGERPRINT\|PRIVATE_BUILD_DESC\|BuildFingerprint\|BuildDesc" \
android_device_samsung_gta4l_20 \
android_device_samsung_gta4l-common_20 \
> android_base_fingerprint_20.txt

cat android_base_fingerprint_20.txt
```

Resultado:

```text
PRIVATE_BUILD_DESC="gta4lxx-user 12 SP1A.210812.016 T505XXS6CWI2 release-keys"
BUILD_FINGERPRINT := "samsung/gta4lxx/qssi:12/SP1A.210812.016/T505XXS6CWI2:user/release-keys"
proprietary-files.txt: from Samsung package version T505XXS6CWI2
```

Conclusão:

```text
A base escolhida para integração é Halium 12 usando lineage-20 como referência e blobs Samsung Android 12.
```

## 23. Criar cópias locais para Halium 12

```bash
cd ~/halium/reuse

cp -a android_device_samsung_gta4l_20 android_device_samsung_gta4l_halium12
cp -a android_device_samsung_gta4l-common_20 android_device_samsung_gta4l-common_halium12
cp -a android_kernel_samsung_sm6115 android_kernel_samsung_sm6115_halium12
```

Listar ficheiros principais:

```bash
find android_device_samsung_gta4l_halium12 android_device_samsung_gta4l-common_halium12 \
  -maxdepth 3 -type f | sort > halium12_tree_files.txt

cat halium12_tree_files.txt
```

## 24. Preparar fragmento de kernel Halium

Verificar namespaces:

```bash
cd ~/halium/reuse/android_kernel_samsung_sm6115_halium12

grep -R "CONFIG_CGROUP_BPF" arch/arm64/configs/vendor/bengal* 2>/dev/null
grep -R "CONFIG_ANDROID_PARANOID_NETWORK" arch/arm64/configs/vendor/bengal* 2>/dev/null
grep -R "CONFIG_UTS_NS" arch/arm64/configs/vendor/bengal* 2>/dev/null
grep -R "CONFIG_USER_NS" arch/arm64/configs/vendor/bengal* 2>/dev/null
grep -R "CONFIG_PID_NS" arch/arm64/configs/vendor/bengal* 2>/dev/null
grep -R "CONFIG_NET_NS" arch/arm64/configs/vendor/bengal* 2>/dev/null
```

Resultado relevante:

```text
CONFIG_CGROUP_BPF=y
# CONFIG_PID_NS is not set
```

Criar fragmento:

```bash
cd ~/halium/reuse/android_kernel_samsung_sm6115_halium12

cat > arch/arm64/configs/vendor/gta4l-halium.config <<'EOF'
CONFIG_PID_NS=y
CONFIG_USER_NS=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_NET_NS=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_BPF=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDERFS=y
CONFIG_ASHMEM=y
CONFIG_ION=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
EOF
```

Editar `BoardConfigCommon.mk`:

```make
TARGET_KERNEL_CONFIG := vendor/bengal-perf_defconfig vendor/gta4l-halium.config
```

Remover override da árvore específica:

```bash
cd ~/halium/reuse/android_device_samsung_gta4l_halium12

cp BoardConfig.mk BoardConfig.mk.bak
sed -i '/TARGET_KERNEL_CONFIG := gta4l_eur_open_defconfig/d' BoardConfig.mk
mkdir -p ../backups_halium12
mv BoardConfig.mk.bak ../backups_halium12/BoardConfig.gta4l.mk.bak
```

Confirmar:

```bash
grep -R "TARGET_KERNEL_CONFIG" \
  ~/halium/reuse/android_device_samsung_gta4l_halium12/*.mk \
  ~/halium/reuse/android_device_samsung_gta4l-common_halium12/*.mk
```

Resultado esperado/observado:

```text
BoardConfigCommon.mk:TARGET_KERNEL_CONFIG := vendor/bengal-perf_defconfig vendor/gta4l-halium.config
```

## 25. Verificação dos fstabs Halium 12

```bash
cd ~/halium/reuse/android_device_samsung_gta4l-common_halium12

cat rootdir/etc/fstab.emmc
cat rootdir/etc/fstab.default
cat rootdir/etc/fstab.firmware
```

Conclusões:

```text
system, vendor, product e odm são partições lógicas.
persist, efs, sec_efs, metadata e userdata existem no fstab.
modem, apnhlos, dsp e bluetooth são montados como firmware Qualcomm.
AVB aparece nas entradas do fstab e terá de ser considerado no método de boot/flash.
```

## 26. Estado do ambiente Halium

```bash
cd ~/halium

ls
repo manifests 2>/dev/null || true
repo --version
grep -R "halium" .repo/manifests 2>/dev/null
```

Resultado:

```text
Diretórios existentes: info, research, reuse, snapshots
repo instalado em ~/.local/bin/repo
Nenhuma árvore Halium inicializada ainda em ~/halium
```

## 27. Próximo passo definido: árvore limpa Halium 12 com cópias locais

```bash
cd ~/halium
mkdir -p halium-12-gta4l
cd halium-12-gta4l

repo init -u https://github.com/Halium/android -b halium-12.0 --depth=1
repo sync -c -j$(nproc)
```

Depois da sincronização:

```bash
cd ~/halium/halium-12-gta4l

mkdir -p device/samsung kernel/samsung

cp -a ~/halium/reuse/android_device_samsung_gta4l_halium12 device/samsung/gta4l
cp -a ~/halium/reuse/android_device_samsung_gta4l-common_halium12 device/samsung/gta4l-common
cp -a ~/halium/reuse/android_kernel_samsung_sm6115_halium12 kernel/samsung/sm6115
```

Verificação prevista:

```bash
ls device/samsung
ls kernel/samsung
grep -R "PRODUCT_NAME" device/samsung/gta4l/*.mk
```Sim. Com base no histórico real que enviaste agora , a secção **17. Próximos comandos prováveis para Halium** do `COMANDOS.md` já está desatualizada e deveria ganhar uma nova secção, por exemplo:

# 18. Construção da árvore Halium 12

## Inicializar workspace

```bash
mkdir -p ~/halium/halium-12-gta4l
cd ~/halium/halium-12-gta4l

repo init -u https://github.com/Halium/android -b halium-12.0 --depth=1
repo sync -c -j$(nproc)
```

## Corrigir Chromium WebView

```bash
rm -rf external/chromium-webview/prebuilt/arm
rm -rf external/chromium-webview/prebuilt/arm64
rm -rf external/chromium-webview/prebuilt/x86
rm -rf external/chromium-webview/prebuilt/x86_64

repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
```

## Importar árvores locais

```bash
mkdir -p device/samsung kernel/samsung

cp -a ~/halium/reuse/android_device_samsung_gta4l_halium12 \
      device/samsung/gta4l

cp -a ~/halium/reuse/android_device_samsung_gta4l-common_halium12 \
      device/samsung/gta4l-common

cp -a ~/halium/reuse/android_kernel_samsung_sm6115_halium12 \
      kernel/samsung/sm6115
```

## Preparação do build

```bash
source build/envsetup.sh
breakfast gta4l
```

## Correção non_ab_device

```bash
sed -i \
's|$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)|# removed for Halium 12|' \
device/samsung/gta4l-common/gta4l.mk
```

## Extração dos blobs

```bash
cd device/samsung/gta4l-common
./extract-files.sh /mnt

cd ../gta4l
./extract-files.sh /mnt
```

Gerados:

```text
vendor/samsung/gta4l
vendor/samsung/gta4l-common
```

# 19. Correções para compilar

## SEPolicy

```bash
sed -i \
's|device/qcom/sepolicy_vndr-legacy-um/SEPolicy.mk|device/qcom/sepolicy-legacy-um/SEPolicy.mk|' \
device/samsung/gta4l-common/BoardConfigCommon.mk
```

## Audio HAL 7.1

Ficheiro:

```text
device/samsung/gta4l-common/audio/impl/Android.bp
```

Comentado:

```text
android.hardware.audio@7.1-impl_gta4l
```

## Health HAL

```bash
mkdir -p \
vendor/samsung/gta4l-common/proprietary/vendor/etc/vintf/manifest

cp \
/mnt/vendor/etc/vintf/manifest/android.hardware.health-service.samsung.xml \
vendor/samsung/gta4l-common/proprietary/vendor/etc/vintf/manifest/android.hardware.health@2.1-samsung.xml
```

## BUILD_BROKEN_MISSING_REQUIRED_MODULES

Adicionado:

```make
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true
```

em:

```text
device/samsung/gta4l-common/BoardConfigCommon.mk
```

# 20. Correções do kernel

## OpenSSL 3

Ficheiro:

```text
kernel/samsung/sm6115/scripts/extract-cert.c
```

Desativado suporte PKCS#11 ENGINE.

## suspend.c

```bash
sed -i \
's|if (intr_sync(NULL)) {|if (0) { /* intr_sync(NULL) disabled for Halium bootstrap */|' \
kernel/power/suspend.c
```

## nt36xxx

Ficheiro:

```text
drivers/input/touchscreen/nt36xxx/nt36xxx.c
```

Corrigido warning relacionado com:

```text
struct device_node *dp
```

## Desativar warnings fatais

Adicionar ao Makefile principal:

```make
KBUILD_CFLAGS += -Wno-error
```

# 21. Dependências Fedora

```bash
sudo dnf install openssl-devel
sudo dnf install compat-openssl11-devel
sudo dnf install libxcrypt-compat
sudo dnf install git-lfs
```

# 22. Build realizado

## Configurar ambiente

```bash
source build/envsetup.sh
lunch lineage_gta4l-userdebug
```

## Compilar

```bash
mka bootimage
```

Resultado:

```text
#### build completed successfully ####
```

Imagem gerada:

```text
out/target/product/gta4l/boot.img
```

# 23. Verificação do boot gerado

## Hash

```bash
sha256sum out/target/product/gta4l/boot.img
```

Resultado:

```text
39e67af96b015ec689ae86e504c6cf20acb9e589fe33b430c6ec2849ed77d278
```

## Comparação com boot original

```bash
sha256sum \
/home/gabriel/Área\ de\ Trabalho/UbuntoNoTablet/gta4l_backup_20260610_072545/boot.img
```

Resultado:

```text
9aa9da7cebd98bbf376dd57f2cbe897f232a361f54ba18d5cfcb8ce8ea0dc5ab
```

## Extrair boot

```bash
mkdir -p boot_unpack

unpack_bootimg \
  --boot_img out/target/product/gta4l/boot.img \
  --out boot_unpack
```

## Extrair ramdisk

```bash
mkdir -p boot_ramdisk
cd boot_ramdisk

gzip -dc ../boot_unpack/ramdisk | cpio -idmv
```

## Verificar conteúdo

```bash
find . -maxdepth 3 -type f | sort
```

Resultado observado:

```text
init
fstab.emmc
```

# 24. Estado atual

## Procurar artefactos Halium

```bash
find out/target/product/gta4l \
  -maxdepth 2 \
  -type f | \
grep -E "boot|hybris|halium|recovery|ramdisk"
```

Resultado:

```text
boot.img
ramdisk.img
ramdisk/fstab.emmc
ramdisk/init
```

## Procurar referências internas

```bash
grep -R \
"hybris-boot\|halium-boot\|rootfs\|initrd" \
vendor/halium \
build \
device/samsung/gta4l \
device/samsung/gta4l-common \
-n
```

## Conclusão atual

```text
boot.img compila corretamente.
Não foi gerado halium-boot.img.
Não foi gerado hybris-boot.img.
O ramdisk ainda é um ramdisk Android convencional.
A próxima investigação deve concentrar-se exclusivamente no mecanismo de geração de halium-boot/hybris-boot na árvore Halium 12.
```



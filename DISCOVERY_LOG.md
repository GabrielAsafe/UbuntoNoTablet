# DISCOVERY_LOG.md

## Objetivo

Registar cronologicamente as descobertas feitas durante a preparação do port Ubuntu Touch / Halium para o Samsung Galaxy Tab A7 LTE SM-T505 (`gta4l`).

## 2026-06-10 — Identificação inicial

Comandos utilizados:

```bash
adb shell getprop ro.product.device
adb shell getprop ro.boot.hardware
adb shell uname -a
adb shell cat /proc/version
```

Descobertas:

```text
Codename: gta4l
Plataforma: qcom
Modelo: SM-T505
Kernel: Linux 4.19.325-cip128-st12-perf-g646d493c15ed
Arquitetura: aarch64
```

Interpretação:

O dispositivo é um Samsung Galaxy Tab A7 LTE SM-T505 com plataforma Qualcomm SM6115/Bengal.

## 2026-06-10 — Root ADB

Comando:

```bash
adb root
adb shell id
```

Resultado:

```text
adbd is already running as root
uid=0(root)
```

Conclusão:

ADB root funcional. Isto permitiu fazer backup das partições com `dd`.

## 2026-06-10 — Linha de boot

Comando:

```bash
adb shell cat /proc/cmdline
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

Interpretação:

Confirma plataforma Qualcomm, modelo SM-T505, firmware base T505XXS8CXG1, bootloader desbloqueado, Knox/warranty bit ativado, 3 GB RAM e painel FT8201AB Tianma.

## 2026-06-10 — Device Tree

Comando:

```bash
adb shell 'cat /proc/device-tree/model; echo'
```

Resultado:

```text
Qualcomm Technologies, Inc. Bengal QRD
```

Comando:

```bash
adb shell 'tr "\0" "\n" < /proc/device-tree/compatible'
```

Resultado:

```text
qcom,bengal-qrd
qcom,bengal
qcom,qrd
```

Conclusão:

O kernel identifica a plataforma como Qualcomm Bengal QRD, consistente com Snapdragon 662 / SM6115.

## 2026-06-10 — Layout de partições

Comando:

```bash
adb shell ls -l /dev/block/by-name
```

Conclusões:

```text
Existe boot
Existe recovery
Existe dtbo
Existe vbmeta
Existe vbmeta_samsung
Existe super
Existe userdata
Não existe vendor_boot
```

Impacto:

A ausência de `vendor_boot` simplifica o caminho de boot para Halium. O dispositivo usa `boot + dtbo + vbmeta + super`.

## 2026-06-10 — Verificação das partições críticas

Comando:

```bash
adb shell 'for p in boot recovery dtbo vbmeta vbmeta_samsung efs sec_efs modemst1 modemst2 persist super modem apnhlos fsg fsc cache metadata misc param; do echo "$p -> $(readlink -f /dev/block/by-name/$p 2>/dev/null || echo AUSENTE)"; done'
```

Resultado:

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

Conclusão:

Todas as partições críticas esperadas existem.

## 2026-06-10 — Backup completo

Script usado:

```text
backup_gta4l_safe.sh
```

Diretório criado no tablet:

```text
/sdcard/gta4l_backup_20260610_072545
```

Diretório copiado para o PC:

```text
gta4l_backup_20260610_072545
```

Partições copiadas:

```text
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
```

Tamanhos observados:

```text
boot.img            96 MB
recovery.img        99 MB
dtbo.img            24 MB
vbmeta.img          64 KB
vbmeta_samsung.img  64 KB
efs.img             16 MB
sec_efs.img         16 MB
modemst1.img         4 MB
modemst2.img         4 MB
persist.img         32 MB
modem.img           52 MB
super.img          5,4 GB
```

SHA256:

```bash
sha256sum gta4l_backup_20260610_072545/*.img > gta4l_backup_20260610_072545/SHA256SUMS.txt
```

Conclusão:

Backup crítico concluído com sucesso. Nenhuma partição foi modificada.

## 2026-06-10 — Ambiente do PC

Comandos:

```bash
cat /etc/os-release
uname -a
which lpunpack
which simg2img
which file
```

Resultado:

```text
Fedora Linux 43 Workstation
Kernel 7.0.10-101.fc43.x86_64
lpunpack disponível
simg2img disponível
file disponível
```

Conclusão:

Host adequado para análise offline da `super.img`.

## 2026-06-10 — Análise de super.img

Comandos:

```bash
file gta4l_backup_20260610_072545/super.img
hexdump -C gta4l_backup_20260610_072545/super.img | head -20
lpdump gta4l_backup_20260610_072545/super.img | head -50
```

Resultado:

```text
file: data
lpdump: metadata LP válida
Metadata version: 10.0
Partições lógicas: system, vendor, product, odm
```

Conclusão:

A `super.img` é válida e pode ser extraída diretamente com `lpunpack`, sem `simg2img`.

## 2026-06-10 — Extração das partições lógicas

Comando:

```bash
mkdir extracted
lpunpack gta4l_backup_20260610_072545/super.img extracted
```

Resultado:

```text
odm.img
product.img
system.img
vendor.img
```

Conclusão:

Extração concluída sem erros.

## 2026-06-10 — Sistema de ficheiros

Comandos:

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

Conclusão:

As imagens podem ser montadas diretamente no Linux.

## 2026-06-10 — Montagem das imagens

Comandos:

```bash
sudo mkdir -p /mnt/system /mnt/vendor /mnt/product /mnt/odm
sudo mount -o loop extracted/system.img /mnt/system
sudo mount -o loop extracted/vendor.img /mnt/vendor
sudo mount -o loop extracted/product.img /mnt/product
sudo mount -o loop extracted/odm.img /mnt/odm
df -h | grep /mnt
```

Resultado:

```text
/mnt/system   97% usado
/mnt/vendor   100% usado
/mnt/product  49% usado
/mnt/odm      100% usado
```

Conclusão:

Montagem concluída com sucesso.

## 2026-06-10 — system_ext

Descoberta:

```text
/mnt/system/system_ext -> /system/system_ext
/mnt/system/system/system_ext contém o conteúdo real
```

Arquivos relevantes:

```text
vendor.samsung.hardware.radio@2.0.so
vendor.samsung.hardware.radio@2.1.so
vendor.samsung.hardware.radio@2.2.so
```

Conclusão:

`system_ext` contém bibliotecas Samsung de rádio/RIL relevantes para LTE.

## 2026-06-10 — Inventário inicial do vendor

Descobertas:

```text
1129 bibliotecas .so em /mnt/vendor
57 módulos HAL em /vendor/lib/hw e /vendor/lib64/hw
```

Componentes relevantes:

```text
audio.primary.bengal.so
camera.qcom.so
vulkan.adreno.so
android.hardware.gnss@2.1-impl-qti.so
vendor.samsung.hardware.gnss@2.0-impl-sec.so
```

Binários relevantes:

```text
adsprpcd
cdsprpcd
sscrpcd
cnss-daemon
loc_launcher
qseecomd
rmt_storage
sensors.qti
thermal-engine
secril_config_svc
```

Conclusão:

A base vendor é rica e favorável para Halium.

## 2026-06-10 — VINTF

Arquivos:

```text
/vendor/etc/vintf/manifest.xml
/vendor/etc/vintf/compatibility_matrix.xml
/vendor/etc/vintf/manifest/*.xml
```

Áreas declaradas:

```text
audio
bluetooth
camera
gnss
graphics
health
keymaster
media
power
radio
sensors
thermal
usb
wifi
```

HALs Samsung:

```text
vendor.samsung.hardware.radio
vendor.samsung.hardware.gnss
vendor.samsung.hardware.thermal
vendor.samsung.hardware.security.vaultkeeper
```

HALs Qualcomm/QTI:

```text
vendor.qti.hardware.display.*
vendor.qti.hardware.dsp
vendor.qti.hardware.perf
vendor.qti.hardware.qseecom
vendor.qti.hardware.sensorscalibrate
```

Conclusão:

O vendor declara formalmente as HALs principais que uma camada Halium deverá considerar.

## 2026-06-10 — Kernel config

Comando:

```bash
adb shell zcat /proc/config.gz > kernel.config
```

Verificação:

```bash
grep -E "CONFIG_ANDROID|CONFIG_BINDER|CONFIG_ASHMEM|CONFIG_CGROUP|CONFIG_NAMESPACES|CONFIG_OVERLAY_FS|CONFIG_VT|CONFIG_FB|CONFIG_DRM|CONFIG_INPUT|CONFIG_USB_CONFIGFS" kernel.config | sort
```

Descobertas:

```text
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDERFS=y
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
CONFIG_ASHMEM=y
CONFIG_NAMESPACES=y
CONFIG_OVERLAY_FS=y
CONFIG_CGROUPS=y
CONFIG_USB_CONFIGFS=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_DRM=y
CONFIG_FB=y
# CONFIG_VT is not set
```

Conclusão:

O kernel possui os recursos essenciais para Halium. Não surgiu bloqueador técnico nesta fase.


## 2026-06-10 — Identificação definitiva da ROM

Comando:

sudo cat /mnt/system/system/build.prop | grep lineage

Resultado:

ro.build.flavor=lineage_gta4l-userdebug
ro.lineage.device=gta4l

---

Comando:

sudo cat /mnt/system/system/build.prop | grep ro.build.version.release

Resultado:

ro.build.version.release=16

Conclusão:

A ROM atualmente instalada é LineageOS para gta4l baseada em Android 16.

Impacto:

A estratégia do projeto passa a considerar Android 16 como base real do vendor e dos blobs extraídos.

---

# Atualização de progresso — 2026-06-10
## 2026-06-10 — Pesquisa de reuso LineageOS

Objetivo:

```text
Evitar iniciar um port do zero e verificar se o SM-T505 poderia reaproveitar árvores existentes do LineageOS.
```

Repositórios clonados em `~/halium/reuse`:

```text
android_device_samsung_gta4l
android_device_samsung_gta4lwifi
android_device_samsung_gta4l-common
android_kernel_samsung_sm6115
```

Conclusão:

```text
As árvores oficiais atuais existem para gta4l, gta4lwifi e gta4l-common.
A árvore comum concentra a maior parte do hardware compartilhado.
A árvore gta4l adiciona principalmente LTE/RIL/modem.
```

## 2026-06-10 — Comparação SM-T500 Wi-Fi vs SM-T505 LTE

Ficheiros gerados:

```text
diff_gta4lwifi_vs_gta4l.txt
reuse_keywords_report.txt
```

Conclusão técnica:

```text
SM-T505 / gta4l é essencialmente SM-T500 / gta4lwifi + LTE/RIL/modem.
```

Diferenças relevantes no `gta4l`:

```text
ENABLE_VENDOR_RIL_SERVICE := true
full_base_telephony.mk
init.gta4l.rc
init.vendor.rilchip.rc
init.vendor.rilcommon.rc
rild
secril_config_svc
vendor.samsung.hardware.radio@2.2
vendor.sec.rild.libpath=/vendor/lib64/libsec-ril.so
ro.radio.noril=no
```

Impacto:

```text
O risco principal do port não parece ser o hardware comum, mas sim a integração Halium com vendor Android 12 e a camada RIL Samsung/Qualcomm.
```

## 2026-06-10 — Branches históricas LineageOS

Tentativa inicial:

```text
lineage-19.1 não existe para as árvores públicas consultadas.
```

Branches confirmadas:

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

Conclusão:

```text
A branch mais antiga disponível é lineage-20.
```

## 2026-06-10 — Comparação lineage-20 vs lineage-23.2

Ficheiros gerados:

```text
diff_common_20_vs_23_2.txt
diff_gta4l_20_vs_23_2.txt
diff_gta4lwifi_20_vs_23_2.txt
halium_relevant_20_vs_23_2.txt
```

Conclusões:

```text
A parte relevante para Halium praticamente não mudou entre lineage-20 e lineage-23.2.
As diferenças principais são modernizações de infraestrutura Lineage/Android, como Android.mk para Android.bp, extract-files.py, ajustes VINTF, AVB, SELinux e organização de init.
A estrutura de RIL/LTE do gta4l já existe em lineage-20.
```

Impacto:

```text
lineage-20 é a melhor base histórica disponível para iniciar uma adaptação Halium 12.
```

## 2026-06-10 — Pesquisa por port Halium/Ubuntu Touch existente

Ficheiros gerados:

```text
possible_halium_refs.txt
sm6115_references.txt
```

Resultado:

```text
Não foi encontrada evidência local de port Halium, Ubuntu Touch, UBports, hybris-boot, droid-hal ou Lomiri existente para SM6115/Bengal/gta4l.
```

Conclusão:

```text
O projeto deve avançar como adaptação própria usando LineageOS 20 + blobs Android 12.
```

## 2026-06-10 — Kernel source LineageOS

Comandos executados no kernel source:

```bash
grep -R "^VERSION =" .
grep -R "^PATCHLEVEL =" .
grep -R "CONFIG_ANDROID_BINDER_IPC" .
grep -R "CONFIG_ANDROID_BINDERFS" .
grep -R "CONFIG_ASHMEM" .
grep -R "CONFIG_ION" .
grep -R "CONFIG_DEVTMPFS" .
```

Resultados:

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
O kernel source LineageOS é Linux 4.19 e é tecnicamente favorável para Halium.
```

## 2026-06-10 — Base Android da árvore lineage-20

Resultados observados:

```text
PRODUCT_SHIPPING_API_LEVEL := 29
PRIVATE_BUILD_DESC="gta4lxx-user 12 SP1A.210812.016 T505XXS6CWI2 release-keys"
BUILD_FINGERPRINT := "samsung/gta4lxx/qssi:12/SP1A.210812.016/T505XXS6CWI2:user/release-keys"
proprietary-files.txt: from Samsung package version T505XXS6CWI2
```

Interpretação:

```text
O dispositivo foi lançado originalmente com Android 10, mas a árvore lineage-20 usa blobs Samsung Android 12.
A ROM atual do tablet usa fingerprint mais novo T505XXS8CXG1, também Android 12 vendor.
```

Conclusão:

```text
A direção técnica definida é Halium 12, não Halium 11 e não Android 16 como base inicial.
```

## 2026-06-10 — Criação de cópias locais Halium 12

Cópias criadas:

```text
android_device_samsung_gta4l_halium12
android_device_samsung_gta4l-common_halium12
android_kernel_samsung_sm6115_halium12
```

Motivo:

```text
Preservar as árvores clonadas originais e fazer alterações Halium apenas em cópias locais.
```

## 2026-06-10 — Ajuste inicial de kernel para Halium

Verificação de namespaces:

```text
CONFIG_CGROUP_BPF=y
# CONFIG_PID_NS is not set
```

Fragmento criado:

```text
arch/arm64/configs/vendor/gta4l-halium.config
```

Conteúdo:

```text
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
```

Ajuste aplicado:

```text
BoardConfigCommon.mk passou a usar:
TARGET_KERNEL_CONFIG := vendor/bengal-perf_defconfig vendor/gta4l-halium.config
```

Também foi removido o override em `android_device_samsung_gta4l_halium12/BoardConfig.mk`:

```text
TARGET_KERNEL_CONFIG := gta4l_eur_open_defconfig
```

Conclusão:

```text
O kernel config Halium passou a ser controlado pela árvore common com fragmento adicional Halium.
```

## 2026-06-10 — FSTAB da árvore lineage-20/Halium 12

Ficheiros verificados:

```text
rootdir/etc/fstab.emmc
rootdir/etc/fstab.default
rootdir/etc/fstab.firmware
```

Conclusões:

```text
system, vendor, product e odm são partições lógicas.
persist, efs, sec_efs, metadata e userdata estão presentes.
modem, apnhlos, dsp e bluetooth são montados como firmware Qualcomm.
AVB aparece nos fstabs e terá de ser considerado no método de boot/flash.
```

## 2026-06-10 — Estado do ambiente Halium

Verificação:

```text
repo está instalado em ~/.local/bin/repo.
Nenhuma árvore Halium está inicializada ainda em ~/halium.
Diretórios atuais principais: info, research, reuse, snapshots.
```

Decisão:

```text
Criar uma árvore limpa em ~/halium/halium-12-gta4l e usar cópias locais das árvores device/common/kernel.
```


---

# Atualização de progresso — 2026-06-11
## Geração manual do boot Halium final

Foi concluída a investigação do fluxo de boot para Halium 12 no SM-T505 / `gta4l`.

Conclusões confirmadas:

```text
A árvore não possui target `halium-boot`.
O dispositivo usa BOARD_BOOT_HEADER_VERSION := 2.
Não existe partição `vendor_boot`.
O fluxo correto é boot image clássico: kernel + ramdisk + dtb.
```

Artefactos usados:

```text
out/target/product/gta4l/kernel
out/target/product/gta4l/ramdisk-recovery.img
out/target/product/gta4l/dtb.img
```

O `ramdisk-recovery.cpio` foi identificado como cpio ASCII cru:

```text
out/target/product/gta4l/ramdisk-recovery.cpio: ASCII cpio archive (SVR4 with no CRC)
```

O `ramdisk-recovery.img` foi identificado como gzip comprimido:

```text
out/target/product/gta4l/ramdisk-recovery.img: gzip compressed data
```

Portanto, o ficheiro correto para passar ao `mkbootimg` é:

```text
out/target/product/gta4l/ramdisk-recovery.img
```

não o `.cpio` cru.

## Comando usado para gerar `halium-boot.img`

```bash
out/host/linux-x86/bin/mkbootimg   --kernel out/target/product/gta4l/kernel   --ramdisk out/target/product/gta4l/ramdisk-recovery.img   --cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x4a90000 androidboot.console=ttyMSM0 androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 loop.max_part=7 firmware_class.path=/vendor/firmware_mnt/image"   --base 0x00000000   --pagesize 4096   --kernel_offset 0x00008000   --ramdisk_offset 0x020000000   --tags_offset 0x01E00000   --dtb_offset 0x1F00000   --header_version 2   --dtb out/target/product/gta4l/dtb.img   --output out/target/product/gta4l/halium-boot.img
```

## Resultado final

Foi criado:

```text
out/target/product/gta4l/halium-boot.img
```

Tamanho observado:

```text
32 MB
```

SHA256:

```text
fa4ddd30be54e297d57eb1e761bee7979c1e4c71dbb81600e82d06d836e6838b  out/target/product/gta4l/halium-boot.img
```

Validação com `file`:

```text
Android bootimg, kernel (0x8000), ramdisk (0x20000000), page size: 4096
```

## Validação do ramdisk

O ramdisk foi extraído com:

```bash
mkdir -p /tmp/halium_ramdisk_check
cd /tmp/halium_ramdisk_check
gzip -dc ~/halium/halium-12-gta4l/out/target/product/gta4l/ramdisk-recovery.img | cpio -idmv
```

Foram encontrados componentes Ubuntu Touch / Halium:

```text
system/bin/system-image-upgrader
system/bin/install-system
system/etc/system-image/
system/etc/init/hw/init.rc
```

Trechos relevantes encontrados:

```text
setprop ro.ubuntu.recovery true
System Image Upgrader for Ubuntu Touch
halium-install
ubuntu.img
/data/ubuntu
/var/lib/lxc/android
```

Conclusão:

```text
O `ramdisk-recovery.img` gerado pelo alvo `recoveryramdisk` contém infraestrutura Ubuntu Touch/Halium.
O `halium-boot.img` manual é o equivalente funcional ao target ausente `halium-boot` nesta árvore.
```

## Estado após esta atualização

| Item | Estado |
|---|---|
| `mka bootimage` | concluído |
| `mka recoveryramdisk` | concluído |
| `mka halium-boot` | inexistente / unknown target |
| `ramdisk-recovery.img` | gerado e validado |
| `halium-boot.img` manual | criado |
| SHA256 do `halium-boot.img` | registado |
| Validação de conteúdo Ubuntu Touch/Halium | concluída |
| Primeiro boot real no dispositivo | próxima fase |

## Próxima fase

A próxima etapa do projeto passa a ser:

```text
Primeiro boot Halium / Ubuntu Touch no SM-T505
```

Antes de qualquer flash, preservar a regra de segurança:

```text
1. confirmar backup existente;
2. confirmar hash SHA256;
3. confirmar método de restauração;
4. confirmar comando exato;
5. confirmar partição alvo correta.
```


---

# Atualização — 2026-06-13 — Investigação recovery, AVB e repack

## Objetivo da sessão

Investigar por que `halium-boot`, `recovery Halium` e `recovery-debug` ficavam presos no logo Samsung, evitando novos testes de flash do sistema e concentrando a análise no recovery.

## Estado seguro no fim da sessão

```text
✓ Recovery original restaurado
✓ Sistema voltou a funcionar
✓ Tablet recuperado de bootloop
✓ Nenhuma alteração permanente deixada como estado final
```

## Estrutura de trabalho usada

Diretórios relevantes:

```text
~/halium/test_recovery_compare
~/halium/halium-12-gta4l
~/Área de Trabalho/UbuntoNoTablet/gta4l_backup_20260610_072545
```

Imagens principais usadas:

```text
recovery-stock.img
recovery-debug.img
boot-stock.img
boot-halium.img
```

## Comparação inicial stock vs Halium/debug

Foi confirmado que o recovery stock e o boot stock usam o mesmo kernel:

```text
stock_recovery/kernel == stock_boot/kernel
SHA256: 442492b2f846a5ff664647da2660105e55f6a8a73331a4d3ba1a6a353ade9fdb
```

Também foi confirmado que `recovery-debug` e `halium_boot` usam o mesmo kernel Halium, diferente do stock:

```text
debug_recovery/kernel == halium_boot/kernel
SHA256: 7b7f40bb85...
```

O DTB e o recovery DTBO também diferiam entre stock e Halium:

```text
stock dtb:          86ce145276a684dcaf05470c92074db745cab2b2e19b9c1ad57678a267bfda6a
halium/debug dtb:   57ddc81bd0...

stock recovery_dtbo:        4f152da82efc83b73156768e459c4f546a535df3dc3e55676d9dd062081de627
halium/debug recovery_dtbo: bb1871f157...
```

Conclusão dessa etapa:

```text
O recovery Halium/debug mudava simultaneamente kernel, dtb, recovery_dtbo e ramdisk.
Ainda não era possível isolar a causa do travamento.
```

## Parâmetros reais do recovery stock

`unpack_bootimg --format mkbootimg` mostrou que o recovery stock foi criado com parâmetros específicos:

```text
--header_version 2
--os_version 16.0.0
--os_patch_level 2026-03
--pagesize 0x00001000
--base 0x00000000
--kernel_offset 0x00008000
--ramdisk_offset 0x20000000
--second_offset 0x00000000
--tags_offset 0x01e00000
--dtb_offset 0x0000000001f00000
--board SRPTC24A004
```

Cmdline stock:

```text
console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x4a90000 androidboot.console=ttyMSM0 androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 loop.max_part=7 firmware_class.path=/vendor/firmware_mnt/image
```

## Teste recovery híbrido

Foi criado um recovery híbrido com:

```text
kernel        = stock
dtb           = stock
recovery_dtbo = stock
ramdisk       = recovery-debug Halium
```

A primeira versão foi gerada com `pagesize` incorreto por defaults do `mkbootimg`:

```text
page size: 2048
```

Depois foi reconstruída com os parâmetros reais do stock:

```text
page size: 4096
board: SRPTC24A004
os_version: 16.0.0
os_patch_level: 2026-03
cmdline stock preservada
```

Hashes validados no híbrido:

```text
stock_recovery/kernel == hybrid/kernel
stock_recovery/dtb == hybrid/dtb
stock_recovery/recovery_dtbo == hybrid/recovery_dtbo
debug_recovery/ramdisk == hybrid/ramdisk
```

## Descoberta do footer AVB

O stock tinha 99 MB, enquanto o híbrido reconstruído tinha cerca de 38 MB. A análise mostrou dados extras não-zero após a imagem Android normal e footer AVB no final:

```text
AVBf
```

Foi gerada uma versão com footer AVB e tamanho final igual ao stock:

```text
recovery-hybrid-stockparams-avb.img = 103546880 bytes
```

Diferença importante:

```text
Stock:  Algorithm SHA256_RSA4096, VBMeta size 2240
Híbrido: Algorithm NONE, VBMeta size 512
```

## Resultado do flash do recovery híbrido

O comportamento mudou em relação aos testes anteriores:

Antes apareciam mensagens completas do bootloader, incluindo RPMB/KG/secure download.

Com o híbrido apareceu apenas algo como:

```text
Set Warranty Bit : vbmeta
Set Warranty Bit : recovery
Samsung logo
```

Depois ficava preso no logo Samsung.

Conclusão parcial:

```text
A imagem foi carregada e executada até algum ponto, mas ainda travou.
Kernel/dtb/recovery_dtbo stock não foram suficientes para tornar o ramdisk Halium funcional.
```

## USB durante o travamento

Em um momento foi observado no host:

```text
idVendor=04e8
idProduct=685d
Product: SM6150
Manufacturer: Samsung
cdc_acm: USB Abstract Control Model driver
```

Depois houve desconexão.

Interpretação:

```text
O kernel/recovery chegou a enumerar USB por um instante, mas não manteve ADB ativo.
```

## Análise do ramdisk Halium

O `init.rc` do ramdisk Halium/debug foi inspecionado. Foram observadas diferenças importantes contra o stock:

```text
Ausência de binderfs no init
Ausência de start servicemanager no ponto equivalente
Ausência de class_start hal
Diferenças em servicemanager.recovery.rc
Diferenças em init.qcom.recovery.rc
Diferenças no health-service samsung recovery
```

O diff confirmou remoções relevantes:

```text
binderfs removido
start servicemanager removido
class_start hal removido
servicemanager.recovery.rc diferente
android.hardware.health-service.samsung-recovery diferente
```

Conclusão parcial:

```text
O ramdisk Halium 12 é estruturalmente diferente e provavelmente incompatível com o recovery moderno usado pela base LineageOS/Android 16.
```

## Teste fix1 no ramdisk Halium

Foi criado `ramdisk-fix1.img` tentando restaurar minimamente:

```text
start servicemanager
class_start hal
correção do bloco fastboot incompleto
ADB no boot
```

Resultado:

```text
Mesmo comportamento: trava no logo Samsung.
```

Conclusão:

```text
Correções simples no init.rc Halium não resolvem.
O problema é mais estrutural do que apenas uma linha de init.
```

## Teste stock-debug baseado no ramdisk stock

Foi criado um recovery baseado no ramdisk stock, alterando minimamente:

```text
ro.debuggable=1
ro.force.debuggable=1
ro.adb.secure=0
persist.sys.usb.config=adb
setprop service.adb.root 1
setprop sys.usb.config adb
start adbd
```

Validações:

```text
kernel stock preservado
dtb stock preservado
recovery_dtbo stock preservado
ramdisk modificado validado
AVB footer presente
tamanho final 103546880 bytes
```

Resultado no dispositivo:

```text
Mesmo problema: logo Samsung, sem ADB, sem lsusb.
```

## Teste clean repack do stock

Foi feita uma prova de controle: extrair o ramdisk stock e reempacotar sem alterações reais, usando os mesmos componentes stock e AVB footer NONE.

Resultado:

```text
Bootloop
```

Depois o recovery original foi restaurado e o sistema voltou a funcionar.

Conclusão crítica:

```text
Mesmo um repack limpo do recovery stock não é equivalente ao recovery Samsung original.
O fluxo mkbootimg + avbtool add_hash_footer Algorithm NONE não reproduz a imagem aceita/funcional.
```

## AVB do recovery stock

`avbtool info_image --image recovery-stock.img` mostrou:

```text
Footer version: 1.0
Image size: 103546880 bytes
Original image size: 41349120 bytes
VBMeta offset: 41349120
VBMeta size: 2240 bytes
Algorithm: SHA256_RSA4096
Rollback Index: 1
Public key sha1: 2597c218aae470a130f61162feaae70afd97f011
Partition Name: recovery
Salt: 442492b2f846a5ff664647da2660105e55f6a8a73331a4d3ba1a6a353ade9fdb
Digest: 5593a5985bec726491551ea2cabbc338ce89872471a94fa2d84cd262b0e760d2
Prop: com.android.build.recovery.fingerprint -> samsung/lineage_gta4l/gta4l:16/BP4A.251205.006/a4e156c058:userdebug/release-keys
```

`avbtool verify_image` verificou a estrutura RSA, mas acusou mismatch do digest:

```text
vbmeta: Successfully verified footer and SHA256_RSA4096 vbmeta struct in recovery-stock.img
sha256 digest of recovery.img does not match digest in descriptor
```

Interpretação atual:

```text
O footer/vbmeta stock é RSA válido, mas a verificação de hash pelo avbtool local não casa com o conteúdo como interpretado.
Pode haver detalhe específico Samsung/extração/tamanho original que ainda não entendemos.
```

## Conclusões da sessão

1. O recovery stock original é o único comprovadamente funcional.
2. O recovery Halium/debug trava.
3. O híbrido com kernel/dtb/dtbo stock e ramdisk Halium também trava.
4. Corrigir init.rc Halium de forma simples não resolve.
5. Modificar o ramdisk stock e reempacotar também trava.
6. Reempacotar o stock sem alterações causou bootloop.
7. Portanto, além de problemas no ramdisk Halium, existe uma limitação crítica no método de repack/assinatura usado.
8. O fluxo `mkbootimg + avbtool add_hash_footer` com `Algorithm: NONE` não reproduz fielmente o recovery stock.

## Hipóteses atualizadas

```text
Alta probabilidade: ramdisk Halium 12 incompatível com recovery moderno LineageOS/Android 16.
Alta probabilidade: repack atual não reproduz AVB/estrutura Samsung funcional.
Média probabilidade: recovery exige assinatura/metadata AVB semelhante ao stock RSA.
Baixa probabilidade: kernel/dtb/dtbo sejam a causa principal, pois o híbrido usou os componentes stock.
```

## Direção recomendada após esta sessão

```text
1. Não continuar flashes de recovery reconstruído até entender o formato/assinatura.
2. Preservar o recovery stock original como base segura.
3. Investigar como LineageOS/Android 16 gera recovery.img para gta4l.
4. Procurar método de assinatura/repack usado pela build funcional.
5. Investigar alternativas de debug que não dependam de reempacotar recovery, como logs persistentes, UART, ramo de boot normal ou initramfs de boot.
```

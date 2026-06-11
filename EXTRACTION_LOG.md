# EXTRACTION_LOG.md

## Objetivo

Documentar a análise e extração da partição dinâmica `super.img`, incluindo formato, partições lógicas, montagem, inventário de blobs e VINTF.

## Ambiente

Host:

```text
Fedora Linux 43 Workstation
Kernel 7.0.10-101.fc43.x86_64
```

Ferramentas disponíveis:

```text
lpunpack
lpdump
simg2img
file
blkid
hexdump
mount
```

## Backup analisado

```text
gta4l_backup_20260610_072545/super.img
```

Tamanho observado:

```text
5,4 GB
```

## 2026-06-10 — Análise da super partition

Comando:

```bash
lpdump gta4l_backup_20260610_072545/super.img | head -50
```

Resultado:

```text
Metadata version: 10.0
Metadata max size: 65536 bytes
Metadata slot count: 2
```

Partições lógicas identificadas:

```text
system
vendor
product
odm
```

Layout observado:

```text
system  -> 3129400 setores
vendor  -> 1082384 setores
product -> 4935912 setores
odm     -> 3320 setores
```

Conclusão:

A `super.img` é válida, possui metadata LP íntegra e não precisa de `simg2img`.

## 2026-06-10 — Extração

Comando:

```bash
mkdir extracted
lpunpack gta4l_backup_20260610_072545/super.img extracted
```

Resultado:

```text
Attempting to extract partition 'odm'...
Attempting to extract partition 'product'...
Attempting to extract partition 'vendor'...
Attempting to extract partition 'system'...
```

Arquivos gerados:

```text
extracted/odm.img
extracted/product.img
extracted/system.img
extracted/vendor.img
```

Tamanhos:

```text
odm.img      1,7 MB
vendor.img   529 MB
system.img   1,5 GB
product.img  2,4 GB
```

Observação:

Não existe `system_ext.img` separado.

## 2026-06-10 — Sistema de ficheiros

Comandos:

```bash
file extracted/*.img
blkid extracted/*.img
```

Resultado:

```text
odm.img     TYPE="ext4"
product.img TYPE="ext4"
system.img  TYPE="ext4"
vendor.img  TYPE="ext4"
```

Conclusão:

As imagens não usam EROFS. Podem ser montadas diretamente em Linux.

## 2026-06-10 — Montagem

Comandos:

```bash
sudo mkdir -p /mnt/system /mnt/vendor /mnt/product /mnt/odm

sudo mount -o loop extracted/system.img /mnt/system
sudo mount -o loop extracted/vendor.img /mnt/vendor
sudo mount -o loop extracted/product.img /mnt/product
sudo mount -o loop extracted/odm.img /mnt/odm
```

Verificação:

```bash
df -h | grep /mnt
```

Uso observado:

```text
/mnt/system   1,5 GB total, 97% usado
/mnt/vendor   520 MB total, 100% usado
/mnt/product  2,3 GB total, 49% usado
/mnt/odm      1,5 MB total, 100% usado
```

## 2026-06-10 — Estrutura montada

`/mnt/system` contém diretórios compatíveis com Android dynamic partitions:

```text
system
system_ext
product
vendor
odm
system_dlkm
vendor_dlkm
odm_dlkm
```

`/mnt/system/system_ext` é symlink para:

```text
/system/system_ext
```

O conteúdo real está em:

```text
/mnt/system/system/system_ext
```

Arquivos relevantes em `system_ext`:

```text
system_ext/bin/hwservicemanager
system_ext/lib64/vendor.samsung.hardware.radio@2.0.so
system_ext/lib64/vendor.samsung.hardware.radio@2.1.so
system_ext/lib64/vendor.samsung.hardware.radio@2.2.so
system_ext/lib/vendor.samsung.hardware.radio@2.0.so
system_ext/lib/vendor.samsung.hardware.radio@2.1.so
system_ext/lib/vendor.samsung.hardware.radio@2.2.so
```

Interpretação:

`system_ext` contém bibliotecas Samsung importantes para rádio/RIL.

## 2026-06-10 — Vendor

Contagem:

```text
1129 bibliotecas .so em /mnt/vendor
```

HAL modules:

```text
/vendor/lib64/hw: 30 ficheiros
/vendor/lib/hw:   27 ficheiros
Total:            57 módulos HAL
```

HALs relevantes:

```text
audio.primary.bengal.so
audio.primary.default.so
audio.bluetooth.default.so
audio.usb.default.so
camera.qcom.so
vulkan.adreno.so
gralloc.default.so
power.default.so
vibrator.default.so
android.hardware.gnss@2.1-impl-qti.so
android.hardware.graphics.mapper@4.0-impl-qti-display.so
vendor.samsung.hardware.gnss@2.0-impl-sec.so
vendor.qti.hardware.qseecom@1.0-impl.so
vendor.qti.hardware.sensorscalibrate@1.0-impl.so
```

Binários importantes em `/vendor/bin`:

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
xtra-daemon
secril_config_svc
pd-mapper
qrtr-ns
tftp_server
time_daemon
```

Serviços em `/vendor/bin/hw` identificados no inventário:

```text
android.hardware.audio.service
android.hardware.bluetooth@1.0-service-qti
android.hardware.camera.provider-service.samsung
android.hardware.gnss@2.1-service-qti
android.hardware.health-service.samsung
android.hardware.keymaster@4.0-service.samsung
android.hardware.power-service-qti
android.hardware.sensors@2.0-service.multihal
android.hardware.usb-service.qti
android.hardware.wifi-service
rild
hostapd
wpa_supplicant
vendor.qti.hardware.display.allocator-service
vendor.qti.hardware.display.composer-service
vendor.qti.hardware.perf@2.2-service
vendor.qti.hardware.qseecom@1.0-service
vendor.samsung.hardware.thermal@1.0-service
```

## 2026-06-10 — Init scripts

Arquivo gerado:

```text
vendor_init_rc.txt
```

Serviços relevantes:

```text
android.hardware.audio.service.rc
android.hardware.bluetooth@1.0-service-qti.rc
android.hardware.camera.provider-service.samsung.rc
android.hardware.gnss@2.1-service-qti.rc
android.hardware.health-service.samsung.rc
android.hardware.keymaster@4.0-service.samsung.rc
android.hardware.power-service-qti.rc
android.hardware.sensors@2.0-service-multihal.rc
android.hardware.usb-service.qti.rc
android.hardware.wifi-service.rc
android.hardware.wifi.supplicant-service.rc
init.vendor.rilchip.rc
init.vendor.rilcommon.rc
vendor.qti.hardware.display.allocator-service.rc
vendor.qti.hardware.display.composer-service.rc
vendor.samsung.hardware.thermal@1.0-service.rc
wifi_qcom.rc
wifi_sec.rc
```

Interpretação:

O vendor tem scripts de init suficientes para levantar áudio, câmera, GNSS, rádio, Wi-Fi, sensores, display e serviços Qualcomm/Samsung.

## 2026-06-10 — VINTF

Arquivos encontrados:

```text
/vendor/etc/vintf/manifest.xml
/vendor/etc/vintf/compatibility_matrix.xml
/vendor/etc/vintf/manifest/*.xml
```

HALs Android declaradas:

```text
android.hardware.audio
android.hardware.audio.effect
android.hardware.bluetooth
android.hardware.bluetooth.audio
android.hardware.camera.provider
android.hardware.cas
android.hardware.drm
android.hardware.gatekeeper
android.hardware.gnss
android.hardware.graphics.allocator
android.hardware.graphics.composer
android.hardware.graphics.mapper
android.hardware.health
android.hardware.keymaster
android.hardware.media.omx
android.hardware.memtrack
android.hardware.power
android.hardware.radio
android.hardware.radio.config
android.hardware.radio.deprecated
android.hardware.sensors
android.hardware.tetheroffload.config
android.hardware.tetheroffload.control
android.hardware.thermal
android.hardware.usb
android.hardware.wifi
android.hardware.wifi.hostapd
android.hardware.wifi.supplicant
```

HALs Samsung:

```text
vendor.samsung.hardware.gnss
vendor.samsung.hardware.radio
vendor.samsung.hardware.radio.bridge
vendor.samsung.hardware.radio.channel
vendor.samsung.hardware.security.vaultkeeper
vendor.samsung.hardware.thermal
```

HALs Qualcomm/QTI:

```text
com.qualcomm.qti.ant
vendor.qti.data.factory
vendor.qti.hardware.alarm
vendor.qti.hardware.bluetooth_audio
vendor.qti.hardware.bluetooth_sar
vendor.qti.hardware.btconfigstore
vendor.qti.hardware.camera.postproc
vendor.qti.hardware.capabilityconfigstore
vendor.qti.hardware.data.latency
vendor.qti.hardware.display.allocator
vendor.qti.hardware.display.composer
vendor.qti.hardware.display.mapper
vendor.qti.hardware.dsp
vendor.qti.hardware.perf
vendor.qti.hardware.qseecom
vendor.qti.hardware.sensorscalibrate
vendor.qti.hardware.tui_comm
vendor.qti.hardware.vpp
vendor.qti.hardware.wifidisplaysession
```

Conclusão:

A base vendor é tecnicamente favorável para Halium. Existem blobs e serviços para áudio, display, GPU, rádio, GNSS, sensores, Wi-Fi, Bluetooth, USB, thermal e câmera.

## Arquivos gerados nesta fase

```text
INVENTORY_vendor_files.txt
INVENTORY_product_files.txt
INVENTORY_system_files.txt
INVENTORY_odm_files.txt
vendor_bins.txt
vendor_hw_lib.txt
vendor_hw_lib64.txt
vendor_init_rc.txt
```

## Desmontagem segura

Quando a análise terminar:

```bash
sudo umount /mnt/system
sudo umount /mnt/vendor
sudo umount /mnt/product
sudo umount /mnt/odm
```


---

# Atualização de progresso — 2026-06-10
## 2026-06-10 — Relação com a base LineageOS 20 / Halium 12

Após a extração dos blobs da ROM funcional, foi feita comparação com as árvores LineageOS disponíveis.

Conclusão relevante para extração/vendor:

```text
A árvore LineageOS 20 para gta4l usa blobs Samsung Android 12 do pacote T505XXS6CWI2.
O tablet atual usa firmware/vendor Samsung Android 12 mais novo, T505XXS8CXG1.
```

Impacto:

```text
Os blobs extraídos da ROM atual são compatíveis em geração com a árvore LineageOS 20 usada como base Halium 12, embora sejam de pacote Samsung mais recente.
```

## 2026-06-10 — Confirmação de componentes RIL no vendor e system_ext

A análise offline confirmou que o vendor e o system_ext contêm elementos relevantes para LTE/RIL:

```text
/vendor/bin/hw/rild
/vendor/bin/secril_config_svc
/vendor/etc/init/init.vendor.rilchip.rc
/vendor/etc/init/init.vendor.rilcommon.rc
/system/system_ext/lib64/vendor.samsung.hardware.radio@2.0.so
/system/system_ext/lib64/vendor.samsung.hardware.radio@2.1.so
/system/system_ext/lib64/vendor.samsung.hardware.radio@2.2.so
```

Conclusão:

```text
A ROM funcional possui os componentes proprietários necessários para testar LTE/RIL no futuro port Halium.
```

## 2026-06-10 — Correlação com fstabs LineageOS 20

Foram comparadas as partições extraídas com os fstabs da árvore `android_device_samsung_gta4l-common_halium12`.

Fstabs verificados:

```text
rootdir/etc/fstab.emmc
rootdir/etc/fstab.default
rootdir/etc/fstab.firmware
```

Conclusões:

```text
system, vendor, product e odm correspondem às partições lógicas extraídas da super.img.
modem, apnhlos, dsp e bluetooth são tratados como partições de firmware.
persist, efs e sec_efs são montados separadamente e devem ser preservados.
metadata e userdata aparecem no fstab e são relevantes para boot/encriptação.
```

Observação:

```text
As entradas de fstab mantêm flags AVB, como avb, avb=vbmeta e avb=vbmeta_system. Isto terá impacto no método de boot/flash, mas não impede a análise offline.
```

## Estado pós-extração

```text
As imagens extraídas continuam a ser usadas como fonte de blobs e referência vendor.
Nenhuma partição do tablet foi modificada.
Nenhum flash foi realizado.
A etapa seguinte é integrar as árvores locais numa workspace Halium 12 limpa.
```


---

# Atualização — 2026-06-11
## Relação da extração com o boot Halium

A análise de `super.img` continua válida como base de vendor/blobs. A nova etapa de boot confirmou que o dispositivo não depende de `vendor_boot`, e que o ramdisk Ubuntu Touch/Halium pode ser empacotado diretamente num `boot.img` clássico junto com kernel e DTB.

Artefacto final criado fora da `super.img`:

```text
out/target/product/gta4l/halium-boot.img
```

SHA256:

```text
fa4ddd30be54e297d57eb1e761bee7979c1e4c71dbb81600e82d06d836e6838b
```

Isto não altera a extração da `super.img`; apenas fecha a etapa de geração do boot Halium inicial.

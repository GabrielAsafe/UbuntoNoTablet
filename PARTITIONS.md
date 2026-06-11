# PARTITIONS.md

## Objetivo

Documentar o layout de partições identificado em `/dev/block/by-name` no Samsung Galaxy Tab A7 LTE SM-T505 (`gta4l`).

Comando usado:

```bash
adb shell ls -l /dev/block/by-name
```

## Conclusões principais

O dispositivo usa armazenamento eMMC (`mmcblk0`) e possui partição dinâmica `super`.

Não foi encontrada partição `vendor_boot`.

Isto indica um layout de boot mais simples para Halium:

```text
boot
dtbo
vbmeta
vbmeta_samsung
super
```

## Partições críticas de boot

| Nome | Bloco | Função |
|---|---|---|
| boot | /dev/block/mmcblk0p69 | kernel + ramdisk Android |
| recovery | /dev/block/mmcblk0p70 | recovery dedicada |
| dtbo | /dev/block/mmcblk0p57 | Device Tree Overlays |
| vbmeta | /dev/block/mmcblk0p11 | Android Verified Boot |
| vbmeta_samsung | /dev/block/mmcblk0p19 | AVB Samsung |

## Partição dinâmica

| Nome | Bloco | Função |
|---|---|---|
| super | /dev/block/mmcblk0p73 | contém partições lógicas Android |

Partições lógicas encontradas dentro de `super.img`:

| Nome | Observação |
|---|---|
| system | extraída como `system.img` |
| vendor | extraída como `vendor.img` |
| product | extraída como `product.img` |
| odm | extraída como `odm.img` |

`system_ext` não existe como partição lógica separada, mas existe como diretório dentro de `system.img`.

## Partições críticas para LTE/modem

| Nome | Bloco | Função |
|---|---|---|
| efs | /dev/block/mmcblk0p64 | IMEI, identidade e dados de rádio |
| sec_efs | /dev/block/mmcblk0p63 | extensão Samsung da EFS |
| modemst1 | /dev/block/mmcblk0p61 | dados persistentes do modem |
| modemst2 | /dev/block/mmcblk0p62 | espelho do modemst1 |
| persist | /dev/block/mmcblk0p37 | calibrações, Wi-Fi/Bluetooth/sensores/modem |

## Partições relacionadas a firmware/modem

| Nome | Bloco |
|---|---|
| modem | /dev/block/mmcblk0p36 |
| apnhlos | /dev/block/mmcblk0p42 |
| fsg | /dev/block/mmcblk0p59 |
| fsc | /dev/block/mmcblk0p60 |

## Partições auxiliares preservadas quando disponíveis

| Nome | Bloco |
|---|---|
| cache | /dev/block/mmcblk0p76 |
| metadata | /dev/block/mmcblk0p45 |
| misc | /dev/block/mmcblk0p46 |
| param | /dev/block/mmcblk0p44 |

## Partições observadas adicionais

O dispositivo também possui muitas partições Qualcomm/Samsung, incluindo:

```text
xbl
xblbak
xbl_config
xbl_configak
tz
rpm
hyp
keymaster
cmnlib
cmnlib64
abl
bluetooth
dsp
qupfw
cdt
oem
persistent
fota
frp
keystore
rawdump
splash
devinfo
uefivarstore
reserved
bota
userdata
```

Estas não devem ser alteradas durante o port inicial.

## Prioridade de backup

Prioridade máxima:

```text
efs
sec_efs
modemst1
modemst2
persist
boot
recovery
dtbo
vbmeta
vbmeta_samsung
```

Prioridade alta:

```text
super
modem
apnhlos
fsg
fsc
```

Prioridade média:

```text
metadata
misc
param
cache
```

## Estado do backup

Backup realizado com sucesso em:

```text
gta4l_backup_20260610_072545
```

SHA256 gerado em:

```text
gta4l_backup_20260610_072545/SHA256SUMS.txt
```


---

# Atualização de progresso — 2026-06-10
## FSTAB da árvore LineageOS 20 / Halium 12

Ficheiros verificados na cópia local:

```text
~/halium/reuse/android_device_samsung_gta4l-common_halium12/rootdir/etc/fstab.emmc
~/halium/reuse/android_device_samsung_gta4l-common_halium12/rootdir/etc/fstab.default
~/halium/reuse/android_device_samsung_gta4l-common_halium12/rootdir/etc/fstab.firmware
```

Confirmações:

```text
system  -> partição lógica
vendor  -> partição lógica
product -> partição lógica
odm     -> partição lógica
```

Partições persistentes/críticas presentes nos fstabs:

```text
/data
/metadata
/mnt/vendor/persist
/mnt/vendor/efs
/efs
/misc
```

Partições de firmware presentes:

```text
/vendor/dsp
/vendor/firmware_mnt
/vendor/firmware-modem
/vendor/bt_firmware
```

Mapeamento observado:

```text
dsp       -> /vendor/dsp
apnhlos   -> /vendor/firmware_mnt
modem     -> /vendor/firmware-modem
bluetooth -> /vendor/bt_firmware
```

Observação importante:

```text
Os fstabs contêm flags AVB. Para boot Halium será necessário considerar vbmeta/vbmeta_samsung e o estado AVB orange antes de qualquer flash.
```

## Impacto para Halium

```text
O layout de partições é compatível com a estratégia Halium 12 usando super/dynamic partitions.
Não existe vendor_boot, o que simplifica a etapa inicial de boot.
Atenção máxima continua necessária para efs, sec_efs, modemst1, modemst2 e persist.
```


---

# Atualização — 2026-06-11
## Impacto do layout de partições no boot Halium

A ausência de `vendor_boot` foi confirmada como relevante para o fluxo final.

Como o dispositivo usa `BOARD_BOOT_HEADER_VERSION := 2`, o boot Halium foi criado como imagem clássica para a partição `boot`:

```text
kernel + ramdisk-recovery.img + dtb.img -> halium-boot.img
```

Artefacto:

```text
out/target/product/gta4l/halium-boot.img
SHA256: fa4ddd30be54e297d57eb1e761bee7979c1e4c71dbb81600e82d06d836e6838b
```

A próxima fase envolve teste/flash controlado. A partição alvo provável para o primeiro teste é `boot`, mas nenhum comando de escrita deve ser executado sem reconfirmar backup, hash, método de restauração e comando exato.

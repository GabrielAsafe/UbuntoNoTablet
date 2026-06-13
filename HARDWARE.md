# HARDWARE.md

## Identificação

| Item | Valor |
|---|---|
| Modelo comercial | Samsung Galaxy Tab A7 LTE |
| Modelo Samsung | SM-T505 |
| Codename | gta4l |
| Plataforma | Qualcomm |
| Família SoC | Bengal |
| SoC | Qualcomm Snapdragon 662 / SM6115 |
| Arquitetura | ARM64 / aarch64 |
| RAM | 3 GB |
| GPU | Adreno 610 |

## Sistema atual observado

| Item | Valor |
|---|---|
| ROM | LineageOS moderno para gta4l |
| Firmware base indicado por fingerprint | T505XXS8CXG1 |
| Android vendor base | Samsung Android 12 |
| Bootloader | desbloqueado |
| AVB state | orange |
| Warranty bit / Knox | 1 |
| Carrier/sales code observado | EUX / TPH |

## Device Tree

Comando usado:

```bash
adb shell 'cat /proc/device-tree/model; echo'
```

Resultado:

```text
Qualcomm Technologies, Inc. Bengal QRD
```

Comando usado:

```bash
adb shell 'tr "\0" "\n" < /proc/device-tree/compatible'
```

Resultado:

```text
qcom,bengal-qrd
qcom,bengal
qcom,qrd
```

Interpretação:

O kernel identifica a plataforma como Qualcomm Bengal QRD, consistente com SM6115 / Snapdragon 662.

## Display

Identificado em `/proc/cmdline`:

```text
msm_drm.dsi_display0=qcom,mdss_dsi_ft8201ab_tianma_tianma_video
```

Interpretação:

Painel DSI FT8201AB Tianma.

## Kernel

Comando usado:

```bash
adb shell uname -a
adb shell cat /proc/version
```

Resultado consolidado:

```text
Linux 4.19.325-cip128-st12-perf-g646d493c15ed
SMP PREEMPT
Sun Apr 5 10:01:17 UTC 2026
aarch64
Android Clang 21.0.0
LLD 21.0.0
```

Interpretação:

Kernel Samsung/Qualcomm 4.19 moderno, adequado para tentativa Halium. O kernel já inclui recursos Android importantes para Binder, Ashmem, namespaces, cgroups, OverlayFS e USB ConfigFS.

## Configurações de kernel relevantes

Arquivo gerado:

```text
kernel.config
```

Comando usado:

```bash
adb shell zcat /proc/config.gz > kernel.config
```

Trechos relevantes:

```text
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDERFS=y
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
CONFIG_ASHMEM=y
CONFIG_NAMESPACES=y
CONFIG_OVERLAY_FS=y
CONFIG_CGROUPS=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_USB_CONFIGFS=y
CONFIG_DRM=y
CONFIG_FB=y
```

Observação:

```text
# CONFIG_VT is not set
```

Isto é normal em kernel Android e não é considerado bloqueador para Halium.

## Componentes de hardware com blobs encontrados

| Componente | Evidência |
|---|---|
| Áudio | `audio.primary.bengal.so`, ACDB data |
| GPU | `vulkan.adreno.so`, QTI display HAL |
| Câmara | `camera.qcom.so`, Samsung camera provider |
| GNSS | QTI GNSS + Samsung GNSS HAL |
| LTE/RIL | Samsung radio HALs, `rild`, `secril_config_svc` |
| Wi-Fi | `cnss-daemon`, Wi-Fi HALs |
| Bluetooth | QTI Bluetooth HALs |
| Sensores | `sensors.qti`, sensors multihal |
| Thermal | Samsung thermal service |
| USB | QTI USB service |


## Sistema Operacional Atual

ROM:

LineageOS 23.x

Android:

16

Build Flavor:

lineage_gta4l-userdebug

Device:

gta4l

Observação:

O dispositivo não está a executar firmware Samsung OneUI. A base atual é LineageOS Android 16.

---

# Atualização de progresso — 2026-06-10
## Reuso de código LineageOS

Árvores confirmadas:

```text
android_device_samsung_gta4l
android_device_samsung_gta4lwifi
android_device_samsung_gta4l-common
android_kernel_samsung_sm6115
```

Branches disponíveis:

```text
lineage-20
lineage-21
lineage-22.x
lineage-23.x
```

Branch escolhida como base histórica:

```text
lineage-20
```

Motivo:

```text
É a branch mais antiga disponível publicamente para estas árvores e já contém suporte gta4l com LTE/RIL.
```

## Base Android / firmware

A árvore `lineage-20` para `gta4l` usa:

```text
Android 12 / SP1A.210812.016
Samsung package T505XXS6CWI2
```

O dispositivo atual usa:

```text
T505XXS8CXG1
```

Interpretação:

```text
Ambas as bases vendor são Samsung Android 12. A estratégia definida é Halium 12 com lineage-20 como base técnica, usando blobs Android 12.
```

## Kernel source LineageOS

Kernel source confirmado:

```text
android_kernel_samsung_sm6115
Linux 4.19
```

Configurações encontradas nos defconfigs Bengal:

```text
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDERFS=y
CONFIG_ASHMEM=y
CONFIG_ION=y
CONFIG_DEVTMPFS=y
CONFIG_CGROUP_BPF=y
```

Ajuste Halium necessário encontrado:

```text
# CONFIG_PID_NS is not set
```

Fragmento criado:

```text
arch/arm64/configs/vendor/gta4l-halium.config
```

com namespaces e opções essenciais para Halium.

## Avaliação de viabilidade atualizada

| Área | Estado |
|---|---|
| Hardware SM6115/Bengal | favorável |
| Kernel 4.19 | favorável |
| Binder/BinderFS/Ashmem/ION | favorável |
| Device tree LineageOS | favorável |
| Common tree LineageOS | favorável |
| LTE/RIL na árvore gta4l | favorável |
| Vendor Android 12 | favorável |
| Port Halium existente encontrado | não |
| Estratégia escolhida | Halium 12 com cópias locais |


---

# Atualização — 2026-06-11
## Boot Halium

O hardware/boot layout foi confirmado como compatível com boot image clássico:

```text
BOARD_BOOT_HEADER_VERSION := 2
boot = kernel + ramdisk + dtb
sem vendor_boot
```

Foi criado manualmente um `halium-boot.img` usando o kernel compilado, `ramdisk-recovery.img` gzipado e `dtb.img`.

Resultado:

```text
out/target/product/gta4l/halium-boot.img
Tamanho: 32M
SHA256: fa4ddd30be54e297d57eb1e761bee7979c1e4c71dbb81600e82d06d836e6838b
```

O ramdisk contém componentes Ubuntu Touch/Halium, incluindo `system-image-upgrader`, `install-system` e `ro.ubuntu.recovery=true`.


---

# Atualização — 2026-06-13 — Observações de recovery/boot

O kernel/dtb/recovery_dtbo stock foram isolados e testados em imagens híbridas. O híbrido com estes componentes stock e ramdisk Halium alterou o comportamento visual do boot, mas ainda travou no logo Samsung.

Conclusão para hardware/kernel:

```text
Baixa probabilidade de o kernel, DTB ou recovery_dtbo stock serem o problema principal do travamento do recovery Halium.
Alta probabilidade de haver incompatibilidade no ramdisk/userspace Halium e/ou no método de repack/assinatura da imagem recovery.
```

USB enumerou uma vez como Samsung SM6150 (`04e8:685d`) durante uma tentativa, mas não manteve ADB.

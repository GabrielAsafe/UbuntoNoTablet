# Ubuntu Touch / Halium no Samsung Galaxy Tab A7 LTE (SM-T505)

## Objetivo

Documentar e preparar uma tentativa de port do Ubuntu Touch, via Halium, para o Samsung Galaxy Tab A7 LTE SM-T505 (`gta4l`), preservando a capacidade de recuperação do sistema atual.

O objetivo atual não é instalar Ubuntu Desktop puro nem Linux mainline puro. O caminho técnico definido é:

```text
Hardware Samsung SM-T505
↓
Kernel Samsung / Qualcomm 4.19
↓
Device tree LineageOS / gta4l
↓
Vendor blobs extraídos da ROM funcional
↓
Halium
↓
Ubuntu Touch / UBports
```

## Estado atual

Data do último levantamento: 2026-06-10

### Fases

| Fase | Estado |
|---|---|
| Documentação inicial | concluída |
| Identificação de hardware | concluída |
| Descoberta de partições | concluída |
| Backup crítico | concluído |
| Verificação SHA256 do backup | concluída |
| Extração da `super.img` | concluída |
| Montagem das imagens extraídas | concluída |
| Inventário inicial de vendor/blobs | concluído |
| Inventário VINTF | concluído |
| Análise básica do kernel | concluída |
| Preparação do ambiente Halium | próxima etapa |
| Build `halium-boot.img` | pendente |
| Primeiro boot Halium | pendente |
| Ubuntu Touch rootfs | pendente |

## Dispositivo

| Item | Valor |
|---|---|
| Modelo comercial | Samsung Galaxy Tab A7 LTE |
| Modelo Samsung | SM-T505 |
| Codename | gta4l |
| SoC | Qualcomm Snapdragon 662 / SM6115 |
| Plataforma | Qualcomm Bengal |
| Arquitetura | ARM64 / aarch64 |
| RAM | 3 GB |
| GPU | Adreno 610 |
| Display identificado | FT8201AB Tianma |
| Firmware base | T505XXS8CXG1 |
| Estado AVB | orange |
| Bootloader | desbloqueado |
| Knox/warranty bit | 1 |

## Sistema atual

O sistema funcional usado como base de extração é LineageOS moderno no dispositivo `gta4l`. Apesar de o sistema Android ser recente, o fingerprint indica blobs Samsung baseados no firmware Android 12 `T505XXS8CXG1`.

Isto é importante porque permite tentar Halium 12 usando blobs de uma base Samsung Android 12, mesmo estando a ROM atual em uma base Android/Lineage mais moderna.

## Kernel

| Item | Valor |
|---|---|
| Versão | Linux 4.19.325-cip128-st12-perf-g646d493c15ed |
| Tipo | SMP PREEMPT |
| Data de build | Sun Apr 5 10:01:17 UTC 2026 |
| Toolchain | Android Clang 21.0.0 |
| Linker | LLD 21.0.0 |
| Arquitetura | aarch64 |

Configurações importantes confirmadas em `kernel.config`:

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

Observação: `CONFIG_VT` não está ativado, o que é normal em kernels Android modernos e não é considerado bloqueador para Halium/Ubuntu Touch.

## Backup

Backup concluído em:

```text
gta4l_backup_20260610_072545
```

Tamanho total transferido:

```text
≈ 6,11 GB
```

Imagens preservadas:

```text
boot.img
recovery.img
dtbo.img
vbmeta.img
vbmeta_samsung.img
efs.img
sec_efs.img
modemst1.img
modemst2.img
persist.img
modem.img
super.img
```

Foi gerado:

```text
SHA256SUMS.txt
```

Estado do dispositivo após o backup:

```text
Nenhuma partição modificada
Nenhum flash realizado
Nenhuma compilação realizada
Sistema funcional preservado
```

## Super partition

A `super.img` foi analisada com `lpdump`.

Partições lógicas encontradas:

| Partição | Tamanho aproximado |
|---|---|
| system | 1,5 GB |
| vendor | 529 MB |
| product | 2,4 GB |
| odm | 1,7 MB |

Não existe `system_ext` como partição lógica separada, mas existe dentro da árvore de `system.img` em:

```text
/mnt/system/system/system_ext
```

## Imagens extraídas

Extração com:

```bash
lpunpack gta4l_backup_20260610_072545/super.img extracted
```

Arquivos gerados:

```text
extracted/system.img
extracted/vendor.img
extracted/product.img
extracted/odm.img
```

Todos os sistemas de ficheiros são `ext4`.

Montagens realizadas:

```text
/mnt/system
/mnt/vendor
/mnt/product
/mnt/odm
```

## Vendor / blobs

A partição `vendor` contém uma base proprietária forte para Halium.

Foram identificados:

```text
/vendor/lib64/hw: 30 módulos HAL
/vendor/lib/hw:   27 módulos HAL
Total:            57 módulos HAL
```

Exemplos importantes:

```text
audio.primary.bengal.so
camera.qcom.so
vulkan.adreno.so
android.hardware.graphics.mapper@4.0-impl-qti-display.so
android.hardware.gnss@2.1-impl-qti.so
vendor.samsung.hardware.gnss@2.0-impl-sec.so
```

Binários importantes:

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
```

## VINTF

Manifestos encontrados:

```text
/vendor/etc/vintf/manifest.xml
/vendor/etc/vintf/compatibility_matrix.xml
/vendor/etc/vintf/manifest/*.xml
```

Principais áreas declaradas:

```text
audio
bluetooth
camera
drm
gatekeeper
gnss
graphics allocator/composer/mapper
health
keymaster
media omx
memtrack
power
radio / radio.config
sensors
thermal
usb
wifi / hostapd / supplicant
```

HALs Samsung relevantes:

```text
vendor.samsung.hardware.gnss
vendor.samsung.hardware.radio
vendor.samsung.hardware.radio.bridge
vendor.samsung.hardware.radio.channel
vendor.samsung.hardware.security.vaultkeeper
vendor.samsung.hardware.thermal
```

HALs Qualcomm/QTI relevantes:

```text
vendor.qti.hardware.display.*
vendor.qti.hardware.dsp
vendor.qti.hardware.perf
vendor.qti.hardware.qseecom
vendor.qti.hardware.bluetooth_audio
vendor.qti.hardware.sensorscalibrate
vendor.qti.data.factory
```

## Avaliação técnica atual

| Área | Estado |
|---|---|
| Bootloader | favorável |
| Backup | favorável |
| Kernel Android | favorável |
| Binder / hwbinder / vndbinder | favorável |
| Ashmem | favorável |
| OverlayFS | favorável |
| USB ConfigFS | favorável |
| Vendor blobs | favorável |
| Áudio | muito promissor |
| Wi-Fi | muito promissor |
| Bluetooth | muito promissor |
| GPU/Adreno | muito promissor |
| GNSS | muito promissor |
| LTE/RIL | promissor |
| Sensores | promissor |
| Câmara | incerto, mas existem blobs |
| Display | promissor, painel identificado |
| Halium boot | próximo objetivo |

## Próxima etapa

Preparar ambiente Halium e árvore de build.

Próximos objetivos técnicos:

1. Organizar fontes LineageOS/Android para `gta4l`.
2. Obter device tree `gta4l` e `gta4l-common`.
3. Obter kernel `samsung/sm6115` compatível.
4. Preparar vendor blobs a partir das imagens extraídas.
5. Inicializar workspace Halium.
6. Construir `halium-boot.img`.
7. Testar boot sem destruir o estado atual.

## Regra de segurança

Antes de qualquer flash:

```text
Nunca escrever em boot/recovery/dtbo/vbmeta/super sem confirmar:
1. backup existente;
2. hash SHA256;
3. método de restauração;
4. comando exato;
5. partição alvo correta.
```


---

# Atualização de progresso — integração Halium 12
## Atualização — Reuso LineageOS e decisão Halium 12

Após a fase inicial de backup e extração, foi feita uma pesquisa de reuso de código.

Árvores LineageOS clonadas para análise em `~/halium/reuse`:

```text
android_device_samsung_gta4l
android_device_samsung_gta4lwifi
android_device_samsung_gta4l-common
android_kernel_samsung_sm6115
```

Branches disponíveis encontradas:

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

Não foi encontrada branch pública `lineage-19.1`.

Conclusão da comparação:

```text
SM-T505 / gta4l é essencialmente SM-T500 / gta4lwifi + LTE/RIL/modem.
```

A branch `lineage-20` já contém:

```text
ENABLE_VENDOR_RIL_SERVICE := true
rild
secril_config_svc
init.vendor.rilchip.rc
init.vendor.rilcommon.rc
vendor.samsung.hardware.radio
vendor.samsung.hardware.radio.bridge
vendor.samsung.hardware.radio.channel
```

## Base escolhida

A base técnica escolhida para o primeiro trabalho de integração é:

```text
Halium 12
LineageOS 20 / Android 13 como árvore base
Blobs Samsung Android 12
Kernel Samsung/Qualcomm 4.19
```

A árvore LineageOS 20 usa como referência:

```text
T505XXS6CWI2
Android 12 / SP1A.210812.016
```

O tablet atual tem vendor/fingerprint mais recente:

```text
T505XXS8CXG1
```

Interpretação:

```text
A geração vendor continua sendo Android 12, portanto Halium 12 é a direção mais coerente.
```

## Cópias locais preparadas

Foram criadas cópias locais para adaptação Halium sem alterar as árvores originais:

```text
~/halium/reuse/android_device_samsung_gta4l_halium12
~/halium/reuse/android_device_samsung_gta4l-common_halium12
~/halium/reuse/android_kernel_samsung_sm6115_halium12
```

## Ajuste inicial de kernel

Foi criado o fragmento:

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

`BoardConfigCommon.mk` foi ajustado para usar:

```make
TARGET_KERNEL_CONFIG := vendor/bengal-perf_defconfig vendor/gta4l-halium.config
```

O override antigo em `gta4l/BoardConfig.mk` foi removido:

```make
TARGET_KERNEL_CONFIG := gta4l_eur_open_defconfig
```

## FSTAB verificado

Foram verificados:

```text
fstab.emmc
fstab.default
fstab.firmware
```

Conclusões:

```text
system, vendor, product e odm são partições lógicas.
persist, efs, sec_efs, metadata e userdata estão presentes.
modem, apnhlos, dsp e bluetooth são tratados como firmware Qualcomm.
AVB está presente nos fstabs e deve ser considerado antes de qualquer boot/flash.
```

## Estado atual atualizado

| Fase | Estado |
|---|---|
| Documentação inicial | concluída |
| Identificação de hardware | concluída |
| Backup crítico | concluído |
| Extração da super.img | concluída |
| Inventário de vendor/blobs | concluído |
| Pesquisa de reuso LineageOS | concluída |
| Comparação gta4lwifi vs gta4l | concluída |
| Comparação lineage-20 vs lineage-23.2 | concluída |
| Escolha da base Halium 12 | concluída |
| Cópias locais Halium 12 | criadas |
| Fragmento de kernel Halium | criado |
| Ajuste TARGET_KERNEL_CONFIG | aplicado |
| Verificação de fstab | concluída |
| Inicialização workspace Halium 12 | próxima etapa |
| repo sync Halium 12 | pendente |
| Integração das árvores locais na workspace | pendente |
| Build hybris/halium boot | pendente |
| Primeiro boot | pendente |

## Próxima etapa definida

Criar workspace limpa:

```bash
cd ~/halium
mkdir -p halium-12-gta4l
cd halium-12-gta4l

repo init -u https://github.com/Halium/android -b halium-12.0 --depth=1
repo sync -c -j$(nproc)
```

Depois copiar as árvores locais:

```bash
cd ~/halium/halium-12-gta4l

mkdir -p device/samsung kernel/samsung

cp -a ~/halium/reuse/android_device_samsung_gta4l_halium12 device/samsung/gta4l
cp -a ~/halium/reuse/android_device_samsung_gta4l-common_halium12 device/samsung/gta4l-common
cp -a ~/halium/reuse/android_kernel_samsung_sm6115_halium12 kernel/samsung/sm6115
```

Verificar:

```bash
ls device/samsung
ls kernel/samsung
grep -R "PRODUCT_NAME" device/samsung/gta4l/*.mk
```


---

## Atualização — 2026-06-10 (Build Halium 12 concluído)

### Workspace ativo

```text
~/halium/halium-12-gta4l
```

### Estrutura utilizada

```text
device/samsung/gta4l
device/samsung/gta4l-common
kernel/samsung/sm6115
vendor/samsung/gta4l
vendor/samsung/gta4l-common
```

### Vendor

Extração executada com sucesso através de:

```bash
extract-files.sh
```

Gerados:

```text
vendor/samsung/gta4l
vendor/samsung/gta4l-common
```

### Ajustes realizados

#### BoardConfig

Removido:

```make
TARGET_KERNEL_CONFIG := gta4l_eur_open_defconfig
```

Substituído pela configuração Halium herdada do common tree.

#### Configuração Halium do kernel

Criado:

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

#### SEPolicy

Corrigido:

```text
device/qcom/sepolicy_vndr-legacy-um
```

para:

```text
device/qcom/sepolicy-legacy-um
```

#### non_ab_device

Removido:

```make
$(call inherit-product,$(SRC_TARGET_DIR)/product/non_ab_device.mk)
```

#### Audio HAL

Comentado:

```text
android.hardware.audio@7.1-impl_gta4l
```

em:

```text
device/samsung/gta4l-common/audio/impl/Android.bp
```

Motivo:

```text
Halium 12 não contém audio@7.1.
```

#### Health HAL

Criado:

```text
vendor/samsung/gta4l-common/proprietary/vendor/etc/vintf/manifest/android.hardware.health@2.1-samsung.xml
```

Origem:

```text
/mnt/vendor/etc/vintf/manifest/android.hardware.health-service.samsung.xml
```

### Correções do kernel

#### extract-cert.c

Desativado código PKCS#11 ENGINE incompatível com OpenSSL 3.

#### suspend.c

Substituído:

```c
if (intr_sync(NULL))
```

por implementação temporária para permitir compilação.

#### nt36xxx.c

Corrigido warning da variável:

```text
dp
```

#### Makefile

Adicionado:

```make
KBUILD_CFLAGS += -Wno-error
```

### Fedora

Instalado:

```bash
sudo dnf install libxcrypt-compat
```

para disponibilizar:

```text
libcrypt.so.1
```

### Resultado do build

Build concluído:

```text
#### build completed successfully ####
```

Imagem gerada:

```text
out/target/product/gta4l/boot.img
```

### Hashes

Boot original Samsung:

```text
SHA256:
9aa9da7cebd98bbf376dd57f2cbe897f232a361f54ba18d5cfcb8ce8ea0dc5ab
```

Boot compilado:

```text
SHA256:
39e67af96b015ec689ae86e504c6cf20acb9e589fe33b430c6ec2849ed77d278
```

### Informações do boot compilado

```text
boot image header version: 2
os version: 12.0.0
kernel: ~15.8 MB
ramdisk: ~1.3 MB
dtb: ~4.1 MB
```

```text
BOARD_BOOT_HEADER_VERSION=2
```

### Análise do ramdisk

Extraído com:

```bash
unpack_bootimg
```

Conteúdo encontrado:

```text
init
fstab.emmc
```

### Conclusão

O artefacto gerado é:

```text
boot.img Android convencional
```

Não contém:

```text
halium-boot
hybris-boot
Ubuntu Touch rootfs ramdisk
```

### Estado atual

Comando executado:

```bash
find out/target/product/gta4l -maxdepth 2 -type f | \
grep -E "boot|hybris|halium|recovery|ramdisk"
```

Resultado:

```text
boot.img
ramdisk.img
ramdisk/fstab.emmc
ramdisk/init
```

Não foi encontrado:

```text
halium-boot.img
hybris-boot.img
```

### Próxima investigação

Determinar o fluxo correto de geração de:

```text
halium-boot
hybris-boot
Ubuntu Touch rootfs ramdisk
```

na árvore:

```text
Halium 12 / Android 12
SM-T505 (gta4l)
```

---

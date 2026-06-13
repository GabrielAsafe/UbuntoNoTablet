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

Data do último levantamento: 2026-06-11

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
| Preparação do ambiente Halium | concluída |
| Build `halium-boot.img` | concluído manualmente |
| Primeiro boot Halium | próxima fase |
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
| Halium boot | criado manualmente e validado |

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


## Atualização — 2026-06-10 (Investigação recoveryramdisk e estado pós-patches Halium)

### Patches Halium aplicados

Executado:

```bash
bash hybris-patches/apply-patches.sh
```

Os patches Halium foram aplicados com sucesso em múltiplos componentes:

```text
bionic
build
external
frameworks
hardware
packages
system
```

Isto introduziu alterações relacionadas com:

```text
binderfs
hybris
init
servicemanager
compatibilidade Android 12 / Halium
```

### Descoberta importante

Após aplicação dos patches:

```bash
mka halium-boot
```

Resultado:

```text
FAILED: ninja: unknown target 'halium-boot'
```

Conclusão:

```text
A árvore Halium 12 utilizada não possui target halium-boot.
```

### Investigação recoveryramdisk

Foi identificado o alvo:

```bash
mka recoveryramdisk
```

Durante a compilação surgiram múltiplos erros SELinux recovery.

### Ajustes temporários realizados

Foram neutralizados ficheiros Lineage/QCOM específicos de recovery:

```text
device/lineage/sepolicy/qcom/dynamic/hal_lineage_livedisplay_qti.te
device/lineage/sepolicy/qcom/dynamic/hal_lineage_livedisplay_sysfs.te
device/lineage/sepolicy/qcom/vendor/fsck.te
device/lineage/sepolicy/qcom/vendor/hal_lineage_health_default.te
device/lineage/sepolicy/qcom/vendor/hal_lineage_livedisplay_qti.te
```

### Tipos recovery adicionais

Criado:

```text
device/samsung/gta4l-common/sepolicy/vendor/halium_recovery_types.te
```

Tipos adicionados:

```te
type vendor_sysfs_battery_supply, sysfs_type, fs_type;
type vendor_sysfs_graphics, sysfs_type, fs_type;
type vendor_sysfs_mmc_host, sysfs_type, fs_type;
type vendor_sysfs_usb_supply, sysfs_type, fs_type;

type firmware_file, fs_type;
type bt_firmware_file, fs_type;

type vendor_hal_gnss_qti, domain;
type vendor_qti_init_shell, domain;
type vendor_time_daemon, domain;
type vendor_timeservice_app, domain;
type vendor_wcnss_service, domain;
```

### Resultado final

Compilação concluída com sucesso:

```text
#### build completed successfully ####
```

Artefactos gerados:

```text
out/target/product/gta4l/ramdisk-recovery.cpio
out/target/product/gta4l/ramdisk-recovery.img
```

Tamanhos:

```text
ramdisk-recovery.cpio ≈ 29 MB
ramdisk-recovery.img  ≈ 13 MB
```

### Conteúdo recovery gerado

Existe agora:

```text
out/target/product/gta4l/recovery/root
```

incluindo:

```text
init.recovery.qcom.rc
sepolicy
vendor_file_contexts
vendor_property_contexts
plat_file_contexts
plat_property_contexts
```

### Estado atual consolidado

Artefactos existentes:

```text
out/target/product/gta4l/boot.img
out/target/product/gta4l/ramdisk.img
out/target/product/gta4l/ramdisk-recovery.img
out/target/product/gta4l/ramdisk-recovery.cpio
```

Confirmado:

```text
boot.img é Android normal
ramdisk-recovery.img foi gerado com sucesso
não existe target halium-boot
não existe hybris-boot.img gerado automaticamente
```

### Próxima etapa

Determinar qual é o fluxo correto de Halium 12 para gerar o boot final a partir de:

```text
kernel
boot.img
ramdisk-recovery.img
ramdisk-recovery.cpio
```

Investigar especificamente:

```text
recoveryimage
vendorbootimage
bootimage com substituição de ramdisk
empacotamento manual do boot Halium
fluxo utilizado por ports Halium 12 recentes
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



# Atualização — 2026-06-11 (Boot e Recovery Halium reais)

## Estado inicial

Até este momento a árvore Halium 12 para o Samsung Galaxy Tab A7 LTE SM-T505 (`gta4l`) já compilava com sucesso.

Artefactos existentes:

```text
boot.img
ramdisk.img
ramdisk-recovery.img
ramdisk-recovery.cpio
dtb.img
kernel
```

A árvore não possuía target:

```text
halium-boot
```

Foi então iniciada a investigação do método correto de geração do boot Halium.

---

## Descoberta da configuração de boot

Verificação do BoardConfig:

```bash
grep -n "BOARD_KERNEL_CMDLINE\|BOARD_KERNEL_BASE\|BOARD_KERNEL_PAGESIZE\|BOARD_MKBOOTIMG_ARGS\|BOARD_KERNEL_OFFSET\|BOARD_RAMDISK_OFFSET\|BOARD_TAGS_OFFSET\|BOARD_DTB_OFFSET" \
device/samsung/gta4l-common/BoardConfigCommon.mk
```

Resultado relevante:

```text
BOARD_BOOT_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x020000000
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_DTB_OFFSET := 0x1F00000
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_SEPARATED_DTBO := true
```

---

## Geração manual do halium-boot.img

Foi criado manualmente:

```bash
out/host/linux-x86/bin/mkbootimg \
  --kernel out/target/product/gta4l/kernel \
  --ramdisk out/target/product/gta4l/ramdisk-recovery.img \
  --cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x4a90000 androidboot.console=ttyMSM0 androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 loop.max_part=7 firmware_class.path=/vendor/firmware_mnt/image" \
  --base 0x00000000 \
  --pagesize 4096 \
  --kernel_offset 0x00008000 \
  --ramdisk_offset 0x020000000 \
  --tags_offset 0x01E00000 \
  --dtb_offset 0x1F00000 \
  --header_version 2 \
  --dtb out/target/product/gta4l/dtb.img \
  --output out/target/product/gta4l/halium-boot.img
```

Resultado:

```text
halium-boot.img
≈ 32 MB
```

SHA256:

```text
fa4ddd30be54e297d57eb1e761bee7979c1e4c71dbb81600e82d06d836e6838b
```

---

## Confirmação do formato da imagem

```bash
file out/target/product/gta4l/halium-boot.img
```

Resultado:

```text
Android bootimg
header version 2
kernel offset 0x8000
ramdisk offset 0x20000000
page size 4096
```

---

## AVB

Foi observado que o dispositivo utiliza AVB.

Para evitar rejeição do bootloader foi criado:

```bash
cp halium-boot.img halium-boot-avb.img

out/host/linux-x86/bin/avbtool add_hash_footer \
  --image halium-boot-avb.img \
  --partition_name boot \
  --partition_size 100663296 \
  --prop com.android.build.boot.os_version:12
```

Resultado:

```text
halium-boot-avb.img
≈ 96 MB
```

SHA256:

```text
4252bd1d079b6937e4ee8d198b1292c1e81f5ce0b045dfb2bbf504829c01b283
```

Validação:

```bash
avbtool info_image --image halium-boot-avb.img
```

Resultado:

```text
Partition Name: boot
Hash Algorithm: sha256
Algorithm: NONE
Footer version: 1.0
```

---

## PIT real do dispositivo

Obtido através de:

```bash
heimdall print-pit --no-reboot > pit.txt
```

Partições confirmadas:

```text
BOOT      -> mmcblk0p69
RECOVERY  -> mmcblk0p70
DTBO      -> mmcblk0p57
VBMETA    -> mmcblk0p11
VBMETA_SAMSUNG -> mmcblk0p19
```

---

## Flash do halium-boot

Executado:

```bash
heimdall flash \
  --BOOT out/target/product/gta4l/halium-boot-avb.img \
  --no-reboot
```

Resultado:

```text
Protocol initialisation successful
BOOT upload successful
```

---

## Primeiro arranque Halium

Comportamento observado:

```text
Samsung logo
This tablet is not running Samsung's official software
Galaxy Tab A7
Powered by Android
```

O dispositivo permaneceu indefinidamente neste estado.

ADB nunca apareceu.

```bash
adb devices
```

Resultado:

```text
nenhum dispositivo
```

Conclusão:

```text
bootloader aceitou a imagem
AVB não bloqueou
kernel arrancou
userspace não completou o arranque
```

---

## Geração do recovery completo

Executado:

```bash
mka recoveryimage
```

Resultado:

```text
#### build completed successfully ####
```

Artefacto gerado:

```text
out/target/product/gta4l/recovery.img
≈ 99 MB
```

---

## Validação do recovery

```bash
avbtool info_image --image recovery.img
```

Resultado:

```text
Partition Name: recovery
Algorithm: SHA256_RSA4096
Rollback Index: 1
```

---

## Flash do recovery Halium

Executado:

```bash
heimdall flash \
  --RECOVERY out/target/product/gta4l/recovery.img \
  --no-reboot
```

Resultado:

```text
RECOVERY upload successful
```

---

## Teste do recovery Halium

Tentativa de arranque:

```text
Volume Up + Power
```

Resultado:

```text
Samsung logo permanente
```

Não apareceu:

```text
Recovery UI
ADB recovery
Ubuntu Touch installer
```

---

## Investigação do ramdisk recovery

Comparação entre:

```text
ramdisk
recovery/root
```

Descobertas:

O recovery contém:

```text
system/bin/adbd
system/bin/install-system
system/bin/system-image-upgrader
ro.ubuntu.recovery=true
```

Além disso:

```text
/init -> /system/bin/init
```

e:

```text
system/bin/init
```

existem dentro do ramdisk recovery.

---

## Teste SELinux permissive

Foi adicionado temporariamente:

```text
androidboot.selinux=permissive
enforcing=0
```

à linha de boot.

Recovery recompilado.

Resultado:

```text
comportamento idêntico
Samsung logo permanente
```

Conclusão:

```text
a hipótese SELinux perdeu força
```

---

## Recuperação

Recovery original restaurado:

```bash
heimdall flash \
  --RECOVERY recovery.img.original \
  --no-reboot
```

Resultado:

```text
recovery original voltou a funcionar
```

---

## Conclusões atuais

Estado confirmado:

```text
BOOT original           -> funciona
RECOVERY original       -> funciona

halium-boot.img         -> compila
halium-boot-avb.img     -> compila
recovery.img Halium     -> compila

BOOT Halium             -> bloqueia no splash
RECOVERY Halium         -> bloqueia no splash
```

Conclusão técnica atual:

```text
O problema já não está em:
- Heimdall
- PIT
- AVB
- geração da imagem
- partições BOOT/RECOVERY

O kernel arranca.

O bloqueio ocorre durante o arranque do userspace Halium/recovery, antes de existir ADB ou interface gráfica.
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


## Estado atualizado do projeto após 2026-06-13

A estratégia anterior de gerar recovery/boot com `mkbootimg` e adicionar footer com `avbtool add_hash_footer` precisa ser tratada como insegura para testes de recovery neste dispositivo, porque um clean repack do recovery stock causou bootloop.

A prioridade deixou de ser testar novas imagens e passou a ser entender como a imagem recovery funcional é assinada/construída pela base LineageOS/Samsung.

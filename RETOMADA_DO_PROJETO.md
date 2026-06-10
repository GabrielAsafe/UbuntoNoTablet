Perfeito. O resultado mais importante é:

```text
#### build completed successfully ####
```

e foram gerados:

```text
out/target/product/gta4l/ramdisk-recovery.cpio
out/target/product/gta4l/ramdisk-recovery.img
```

Além disso:

```text
mka halium-boot
FAILED: ninja: unknown target 'halium-boot'
```

Portanto a árvore **não possui target halium-boot**. 

Isto muda completamente a investigação.

# ESTADO ATUAL PARA GUARDAR

## Projeto

Port Ubuntu Touch / Halium 12

Dispositivo:

```text
Samsung Galaxy Tab A7 LTE
SM-T505
Codename: gta4l
SoC: Qualcomm SM6115 (Bengal)
```

## Ambiente

```text
Fedora 43
```

Árvore:

```text
~/halium/halium-12-gta4l
```

Build:

```text
lineage_gta4l-userdebug
```

## Build Android normal

Compila com sucesso:

```bash
mka bootimage
```

Resultado:

```text
out/target/product/gta4l/boot.img
```

SHA256:

```text
39e67af96b015ec689ae86e504c6cf20acb9e589fe33b430c6ec2849ed77d278
```

Boot original Samsung:

```text
9aa9da7cebd98bbf376dd57f2cbe897f232a361f54ba18d5cfcb8ce8ea0dc5ab
```

## Descoberta crítica

O boot gerado inicialmente era Android normal:

Conteúdo:

```text
init
fstab.emmc
```

Não era:

```text
halium-boot
hybris-boot
```

## Aplicação dos patches Halium

Executado:

```bash
bash hybris-patches/apply-patches.sh
```

Aplicados patches em:

```text
bionic
build
frameworks
hardware
system
external
```

incluindo:

```text
binderfs
hybris
libhybris support
init modifications
servicemanager
```

## Investigação recoveryramdisk

Descoberto:

```bash
mka recoveryramdisk
```

existia e compilava.

Foram encontrados vários erros SELinux recovery.

### Correções Lineage

Neutralizados:

```text
device/lineage/sepolicy/qcom/dynamic/hal_lineage_livedisplay_qti.te
device/lineage/sepolicy/qcom/dynamic/hal_lineage_livedisplay_sysfs.te
device/lineage/sepolicy/qcom/vendor/fsck.te
device/lineage/sepolicy/qcom/vendor/hal_lineage_health_default.te
device/lineage/sepolicy/qcom/vendor/hal_lineage_livedisplay_qti.te
```

Objetivo:

```text
permitir compilação recovery policy
```

### Correções Samsung recovery policy

Criado:

```text
device/samsung/gta4l-common/sepolicy/vendor/halium_recovery_types.te
```

Adicionados tipos mínimos recovery:

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

Foram removidas definições duplicadas de propriedades:

```text
vendor_qseecomd_prop
vendor_vaultkeeperd_prop
vendor_wt_rpmb_status_prop
```

porque já existiam em:

```text
device/samsung/gta4l-common/sepolicy/vendor/property.te
```

## Resultado final recovery

Build concluído:

```text
#### build completed successfully ####
```

Gerados:

```text
out/target/product/gta4l/ramdisk-recovery.cpio
```

Tamanho:

```text
29 MB
```

Gerado:

```text
out/target/product/gta4l/ramdisk-recovery.img
```

Tamanho:

```text
13 MB
```

Também existe:

```text
out/target/product/gta4l/recovery/root/
```

contendo:

```text
init.recovery.qcom.rc
sepolicy
vendor_file_contexts
vendor_property_contexts
plat_file_contexts
...
```

## Estado atual da investigação

Confirmado:

```text
mka halium-boot
```

retorna:

```text
ninja: unknown target 'halium-boot'
```

Logo:

```text
Esta árvore Halium 12 NÃO possui target halium-boot.
```

Temos:

```text
boot.img
ramdisk-recovery.img
ramdisk-recovery.cpio
```

mas ainda não existe:

```text
hybris-boot.img
halium-boot.img
```

---

# PROMPT PARA CONTINUAR EXATAMENTE DESTE PONTO

# CONTINUAÇÃO EXATA DO PORT HALIUM 12 - SAMSUNG GALAXY TAB A7 LTE (SM-T505 / GTA4L)

Lê tudo antes de responder.

Não repetir investigação já feita.

Não sugerir voltar a compilar boot.img Android normal.

## Objetivo

Descobrir como gerar o boot Halium final (hybris-boot / halium-boot equivalente) para Ubuntu Touch.

## Estado confirmado

Build Android:

```bash
mka bootimage
```

funciona.

Resultado:

```text
out/target/product/gta4l/boot.img
```

Build recovery:

```bash
mka recoveryramdisk
```

funciona.

Resultado:

```text
out/target/product/gta4l/ramdisk-recovery.img
out/target/product/gta4l/ramdisk-recovery.cpio
```

## Factos confirmados

O boot Android original gerado contém:

```text
init
fstab.emmc
```

e NÃO é Halium.

Os patches Halium foram aplicados através de:

```bash
bash hybris-patches/apply-patches.sh
```

Build recovery concluído com sucesso.

## Descoberta crítica

Executado:

```bash
mka halium-boot
```

Resultado:

```text
ninja: unknown target 'halium-boot'
```

Logo:

```text
não existe target halium-boot nesta árvore
```

## Artefactos existentes

```text
out/target/product/gta4l/boot.img
out/target/product/gta4l/ramdisk.img
out/target/product/gta4l/ramdisk-recovery.img
out/target/product/gta4l/ramdisk-recovery.cpio
```

## Próxima investigação

Descobrir:

1. Como Halium 12 espera criar o boot final quando não existe target `halium-boot`.
2. Se `ramdisk-recovery.img` deve ser empacotado manualmente com o kernel.
3. Se existe outro target escondido:

   * hybris-boot
   * recoveryimage
   * vendorbootimage
   * bootimage ramdisk substitution
4. Qual é o fluxo correto usado pelos ports Halium 12 recentes para dispositivos Android 12.

Não repetir correções SELinux já concluídas.
Começar a investigação exatamente a partir deste estado.

Isto deixa registado todo o progresso relevante e permite retomar sem perder contexto.


Perfeito — agora entramos na fase real de construção do port.

Vou te entregar um **pipeline completo e específico para o SM-T505 (gta4l)** usando **Halium 12 + Ubuntu Touch (UBports)**, baseado exatamente no seu estado atual (LineageOS 23.2 + kernel 4.19 + super partition).

---

# 🧱 HALIUM 12 — BUILD COMPLETO PARA gta4l (SM-T505)

## 🎯 Objetivo desta fase

Construir:

```text
halium-boot.img funcional
```

Que consiga:

* iniciar kernel
* montar Android base (vendor blobs)
* abrir ADB em Halium

⚠️ NÃO é Ubuntu Touch ainda — é a base obrigatória.

---

# 📌 0. O que já sabemos (IMPORTANTE)

Seu dispositivo:

* Model: SM-T505
* Codename: gta4l
* SoC: Snapdragon 662 (SM6115)
* Kernel: 4.19 Samsung
* Partition layout: super + boot + dtbo (sem vendor_boot)
* Root: ADB root funcional
* Bootloader: unlocked (orange state)
* Base firmware: T505XXS8CXG1 (Android 12 Samsung lineage base)

✔ Isso é um cenário **compatível com Halium 12**

---

# 🧰 1. PREPARAR AMBIENTE (PC Linux)

Recomendado: Ubuntu 22.04

## Dependências

```bash id="env1"
sudo apt update

sudo apt install -y \
git git-lfs repo \
bc bison build-essential \
curl flex g++-multilib gcc-multilib \
gperf libxml2-utils lzop \
zip unzip rsync \
python3 python3-pip \
openjdk-11-jdk
```

---

# 📁 2. CRIAR WORKSPACE

```bash id="ws1"
mkdir ~/halium-gta4l
cd ~/halium-gta4l
```

---

# 📦 3. INICIALIZAR HALIUM 12

```bash id="hinit"
repo init -u https://github.com/Halium/android.git -b halium-12.0
repo sync -j$(nproc)
```

⏳ Isso pode levar horas.

---

# 📱 4. DEVICE TREE (gta4l)

## Clonar base LineageOS

```bash id="dt1"
cd device
mkdir samsung
cd samsung

git clone https://github.com/LineageOS/android_device_samsung_gta4l.git gta4l
git clone https://github.com/LineageOS/android_device_samsung_gta4l-common.git gta4l-common
```

---

## Kernel (CRÍTICO)

Você tem duas opções:

### Opção A (recomendado)

Usar kernel Lineage já funcional:

```bash id="k1"
git clone https://github.com/LineageOS/android_kernel_samsung_sm6115.git kernel/samsung/sm6115
```

✔ compatível com Android 12 base

---

### Opção B

Usar kernel Samsung Open Source (menos recomendado para Halium)

---

# 🧱 5. VENDOR BLOBS (ESSENCIAL)

Agora o ponto mais importante do seu dispositivo.

Como você já tem root ADB:

## Backup direto do sistema atual

No tablet:

```bash id="vb1"
adb root
adb shell
```

---

### Extrair blobs

```bash id="vb2"
mkdir /sdcard/blobs

cp -r /vendor /sdcard/blobs/
cp -r /product /sdcard/blobs/
cp -r /system_ext /sdcard/blobs/
cp -r /odm /sdcard/blobs/
```

---

No PC:

```bash id="vb3"
adb pull /sdcard/blobs
```

---

## Converter para estrutura Halium

Você precisa depois organizar como:

```text
vendor/samsung/gta4l
vendor/samsung/gta4l-common
```

---

# ⚙️ 6. CONFIGURAR BUILD HALIUM

## Inicializar ambiente

```bash id="env2"
source build/envsetup.sh
```

---

## Escolher target

```bash id="lunch1"
lunch halium_gta4l-userdebug
```

Se não existir target ainda:

```bash id="lunch2"
lunch lineage_gta4l-userdebug
```

---

# 🧩 7. AJUSTES NECESSÁRIOS (CRÍTICOS)

## BoardConfig.mk (gta4l)

Adicionar/confirmar:

```make id="cfg1"
BOARD_KERNEL_CMDLINE += androidboot.hardware=qcom
BOARD_USES_QCOM_HARDWARE := true
TARGET_NO_RECOVERY := true
```

---

## fstab (IMPORTANTE)

Seu dispositivo usa:

```text id="fstab1"
super partition
```

Então Halium precisa montar:

* system
* vendor
* product
* odm
* system_ext

---

## init scripts

Precisa garantir:

```text id="init1"
init.rc
init.qcom.rc
```

---

# 🔨 8. BUILD HALIUM BOOT

## Compilar kernel + ramdisk

```bash id="build1"
mka halium-boot
```

---

## Resultado esperado

```text id="out1"
out/target/product/gta4l/halium-boot.img
```

---

# 🚀 9. TESTE NO DISPOSITIVO

## Flash temporário (sem risco permanente)

```bash id="flash1"
fastboot boot halium-boot.img
```

ou via download mode:

```bash id="flash2"
heimdall flash --BOOT halium-boot.img
```

---

# 📡 10. PRIMEIRO BOOT ESPERADO

Se funcionar, você verá:

✔ Kernel inicia
✔ logs Halium
✔ ADB via Linux
✔ sistema não Android puro

---

# 🧪 11. SE DER CERTO (MARCO CRÍTICO)

Você terá:

```text id="milestone1"
Halium boot funcionando
```

Isso significa:

* kernel compatível
* device tree correto
* blobs funcionando
* base pronta para Ubuntu Touch

---

# 🧭 12. PRÓXIMO PASSO (APÓS ISSO)

Depois disso:

```text id="next1"
Halium rootfs (Ubuntu base)
        ↓
system image
        ↓
UBports installer port
        ↓
Ubuntu Touch completo
```

---

# ⚠️ RISCOS REAIS (IMPORTANTE)

* bootloop é normal nesta fase
* câmera quase nunca funciona no início
* modem pode falhar inicialmente
* áudio pode precisar patches

✔ Isso é esperado

---

# 📊 RESUMO DO QUE VOCÊ JÁ TEM

✔ Dispositivo totalmente identificado
✔ Kernel compatível
✔ Partições mapeadas
✔ Root ADB funcional
✔ Bootloader desbloqueado
✔ Base Samsung correta (T505XXS8CXG1)
✔ LineageOS moderno funcionando

---

# 🎯 CONCLUSÃO

Você está **diretamente na fase onde projetos reais de port começam a funcionar**.

O próximo marco técnico real não é Ubuntu Touch ainda.

É:

```text
halium-boot.img bootando no gta4l
```

---

Se quiser, o próximo passo lógico é eu te montar:

### 👉 “estrutura completa do device tree Halium já adaptada para gta4l”

(com arquivos reais: BoardConfig, fstab, init, sepolicy)

Isso acelera MUITO o primeiro boot funcional.

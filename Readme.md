# Blueprint do Port Ubuntu Touch / Halium para Samsung Galaxy Tab A7 LTE (SM-T505)

## Objetivo

Criar uma base de desenvolvimento completa para portar Ubuntu Touch (via Halium) ao Samsung Galaxy Tab A7 LTE (SM-T505), preservando a capacidade de retornar ao sistema atual e documentando todos os componentes necessários.

---

# Identificação do aparelho

## Modelo comercial

Samsung Galaxy Tab A7 LTE

## Modelo Samsung

SM-T505

## Codename

gta4l

## Hardware

### SoC

Qualcomm Snapdragon 662

Também conhecido como:

SM6115

### Arquitetura

ARM64 (aarch64)

### Plataforma

Qualcomm (qcom)

---

# Estado atual do dispositivo

## Sistema instalado

LineageOS

### Versão

23.2-20260405-NIGHTLY-gta4l

### Android base

Android 16

Build:

BP4A.251205.006

---

## Fingerprint

samsung/gta4leea/gta4l:12/SP1A.210812.016/T505XXS8CXG1:user/release-keys

Isto indica que os blobs proprietários continuam derivados do firmware Samsung Android 12.

---

# Kernel atualmente em execução

Linux 4.19.325-cip128-st12-perf-g646d493c15ed

Compilado:

Sun Apr 5 10:01:17 UTC 2026

Arquitetura:

aarch64

Kernel baseado na árvore Samsung/Qualcomm 4.19.

---

# Conclusões importantes

Apesar do LineageOS ser Android 16:

* os blobs continuam da base Samsung Android 12;
* o kernel continua sendo o Samsung 4.19;
* o hardware continua compatível com a árvore Android 12.

Isto é muito importante porque permite usar Halium 12 sem precisar reverter para um firmware antigo.

---

# Pacote Samsung Open Source correspondente

Encontrado no Samsung Open Source Release Center:

SM-T505_EUR_12_Opensource.zip

Versão:

T505XXS8CXG1

Este pacote provavelmente contém:

* código-fonte do kernel;
* drivers GPL;
* configurações de compilação;
* defconfigs.

Não contém:

* blobs proprietários;
* modem firmware;
* GPU firmware;
* HALs Android.

---

# Componentes necessários para o port

O port será composto por quatro blocos principais.

## Bloco 1 — Kernel

Origem:

Samsung Open Source Release

ou

Kernel utilizado pelo LineageOS atual.

Função:

Controlar o hardware.

Responsável por:

* CPU;
* memória;
* armazenamento;
* USB;
* Wi-Fi;
* Bluetooth;
* tela;
* touch.

---

## Bloco 2 — Device Tree

Representa a descrição do hardware.

Contém:

* partições;
* GPIOs;
* configuração do display;
* configuração do touch;
* montagem de sistemas de arquivos;
* parâmetros de boot.

Esperado:

device/samsung/gta4l

e

device/samsung/gta4l-common

---

## Bloco 3 — Vendor Blobs

Parte proprietária.

Extraída do sistema atualmente funcional.

Pastas importantes:

/vendor

/product

/system_ext

/odm

Contém:

* modem;
* câmera;
* áudio;
* GPS;
* GPU;
* sensores.

Sem esses blobs vários componentes deixam de funcionar.

---

## Bloco 4 — Halium

Camada intermediária.

Função:

Permitir que um sistema Linux moderno utilize componentes Android proprietários.

Fornece:

* integração com vendor blobs;
* integração com Binder;
* integração com serviços Android;
* suporte a Ubuntu Touch.

---

# Fluxo final do sistema

Samsung Hardware
↓
Kernel Samsung / Qualcomm
↓
Device Tree
↓
Vendor Blobs
↓
Halium
↓
Ubuntu Touch

---

# O que NÃO estamos tentando fazer

Não estamos tentando inicialmente:

* Linux mainline puro;
* Debian ARM puro;
* Ubuntu Server puro.

Motivo:

Muitos componentes ainda dependem dos blobs Android.

O objetivo inicial é:

Hardware funcional
+
Ubuntu Touch funcional

---

# Backups obrigatórios

Antes de qualquer compilação:

## Partições

Salvar:

boot

vendor_boot

dtbo

vbmeta

vbmeta_system

vbmeta_vendor

recovery (se existir)

super

---

## EFS

Backup obrigatório.

Contém:

* IMEI;
* dados LTE;
* calibração do modem.

Perder esta partição pode impedir o funcionamento da rede celular.

---

## Sistema funcional

Salvar:

/vendor

/product

/system_ext

/odm

Esses diretórios são a fonte dos blobs.

---

# Informações ainda faltando coletar

## Layout de partições

Comando:

adb shell ls -l /dev/block/by-name

Objetivo:

Documentar todas as partições.

---

## Modelo da Device Tree

Comando:

adb shell cat /proc/device-tree/model

Objetivo:

Identificar o hardware descrito ao kernel.

---

## Compatíveis do Device Tree

Comando:

adb shell cat /proc/device-tree/compatible

Objetivo:

Mapear a árvore utilizada.

---

## Linha de boot

Comando:

adb shell cat /proc/cmdline

Objetivo:

Capturar parâmetros de boot atuais.

---

# Fases do projeto

## Fase 1

Documentação completa do aparelho.

---

## Fase 2

Backup completo.

---

## Fase 3

Extração dos blobs.

---

## Fase 4

Obtenção da árvore LineageOS:

* gta4l
* gta4l-common
* sm6115

---

## Fase 5

Preparação do ambiente Halium 12.

---

## Fase 6

Compilação de:

halium-boot.img

Objetivo:

Verificar se o sistema inicia.

---

## Fase 7

ADB funcional.

---

## Fase 8

Tela funcional.

---

## Fase 9

Áudio.

---

## Fase 10

Wi-Fi.

---

## Fase 11

LTE.

---

## Fase 12

Ubuntu Touch completo.

---

# Critério de sucesso

Primeiro marco:

Tablet inicializa com halium-boot.img.

Segundo marco:

ADB funcional.

Terceiro marco:

Tela funcional.

Quarto marco:

Ubuntu Touch inicia.

Quinto marco:

LTE, Wi-Fi, áudio e sensores funcionando.

Neste ponto o port pode ser considerado utilizável para desenvolvimento e testes diários.




Eu acrescentaria a seguinte seção ao documento, porque ela muda bastante o planejamento do projeto.

---

# Inventário de Partições

## Layout identificado em `/dev/block/by-name`

O dispositivo utiliza armazenamento eMMC (`mmcblk0`) e possui aproximadamente 80 partições nomeadas.

---

## Partições críticas para backup

Estas devem ser copiadas antes de qualquer experimento.

### Boot

```text
boot -> mmcblk0p69
```

Contém:

* kernel
* ramdisk Android

Backup obrigatório.

---

### Recovery

```text
recovery -> mmcblk0p70
```

Contém:

* recovery atual

Backup obrigatório.

---

### DTBO

```text
dtbo -> mmcblk0p57
```

Contém:

* Device Tree Overlays

Necessário para boot.

Backup obrigatório.

---

### VBMETA

```text
vbmeta -> mmcblk0p11
```

Contém:

* Android Verified Boot

Backup obrigatório.

---

### VBMETA Samsung

```text
vbmeta_samsung -> mmcblk0p19
```

Implementação Samsung do AVB.

Backup obrigatório.

---

### SUPER

```text
super -> mmcblk0p73
```

Partição dinâmica.

Contém normalmente:

* system
* vendor
* product
* odm
* system_ext

É uma das partições mais importantes do aparelho.

Backup altamente recomendado.

---

### USERDATA

```text
userdata -> mmcblk0p80
```

Dados do usuário.

Não é necessária para o port, mas pode ser arquivada.

---

## Partições críticas para LTE

### EFS

```text
efs -> mmcblk0p64
```

Contém:

* IMEI
* identidade do modem
* parâmetros de rede

Backup obrigatório.

---

### SEC_EFS

```text
sec_efs -> mmcblk0p63
```

Extensão Samsung da EFS.

Backup obrigatório.

---

### MODEMST1

```text
modemst1 -> mmcblk0p61
```

Dados persistentes do modem.

Backup obrigatório.

---

### MODEMST2

```text
modemst2 -> mmcblk0p62
```

Espelho do modemst1.

Backup obrigatório.

---

### PERSIST

```text
persist -> mmcblk0p37
```

Contém calibrações importantes:

* sensores
* Wi-Fi
* Bluetooth
* modem

Backup obrigatório.

---

## Partições relacionadas ao modem

```text
modem -> mmcblk0p36
apnhlos -> mmcblk0p42
fsg -> mmcblk0p59
fsc -> mmcblk0p60
```

Essas partições participam do funcionamento da baseband Qualcomm.

Devem ser preservadas.

---

# Observações importantes

## Não existe vendor_boot

Na listagem atual não aparece:

```text
vendor_boot
```

Isso é relevante.

O aparelho ainda segue um layout Android mais antigo baseado em:

```text
boot
+
dtbo
+
super
```

e não no modelo mais recente que separa `vendor_boot`.

Isso simplifica bastante um futuro port Halium.

---

## Existe partição recovery dedicada

```text
recovery -> mmcblk0p70
```

Isso significa que podemos testar imagens sem necessariamente substituir o boot principal.

---

## Existe partição super

```text
super -> mmcblk0p73
```

Portanto o dispositivo utiliza Dynamic Partitions.

Dentro dela estarão:

* system
* vendor
* product
* odm
* system_ext

Os blobs necessários para Ubuntu Touch provavelmente serão extraídos daí.

---

## Existe dual boot chain parcial

Foram encontradas:

```text
boot
bota
```

Isso sugere que a Samsung mantém mecanismos de redundância ou atualização para o kernel.

Antes de qualquer flash será necessário investigar a função exata da partição `bota`.

---

# Prioridade de backup

### Prioridade máxima

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

---

### Prioridade alta

```text
super
modem
apnhlos
fsg
fsc
```

---

### Prioridade média

```text
metadata
misc
param
```

---

# Impacto no projeto Ubuntu Touch

Com base no layout descoberto, o caminho mais provável será:

```text
Kernel Samsung 4.19
        +
Device Tree gta4l
        +
Blobs extraídos da super
        +
Halium 12
        +
Ubuntu Touch
```

A ausência de `vendor_boot` reduz a complexidade do boot, e a presença de uma partição `super` indica que os blobs atuais do LineageOS podem ser reaproveitados diretamente sem depender do firmware Samsung para extração.

---

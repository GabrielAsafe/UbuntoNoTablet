# CHECKPOINT — Port Halium 12 / Ubuntu Touch para Samsung Galaxy Tab A7 LTE SM-T505 (gta4l)

## Estado funcional confirmado

```text
✓ Android arranca normalmente
✓ Recovery Samsung original arranca normalmente
✓ Kernel compila
✓ Android build compila
✓ Recovery build compila
✓ Ramdisk recovery compila
✓ Heimdall funciona
✓ AVB funciona
✓ PIT obtido
✓ BOOT pode ser flashado
✓ RECOVERY pode ser flashado
✓ recovery-debug.img pode ser construído e assinado
```

## Estado não funcional

```text
✗ halium-boot não arranca
✗ recovery Halium não arranca
✗ recovery-debug não arranca
✗ ADB nunca aparece
✗ UI recovery nunca aparece
✗ Ubuntu Touch installer nunca aparece
```

---

# Comportamento observado

## halium-boot-avb.img

```text
Samsung logo
"This tablet is not running Samsung's official software"
Galaxy Tab A7
Powered by Android

↓
fica preso indefinidamente
```

## recovery.img Halium

```text
Samsung logo

↓
fica preso indefinidamente
```

## recovery-debug.img

Mesma modificação:

```text
- adbd forçado
- class core adicionada
- start adbd manual
- sys.usb.config=adb
- console shell ativada
- tentativa de arranque em early-init
```

Resultado:

```text
Samsung logo

↓
fica preso exatamente igual
```

Nenhuma alteração observável.

---

# O que foi definitivamente descartado

## Flashing

```text
✓ Heimdall
✓ PIT
✓ RECOVERY partition
✓ BOOT partition
```

## Segurança

```text
✓ AVB
✓ assinatura AVB recovery
✓ bootloader aceita imagens
✓ CURRENT BINARY: Custom
```

## Configuração Android

```text
✓ SELinux permissive
✓ enforcing=0
✓ ro.boot.bootdevice
✓ androidboot.hardware=qcom
```

## Construção recovery

```text
✓ kernel incluído
✓ dtb incluído
✓ recovery_dtbo incluído
✓ header_version=2
✓ board=SRPTC24A004
✓ pagesize=4096
✓ offsets corretos
```

---

# Descobertas importantes

## Cmdline real do recovery

```text
console=ttyMSM0,115200n8
earlycon=msm_geni_serial,0x4a90000
androidboot.console=ttyMSM0
androidboot.hardware=qcom
androidboot.memcg=1
androidboot.selinux=permissive
enforcing=0
buildvariant=userdebug
```

Portanto:

```text
✓ ro.hardware=qcom está correto
```

A hipótese:

```text
import /init.recovery.${ro.hardware}.rc
```

falhar por hardware incorreto foi descartada.

---

## Conteúdo do ramdisk

Confirmado:

```text
✓ /system/bin/init
✓ /system/bin/recovery
✓ /system/bin/adbd
✓ fastbootd
✓ recovery.fstab
✓ init.recovery.qcom.rc
✓ recovery UI resources
✓ Ubuntu Touch recovery files
```

Portanto:

```text
ramdisk não está vazio
ramdisk não está incompleto
```

---

## init.rc

Primeira linha:

```rc
import /init.recovery.${ro.hardware}.rc
```

Serviços encontrados:

```rc
service recovery /system/bin/recovery
service adbd /system/bin/adbd
service fastbootd /system/bin/fastbootd
```

ADB existe.

Recovery existe.

UI existe.

---

# Teste recovery-debug

Foram feitas alterações para forçar:

```text
ADB
console shell
class core
early-init
```

Resultado:

```text
nenhuma diferença observável
```

Isto sugere fortemente:

```text
o sistema não chega a executar
os blocos relevantes do init.rc
```

ou

```text
o bloqueio ocorre antes do userspace recovery funcionar
```

---

# Recovery debug construído

SHA256:

```text
recovery-debug.img
9ba71e36601640ab6cadd49b1d5492902a56b2e8ca4a87d753758beacc073ddd
```

Recovery original:

```text
0b275e078bcd1a1f2145ed4a8e95e9998a777fd7a21e835f4bd7a44eed4be52a
```

Logo:

```text
✓ imagens diferentes
✓ modificações realmente aplicadas
```

---

# Logs persistentes

Tentativa:

```text
CONFIG_PSTORE
ramoops
pstore
```

Resultado:

```text
nenhuma evidência encontrada
```

Neste momento não existe mecanismo conhecido para recolher logs persistentes.

---

# Hipótese principal atual

A hipótese mais forte neste momento é:

```text
Kernel assume controlo.

↓

Problema ocorre antes do userspace recovery ficar funcional.

↓

ADB nunca sobe.
Recovery nunca sobe.
UI nunca sobe.

↓

Bloqueio muito cedo no arranque.
```

---

# Próxima investigação

Prioridade máxima:

```text
Comparar recovery stock Samsung
vs
recovery Halium
```

Objetivo:

```text
extrair recovery.img stock

comparar:

- kernel
- dtb
- dtbo
- cmdline
- header
- offsets
- pagesize
- board
```

e determinar:

```text
se o problema está no kernel/dtb/dtbo
ou no userspace Halium
```

---

# Estado resumido

```text
Já não parece ser:

- Heimdall
- AVB
- PIT
- recovery partition
- boot partition
- SELinux
- bootdevice
- adbd desativado
- init.rc incompleto

O foco passou para:

kernel
dtb
dtbo
boot chain Samsung
arranque muito precoce antes do recovery userspace
```

# CHECKPOINT — Port Halium 12 / Ubuntu Touch para Samsung Galaxy Tab A7 LTE SM-T505 (gta4l)

## Estado funcional confirmado

```text
✓ Android arranca normalmente
✓ Recovery Samsung original arranca normalmente
✓ Kernel compila
✓ Android build compila
✓ Recovery build compila
✓ Ramdisk recovery compila
✓ Heimdall funciona
✓ AVB funciona
✓ PIT obtido
✓ BOOT pode ser flashado
✓ RECOVERY pode ser flashado
✓ recovery-debug.img pode ser construído e assinado
```

## Estado não funcional

```text
✗ halium-boot não arranca
✗ recovery Halium não arranca
✗ recovery-debug não arranca
✗ ADB nunca aparece
✗ UI recovery nunca aparece
✗ Ubuntu Touch installer nunca aparece
```

---

# Comportamento observado

## halium-boot-avb.img

```text
Samsung logo
"This tablet is not running Samsung's official software"
Galaxy Tab A7
Powered by Android

↓
fica preso indefinidamente
```

## recovery.img Halium

```text
Samsung logo

↓
fica preso indefinidamente
```

## recovery-debug.img

Mesma modificação:

```text
- adbd forçado
- class core adicionada
- start adbd manual
- sys.usb.config=adb
- console shell ativada
- tentativa de arranque em early-init
```

Resultado:

```text
Samsung logo

↓
fica preso exatamente igual
```

Nenhuma alteração observável.

---

# O que foi definitivamente descartado

## Flashing

```text
✓ Heimdall
✓ PIT
✓ RECOVERY partition
✓ BOOT partition
```

## Segurança

```text
✓ AVB
✓ assinatura AVB recovery
✓ bootloader aceita imagens
✓ CURRENT BINARY: Custom
```

## Configuração Android

```text
✓ SELinux permissive
✓ enforcing=0
✓ ro.boot.bootdevice
✓ androidboot.hardware=qcom
```

## Construção recovery

```text
✓ kernel incluído
✓ dtb incluído
✓ recovery_dtbo incluído
✓ header_version=2
✓ board=SRPTC24A004
✓ pagesize=4096
✓ offsets corretos
```

---

# Descobertas importantes

## Cmdline real do recovery

```text
console=ttyMSM0,115200n8
earlycon=msm_geni_serial,0x4a90000
androidboot.console=ttyMSM0
androidboot.hardware=qcom
androidboot.memcg=1
androidboot.selinux=permissive
enforcing=0
buildvariant=userdebug
```

Portanto:

```text
✓ ro.hardware=qcom está correto
```

A hipótese:

```text
import /init.recovery.${ro.hardware}.rc
```

falhar por hardware incorreto foi descartada.

---

## Conteúdo do ramdisk

Confirmado:

```text
✓ /system/bin/init
✓ /system/bin/recovery
✓ /system/bin/adbd
✓ fastbootd
✓ recovery.fstab
✓ init.recovery.qcom.rc
✓ recovery UI resources
✓ Ubuntu Touch recovery files
```

Portanto:

```text
ramdisk não está vazio
ramdisk não está incompleto
```

---

## init.rc

Primeira linha:

```rc
import /init.recovery.${ro.hardware}.rc
```

Serviços encontrados:

```rc
service recovery /system/bin/recovery
service adbd /system/bin/adbd
service fastbootd /system/bin/fastbootd
```

ADB existe.

Recovery existe.

UI existe.

---

# Teste recovery-debug

Foram feitas alterações para forçar:

```text
ADB
console shell
class core
early-init
```

Resultado:

```text
nenhuma diferença observável
```

Isto sugere fortemente:

```text
o sistema não chega a executar
os blocos relevantes do init.rc
```

ou

```text
o bloqueio ocorre antes do userspace recovery funcionar
```

---

# Recovery debug construído

SHA256:

```text
recovery-debug.img
9ba71e36601640ab6cadd49b1d5492902a56b2e8ca4a87d753758beacc073ddd
```

Recovery original:

```text
0b275e078bcd1a1f2145ed4a8e95e9998a777fd7a21e835f4bd7a44eed4be52a
```

Logo:

```text
✓ imagens diferentes
✓ modificações realmente aplicadas
```

---

# Logs persistentes

Tentativa:

```text
CONFIG_PSTORE
ramoops
pstore
```

Resultado:

```text
nenhuma evidência encontrada
```

Neste momento não existe mecanismo conhecido para recolher logs persistentes.

---

# Hipótese principal atual

A hipótese mais forte neste momento é:

```text
Kernel assume controlo.

↓

Problema ocorre antes do userspace recovery ficar funcional.

↓

ADB nunca sobe.
Recovery nunca sobe.
UI nunca sobe.

↓

Bloqueio muito cedo no arranque.
```

---

# Próxima investigação

Prioridade máxima:

```text
Comparar recovery stock Samsung
vs
recovery Halium
```

Objetivo:

```text
extrair recovery.img stock

comparar:

- kernel
- dtb
- dtbo
- cmdline
- header
- offsets
- pagesize
- board
```

e determinar:

```text
se o problema está no kernel/dtb/dtbo
ou no userspace Halium
```

---

# Estado resumido

```text
Já não parece ser:

- Heimdall
- AVB
- PIT
- recovery partition
- boot partition
- SELinux
- bootdevice
- adbd desativado
- init.rc incompleto

O foco passou para:

kernel
dtb
dtbo
boot chain Samsung
arranque muito precoce antes do recovery userspace
```



---

# Retomada — estado após 2026-06-13

## Estado seguro

```text
O recovery original foi restaurado.
O tablet voltou a funcionar.
Não continuar com flashes de recovery reconstruído antes de entender AVB/repack.
```

## Última conclusão importante

Mesmo o recovery stock extraído e reempacotado sem alterações causou bootloop. Portanto, o método atual de reconstrução não produz uma imagem equivalente ao recovery original.

## Próximo passo recomendado

```text
1. Investigar como a build funcional gera e assina recovery.img.
2. Comparar AVB stock RSA vs imagens repack Algorithm NONE.
3. Evitar novos flashes até resolver o método de repack/assinatura.
4. Depois voltar à investigação do ramdisk Halium, que também parece estruturalmente incompatível com o recovery moderno.
```

## Não repetir sem nova análise

```text
Não flashar recovery-stock-clean-repack-avb.img.
Não assumir que mkbootimg + avbtool NONE reproduz o recovery stock.
Não continuar a editar init.rc sem resolver primeiro o problema de repack.
```

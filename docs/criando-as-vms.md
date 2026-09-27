# Criando as VMs

Não quis criar as máquinas clicando na interface do VirtualBox. Se eu precisar apagar tudo e recomeçar, prefiro rodar um comando só. Por isso fiz o [create-vms.ps1](../configs/create-vms.ps1), que usa o `VBoxManage`, a ferramenta de linha de comando que vem junto com o VirtualBox.

## O que o script faz

Ele cria duas VMs: `pfSense` e `UbuntuServer`. As duas têm 2 GB de RAM. Para o pfSense eu podia ter usado 1 GB, mas preferi dar folga.

Os discos são dinâmicos. Ocupam pouco no começo e vão crescendo conforme uso, até 20 GB no pfSense e 25 GB no Ubuntu.

Na rede, o pfSense ganha duas placas. A primeira em NAT, a segunda na rede interna `LAB-LAN`. O Ubuntu fica só na `LAB-LAN`.

Um detalhe: escolhi o modelo de placa Intel PRO/1000 (`82540EM`). O pfSense é baseado em FreeBSD e reconhece essa placa sem driver extra.

Cada VM também ganha um drive de DVD vazio, com boot pelo DVD primeiro. Assim é só anexar a ISO e ligar. Se eu rodar o script de novo com as VMs já criadas, ele avisa e pula em vez de quebrar.

## Rodando

Dentro da pasta do repositório:

```powershell
powershell -ExecutionPolicy Bypass -File .\configs\create-vms.ps1
```

O `-ExecutionPolicy Bypass` é porque o Windows bloqueia scripts `.ps1` por padrão.

## Conferindo

Depois de rodar, confiro se ficou tudo certo com:

```powershell
VBoxManage showvminfo pfSense --machinereadable
VBoxManage showvminfo UbuntuServer --machinereadable
```

As linhas que importam são `memory`, `nic1`, `nic2` e `intnet`. As duas VMs ficaram em `poweroff`, que é o esperado. O script não liga nada.

# Criando as VMs

Não quis criar as máquinas clicando na interface do VirtualBox. Se eu precisar apagar tudo e recomeçar, prefiro rodar um comando só. Por isso fiz o [create-vms.ps1](../configs/create-vms.ps1), que usa o `VBoxManage`, a ferramenta de linha de comando que vem junto com o VirtualBox.

O script mostra a montagem inicial. Depois mudei algumas coisas direto no VirtualBox, e conto isso mais abaixo.

## O que o script faz

Ele cria duas VMs: `pfSense` e `UbuntuServer`. As duas começam com 2 GB de RAM.

Os discos são dinâmicos. Ocupam pouco no começo e vão crescendo conforme uso, até 20 GB no firewall e 25 GB no Ubuntu.

Na rede, a VM do firewall ganha duas placas. A primeira em NAT, a segunda na rede interna `LAB-LAN`. O Ubuntu fica só na `LAB-LAN`.

Escolhi o modelo de placa Intel PRO/1000 (`82540EM`). O firewall é baseado em FreeBSD e reconhece essa placa sem driver extra.

Cada VM também ganha um drive de DVD vazio, com boot pelo DVD primeiro. Assim é só anexar a ISO e ligar. Se eu rodar o script de novo com as VMs já criadas, ele avisa e pula em vez de quebrar.

Para rodar, dentro da pasta do repositório:

```powershell
powershell -ExecutionPolicy Bypass -File .\configs\create-vms.ps1
```

O `-ExecutionPolicy Bypass` é porque o Windows bloqueia scripts `.ps1` por padrão.

Logo depois de criar, tirei um snapshot de cada VM chamado `antes-da-instalacao`, com as duas ainda sem sistema.

## O que mudei depois

Antes de instalar o firewall, voltei a VM `pfSense` para o snapshot `antes-da-instalacao`, aumentei a RAM para 3 GB e anexei a ISO `OPNsense-26.7-dvd-amd64.iso`:

```powershell
VBoxManage snapshot pfSense restore antes-da-instalacao
VBoxManage modifyvm pfSense --memory 3072
VBoxManage storageattach pfSense --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$env:USERPROFILE\Downloads\OPNsense-26.7-dvd-amd64.iso"
```

Troquei a segunda placa do firewall de `LAB-LAN` para host-only. Assim a LAN do OPNsense fica na mesma rede que o Windows, e consigo abrir a interface web pelo navegador.

Com isso a `LAB-LAN` ficou sem o firewall. Adicionei uma terceira placa nele, de novo na rede interna:

```powershell
VBoxManage modifyvm "pfSense" --nic3 intnet --intnet3 "LAB-LAN"
```

A placa da `UbuntuServer` ficou só na `LAB-LAN`:

```powershell
VBoxManage modifyvm "UbuntuServer" --nic1 intnet --intnet1 "LAB-LAN"
```

No fim, a VM do firewall ficou com NAT na placa 1, host-only na placa 2 e `LAB-LAN` na placa 3. Na VM `pfSense` também existe um snapshot `pronta-para-instalar`, que tirei depois da troca para host-only e antes de adicionar a terceira placa.

## Instalando o OPNsense

TODO: passos da instalação do OPNsense a partir da ISO e de como atribuí as interfaces e os IPs.

Depois de instalado, o hostname ficou `firewall-lab.localdomain`. A WAN (em0) pega IP por DHCP do NAT do VirtualBox, e recebeu 10.0.2.15/24. A LAN (em1) ficou com 192.168.56.10/24 e um servidor DHCP de 192.168.56.100 a 192.168.56.200. A OPT1 (em2) ficou com 10.10.10.1/24, e é o gateway da `LAB-LAN`.

Os prints dessa parte estão em [rede-lab-lan.md](rede-lab-lan.md).

# homelab-firewall

Meu laboratório de firewall em casa, montado no VirtualBox. Uma VM com pfSense fica no meio fazendo o papel de firewall. Atrás dela, um Ubuntu Server que só consegue sair para a internet passando pelo pfSense.

## Como está montado

O pfSense tem duas placas de rede. A primeira está em NAT e é a WAN, a saída para fora. A segunda fica numa rede interna do VirtualBox que chamei de `LAB-LAN`.

O Ubuntu Server tem uma placa só, ligada na `LAB-LAN`. Não tem outro caminho.

```
Internet ── NAT ── [ pfSense ] ── LAB-LAN ── [ UbuntuServer ]
```

| VM | RAM | Disco | Rede |
|---|---|---|---|
| pfSense | 2 GB | 20 GB | NAT + LAB-LAN |
| UbuntuServer | 2 GB | 25 GB | LAB-LAN |

## Onde parei

As duas VMs já existem. Criei com um script em PowerShell, o [create-vms.ps1](configs/create-vms.ps1), em vez de clicar tudo na interface. Elas ainda estão desligadas e sem sistema. O próximo passo é anexar as ISOs e instalar o pfSense e o Ubuntu.

## O que tem em cada pasta

Em `configs/` ficam os scripts e, mais pra frente, as configurações que eu exportar do pfSense. Em `docs/` estão minhas anotações: [como criei as VMs](docs/criando-as-vms.md) e [o que deu errado no caminho](docs/licoes-aprendidas.md). A pasta `screenshots/` ainda está vazia. Vou colocando os prints conforme avanço.

# create-vms.ps1
# Cria as VMs do laboratório homelab-firewall no VirtualBox (sem iniciá-las).
#   pfSense      : 2 GB RAM, 20 GB disco, NIC1 = NAT, NIC2 = rede interna LAB-LAN
#   UbuntuServer : 2 GB RAM, 25 GB disco, NIC1 = rede interna LAB-LAN

$ErrorActionPreference = 'Stop'

# --- Localiza o VBoxManage ---------------------------------------------------
$VBoxManage = (Get-Command VBoxManage -ErrorAction SilentlyContinue).Source
if (-not $VBoxManage) {
    $VBoxManage = Join-Path $env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'
}
if (-not (Test-Path $VBoxManage)) {
    throw "VBoxManage não encontrado. Instale o VirtualBox antes de rodar este script."
}

$InternalNet = 'LAB-LAN'

# Executa o VBoxManage e interrompe o script se o comando falhar
function Invoke-VBox {
    & $VBoxManage @args
    if ($LASTEXITCODE -ne 0) { throw "VBoxManage falhou: $($args -join ' ')" }
}

# Pasta padrão onde o VirtualBox guarda as VMs
$MachineFolder = ((& $VBoxManage list systemproperties) |
    Select-String '^Default machine folder:\s+(.+)$').Matches[0].Groups[1].Value.Trim()

function New-LabVM {
    param(
        [string]$Name,
        [string]$OsType,
        [int]$MemoryMB,
        [int]$DiskMB,
        [int]$Cpus = 1
    )

    if ((& $VBoxManage list vms) -match "^`"$Name`" ") {
        Write-Warning "A VM '$Name' já existe, pulando."
        return $false
    }

    Write-Host "Criando VM $Name..." -ForegroundColor Cyan
    Invoke-VBox createvm --name $Name --ostype $OsType --register
    Invoke-VBox modifyvm $Name --memory $MemoryMB --cpus $Cpus --vram 16 `
        --graphicscontroller vmsvga --boot1 dvd --boot2 disk --boot3 none --boot4 none

    # Controladora SATA + disco dinâmico (VDI)
    $Disk = Join-Path $MachineFolder "$Name\$Name.vdi"
    Invoke-VBox createmedium disk --filename $Disk --size $DiskMB --format VDI --variant Standard
    Invoke-VBox storagectl $Name --name 'SATA' --add sata --controller IntelAhci --portcount 2
    Invoke-VBox storageattach $Name --storagectl 'SATA' --port 0 --device 0 --type hdd --medium $Disk
    # Porta 1: drive de DVD vazio (depois é só anexar a ISO de instalação)
    Invoke-VBox storageattach $Name --storagectl 'SATA' --port 1 --device 0 --type dvddrive --medium emptydrive

    return $true
}

# --- pfSense -----------------------------------------------------------------
if (New-LabVM -Name 'pfSense' -OsType 'FreeBSD_64' -MemoryMB 2048 -DiskMB 20480) {
    # Adaptador 1: NAT (WAN)
    Invoke-VBox modifyvm 'pfSense' --nic1 nat --nictype1 82540EM
    # Adaptador 2: rede interna LAB-LAN (LAN)
    Invoke-VBox modifyvm 'pfSense' --nic2 intnet --intnet2 $InternalNet --nictype2 82540EM
}

# --- UbuntuServer ------------------------------------------------------------
if (New-LabVM -Name 'UbuntuServer' -OsType 'Ubuntu_64' -MemoryMB 2048 -DiskMB 25600) {
    # Adaptador 1: rede interna LAB-LAN
    Invoke-VBox modifyvm 'UbuntuServer' --nic1 intnet --intnet1 $InternalNet --nictype1 82540EM
}

Write-Host "`nVMs registradas:" -ForegroundColor Green
& $VBoxManage list vms
Write-Host "`nNenhuma VM foi iniciada. Anexe as ISOs antes do primeiro boot." -ForegroundColor Yellow

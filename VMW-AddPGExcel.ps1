#This script will add PortGroups and associated VLANIDs to Standard Virtual Switches in a Cluster from an Excel file
#Ensure the Excel file is using PGNAME and VLANID in the top columns

#Add-PSSnapin VMware.VimAutomation.Core
 #Variables
 $viserver = Read-Host -Prompt 'Enter vSphere Server Name or IP Address:'
 $cluster = Read-Host -Prompt 'Enter Cluster Name:'
 $vSwitch = Read-Host -Prompt 'Enter vSwitch:'
 $vmpg = import-csv C:\path\vmpgadd.csv

 Connect-VIserver $viserver -User "lmcc\" -Password ""
 $vmhosts = Get-Cluster $cluster | Get-VMhost

 ForEach ($item in $vmpg)
{
    $PGName = $item.("PGNAME")
    $PGVLANID = $item.("VLANID")


    ForEach ($vmhost in $vmhosts)
    {
      Get-VirtualSwitch -VMhost $vmhost -Name $vSwitch | New-VirtualPortGroup -Name $PGName -VlanId $PGVLANID
    }
}
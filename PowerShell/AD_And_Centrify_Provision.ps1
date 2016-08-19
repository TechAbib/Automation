#This script will add a linux server to AD, provision it in Centrify, and add it to the correct security group.

try
{

#Discover domain controller in target forest and site

    try
    {
        Get-ADDomainController -Discover -DomainName '[DOMAIN]' -SiteName '[DATACENTER]' -Writable -OutVariable 'ADServer' -ErrorAction Stop
        Set-CdmPreferredServer -Domain '[DOMAIN]' -Server $ADServer.HostName -ErrorAction Stop
    }
    catch
    {
        throw $_.Exception.Message
    }


#Add computer object to AD and provision in Centrify

    try
    {
        New-CdmManagedComputer -Name '[NAME]' -Zone '[ZONE]' -Container '[OU]'
    }
    catch
    {
        throw $_.Exception.Message
    }


#Wait for computer object to be discoverable in AD or timeout after 60 seconds

if ( -Not ( Get-ADComputer -Server $ADServer.HostName -Filter { Name -eq '[NAME]' } ) )
{
    $i = 0
    do
    {
        Wait-Event -Timeout 10
        $i++
    }
    until ( ( Get-ADComputer -Server $ADServer.HostName -Filter { Name -eq '[NAME]' } ) -or $i -eq 6 )   
}


#Add computer object to AD security group

try
{
    Add-ADGroupMember -Identity '[SECGROUP]' -Members ('[NAME]$') -Server $ADServer.HostName -ErrorAction Stop
}
catch
{
    throw $_.Exception.Message
}


}
catch
{
    throw $_.Exception.Message
}

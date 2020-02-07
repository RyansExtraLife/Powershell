function Move-DhcpServerv4Scope{
    <#
    .SYNOPSIS
    The Move-DhcpServerv4Scope moves a dhcp scope from a target server to a destenation server. 
        
    .DESCRIPTION
    The Move-DhcpServerv4Scope cmdlet moves a dhcp scope, its reservations, its exclusions, its options, 
    and its leases from a target server to destentaion server. The dhcp reservations, exclusions, options, 
    and leases are be excluded from the move by specifing a false value in their associated parameter. 
        
    .PARAMETER SourceServer
    Specifies the source dhcp server that the target scope resides on. 

    .PARAMETER DestenationServer
    Specifies the destenation server that the target scope will be moved to.

    .PARAMETER DhcpScopeId
    Specifes the dhcp scopeid that will be moved.

    .PARAMETER DhcpReservations
    Specifes if the cmdlet will move dhcp reservations from the target scope. 

    .PARAMETER DhcpExclusions
    Specifes if the cmdlet will move dhcp exclusions from the target scope. 

    .PARAMETER DhcpOptions
    Specifes if the cmdlet will move dhcp options from the target scope. 

    .PARAMETER DhcpLeases
    Specifes if the cmdlet will move dhcp leases from the target scope. 

    .OUTPUTS

        
    .EXAMPLE
    Migrate the dhcp scope with scopeId 192.168.0.1 from sfo1-dhcp01 to sfo1-dhcp02.
    C:\PS> Move-DhcpServerv4Scope -SourceServer sfo1-dhcp01 -DestenationServer sfo1-dhcp02 -DhcpScopeId 192.168.0.1
    
    .FUNCTIONALITY
    Windows DHCP
    #>

    [CmdletBinding()]
    Param(

        [Parameter(Mandatory=$true, HelpMessage = "Specify the hostname of the source dhcp server")]
        [ValidateScript({Test-Connection -ComputerName $_ -Count 1})]
        [string] $SourceServer,

        [Parameter(Mandatory=$true, HelpMessage = "Specify the hostname of the destenation dhcp server")]
        [ValidateScript({Test-Connection -ComputerName $_ -Count 1})]
        [string] $DestenationServer,

        [Parameter(Mandatory=$true, HelpMessage = "Specify the ScopeId of the target dhcp scope.")] 
        [IPAddress] $DhcpScopeId,

        [Parameter(HelpMessage = "Specify if dhcp reservations should be migrated")]
        [bool] $DhcpReservations = $true,

        [Parameter(HelpMessage = "Specify if dhcp exclusions should be migrated")]
        [bool] $DhcpExclusions = $true,

        [Parameter(HelpMessage = "Specify if dhcp options should be migrated")]
        [bool] $DhcpOptions = $true,

        [Parameter(HelpMessage = "Specify if dhcp leases should be migrated")]
        [bool] $DhcpLeases = $true
    )

    Begin{

        #Invoke Get-ADComputer on sourceServer parameter to set varible to ADComputer object. 
        try{
            Write-Verbose -Message "Invoking Get-ADComputer cmdlet on hostname: $SourceServer"
            $sourceADComputerObject = Get-ADComputer -Identity $SourceServer
        }catch{
            throw "Unable to invoke Get-ADComputer cmdlet on hostname: $SourceServer"
            break
        }

        #Invoke Get-ADComputer on destenationServer parameter to set varible to ADComputer object. 
        try{
            Write-Verbose -Message "Invoking Get-ADComputer cmdlet on hostname: $DestenationServer"
            $destenationADComputerObject = Get-ADComputer -Identity $DestenationServer   
        }catch{
            throw "Unable to invoke Get-ADComputer cmdlet on hostname: $DestenationServer"
            break
        }
    }

    Process{

        #Attempt to migrate the DHCP scope from the source server to the destination server. 
        try { 
            Write-Verbose -Message "Invoking Get-DhcpServerv4Scope on scope: $DhcpScopeId from server: $($sourceADComputerObject.Name)"
            $tempScope = Get-DhcpServerv4Scope -ComputerName $sourceADComputerObject.Name -ScopeId $dhcpScopeId 
            try{
                Write-Verbose -Message "Invoking Add-DhcpServerv4Scope object on $destenationServer"
                $tempScope | Add-DhcpServerv4Scope -ComputerName $destenationADComputerObject.Name
            }catch{
                throw "Unable to invoke Add-DhcpServerv4Scope on $($destenationADComputerObject.Name)"
                break
            }
        } catch {
            throw "Unable to invoke Get-DhcpServerv4Scope on $($sourceADComputerObject.name)"
            break
        }    

        #Migrate DHCP Reservations from source server to destination server. 
        if ($DhcpReservations){ 
            try{
                Write-Verbose -Message "Invoking Get-Dhcpv4Reservation on scope: $DhcpScopeId from server: $($sourceADComputerObject.Name)"
                $tempReservations = Get-DhcpServerv4Reservation -computername $sourceADComputerObject.Name -ScopeId $dhcpScopeId 
                
                if ($tempReservations){
                    try {
                        Write-Verbose -Message "Invoking Add-DhcpServerv4Reservation on $($destenationADComputerObject.Name)"
                        $tempReservations | Add-DhcpServerv4Reservation -ComputerName $destenationADComputerObject.Name -ScopeId $dhcpScopeId
                    }catch{
                        throw "Unable to invoke Add-DhcpServerv4Reservation on $($destenationADComputerObject.name)"
                    }
                }else{
                    Write-Verbose -Message "Get-DhcpServerv4Reservations returned null."
                }
            }catch{
                throw "Unable to invoke Get-DhcpServerv4Reservation on $($sourceADComputerObject.name)"
            }
        }

        #Migrate DHCP Exclusions from source server to destination server. 
        if ($DhcpExclusions){
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4ExclusionRange on scope: $DhcpScopeId on server: $($sourceADComputerObject.Name)"
                $tempExclusions = Get-DhcpServerv4ExclusionRange -ComputerName $sourceADComputerObject.Name -ScopeId $dhcpScopeId 
                
                if($tempExclusions){
                    try{
                        Write-Verbose -Message "Invoking Add-DhcpServerv4ExclusionRange on $($destenationADComputerObject.Name)"
                        $tempExclusions | Add-DhcpServerv4ExclusionRange -ComputerName $destenationADComputerObject.Name -ScopeId $dhcpScopeId
                    }catch{
                        throw "Unable to invoke Add-DhcpServerv4ExclusionRange on $($destenationADComputerObject.name)"
                    }
                }else{
                    Write-Verbose -Message "Get-DhcpServerv4ExclusionsRange returned null."
                }
            }catch{
                throw "Unable to invoke Get-DhcpServerv4ExclusionRange on $($sourceADComputerObject.name)"
            }
        }

        #Migrate DHCP Options from source server to destination server. 
        if ($DhcpOptions){  
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4OptionValue on scope: $DhcpScopeId from server: $($sourceADComputerObject.Name)"
                $tempOptions = Get-DhcpServerv4OptionValue -ComputerName $sourceADComputerObject.Name -ScopeId $dhcpScopeId 
                
                if($tempOptions){
                    try{
                        Write-Verbose -Message "Invoking Set-DhcpServerv4OptionValue on $($destenationADComputerObject.Name)"
                        $tempOptions | Set-DhcpServerv4OptionValue -ComputerName $destenationADComputerObject.Name -ScopeID $dhcpScopeId
                    }catch{
                        throw "Unable to invoke Add-DhcpServerv4OptionsValue on $($destenationADComputerObject.name)"
                    }   
                }else{
                    Write-Verbose -Message "Get-DhcpServerv4OptionValue returned null."
                }
            }catch{
                throw "Unable to invoke Get-DhcpServerv4OptionValue on $($sourceADComputerObject.name)"
            }
        }

        #Migrate DHCP Leases from source server to destination server. 
        if ($DhcpLeases){
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4Lease on scope: $DhcpScopeId from server: $($sourceADComputerObject.Name)"
                $tempLeases = Get-DhcpServerv4Lease -ComputerName $sourceADComputerObject.Name -ScopeId $dhcpScopeId 
                
                if($tempLeases){
                    try{
                        Write-Verbose -Message "Invoking Add-DhcpServerv4Lease on $($destenationADComputerObject.Name)"
                        $tempLeases | Set-DhcpServerv4Lease -ComputerName $destenationADComputerObject.Name -ScopeID $dhcpScopeId
                    }catch{
                        throw "Unable to invoke Add-DhcpServerv4Lease on $($destenationADComputerObject.name)"
                    }  
                }else{
                    Write-Verbose -Message "Get-DhcpServerv4Lease returned null."
                }
            }catch{
                throw "Unable to invoke Get-DhcpServerv4Lease on $($sourceADComputerObject.name)"
            }
        }
    }

    End{

    }
} 



































function Move-DhcpServerv4Scope{

    [CmdletBinding()]
    Param(

        [Parameter(Mandatory=$true, HelpMessage = "Specify the hostname of the source dhcp server")]
        [ValidateScript({Test-Connection -ComputerName $_ -Count 1})]
        [string] $sourceServer,

        [Parameter(Mandatory=$true, HelpMessage = "Specify the hostname of the destenation dhcp server")]
        [ValidateScript({Test-Connection -ComputerName $_ -Count 1})]
        [string] $destenationServer,

        [Parameter(Mandatory=$true, HelpMessage = "Specify the ScopeId of the target dhcp scope.")] 
        [IPAddress] $dhcpScopeId,

        [Parameter(HelpMessage = "Specify if dhcp reservations should be migrated")]
        [bool] $dhcpReservations = $true,

        [Parameter(HelpMessage = "Specify if dhcp exclusions should be migrated")]
        [bool] $dhcpExclusions = $true,

        [Parameter(HelpMessage = "Specify if dhcp options should be migrated")]
        [bool] $dhcpOptions =$true,

        [Parameter(HelpMessage = "Specify if dhcp leases should be migrated")]
        [bool] $dhcpLeases = $true
    )

    Begin{

        #Invoke Get-ADComputer on sourceServer parameter. 
        try{
            Write-Verbose -Message "Invoking Get-ADComputer cmdlet on hostname: $sourceServer"
            $sourceADComputerObject = Get-ADComputer -Identity $sourceServer 
        }catch{
            throw "Unable to invoke Get-ADComputer cmdlet on hostname: $sourceServer"
            break
        }

        #Invoke Get-ADComputer on destenationServer parameter. 
        try{
            Write-Verbose -Message "Invoking Get-ADComputer cmdlet on hostname: $destenationServer"
            $destenationADComputerObject = Get-ADComputer -Identity $destenationServer   
        }catch{
            throw "Unable to invoke Get-ADComputer cmdlet on hostname: $destenationServer"
            break
        }
    }

    Process{

        #Attempt to migrate the DHCP scope from the source server to the destination server. 
        try { 
            Write-Verbose -Message "Invoking Get-DhcpServerv4Scope on scope: $dhcpScopeId from server: $($sourceADComputerObject.Name)"
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
        if ($dhcpReservations){ 
            try{
                Write-Verbose -Message "Invoking Get-Dhcpv4Reservation on scope: $dhcpScopeId from server: $($sourceADComputerObject.Name)"
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
        if ($dhcpExclusions){
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4ExclusionRange on scope: $dhcpScopeId on server: $($sourceADComputerObject.Name)"
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
        if ($dhcpOptions){  
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4OptionValue on scope: $dhcpScopeId from server: $($sourceADComputerObject.Name)"
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
        if ($dhcpLeases){
            try{
                Write-Verbose -Message "Invoking Get-DhcpServerv4Lease on scope: $dhcpScopeId from server: $($sourceADComputerObject.Name)"
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



































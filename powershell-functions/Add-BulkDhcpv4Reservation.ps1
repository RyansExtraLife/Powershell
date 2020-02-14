function Add-BulkDhcpv4Reservation {  
    <#
        .SYNOPSIS
        The function imports a .CSV and bulk creates DHCP reservations on a specified DHCP server.
        .DESCRIPTION
        The function will import a .csv and bluck create reservations wihtin a DHCP server. 
        .EXAMPLE
        Add-BulkDhcpv4Scopes -FilePath "C:\Dekstop\Scopes.CSV"
    #>

    [CmdletBinding()]
    param (
        # Specifies the file path to the .Csv file that will be used to preform reservations. 
        [Parameter(ParameterSetName = 'BulkCreation', Mandatory, Position = 0)]
        [ValidateNotNullorEmpty()]
        [ValidateScript({
            #Test the filepath to ensure passed in file exists.  
            If (Test-Path -Path $_) {
                #Tests the filetype to enusre it is compatiable.
                If ($_ -Match "^.+.\.(xlsx|xls|csv)$" ){
                    $True
                } else {
                    Throw "'$_' is not a valid file type."
                }
            } else {
                Throw "'$_' is not a valid file path."
            }
        })]
        [String]$FilePath,

        # Specifies the DHCP Server that the resrvation will be made on. 
        [Parameter(ParameterSetName = 'BulkCreation', Mandatory)]
        [ValidateNotNullorEmpty()]
        [ValidateScript({
            If (Test-Connection -ComputerName $_){
                $True
            } else {
                Throw "'$_' is not a reachable server"
            }
        })]
        [String]$DHCPServer,

        # Specifies the DHCP Scope that will be used in creating the reservation. 
        [Parameter(ParameterSetName = 'BulkCreation',Mandatory)]
        [ValidateNotNullorEmpty()]
        [ValidateScript({
            If (Test-DhcpServer4Scope -ScopeId $_){
                $True
            } else {
                Throw "'$_' is not a valid IPScope"
            }
        })]
        [IPAddress]$ScopeID,

        [Parameter(Mandatory,ParameterSetName = 'BulkCreaton')]
        [bool]$CommandLineOutput = $true
    )
    begin {
        if($CommandLineOutput){
            Write-Host "Add-BulkDhcpv4Scopes Function: Begin"
        }
        #Clear Error Cache
        if ($errors -is [object]) {
            $errors.clear()
        }
        
        #Local Variables
        $reservationCSV = Import-Csv -Path $FilePath -Delimiter "," 
        $reservationsCreatedCount = 0
        $reservationsFailedCount = 0
        $missingColumnCount =0

        #Test CSV for correct Column Headers 
        $requiredColumns = "IP Address", "Description", "Mac Address"
        if($CommandLineOutput){
            Write-Host "Validating .CSV column headers"
        }
        $csvTest = $reservationCSV  | Get-Member
        foreach ($requiredColumn in $requiredColumns){
            if (!($csvTest | Where-Object {$_.Name -eq $requiredColumn})){
                Write-Error "$inputFile is missing the $requiredColumn column"
                $missingColumnCount ++
            }
        }
        #If Column is missing return out of function
        if ($missingColumnCount -ne 0){
            Write-Error "Unable to import .csv due to imporper headings"
            Break
        } 
    }
    process {
        #Attempt to create a reservation for each row within imported .CSV
        foreach($reservation in $reservationCSV){ 
            try{ 
                Write-Host "Attempting DHCP reservation of $reservation"
                #Test if the reservation has a valid mac address
                $TempMacAddress = ($reservation.'MAC address').replace( ":", "-") 
                if($TempMacAddress-eq $null ){ 
                    Write-Host "No Mac Address exists for $reservation"
                    continue 
                }else{
                    if($TempMacAddress -Match '^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$') {
                        continue
                    }else{
                        Write-Host "$_ is not a valid Mac Address"
                    }
                }
                if($CommandLineOutput){
                    Write-Host "Testing if ScopeID is a valid Scope"
                }
                If(Test-DhcpServer4Scope -ScopeId $reservation.'IP Address'){
                    continue
                }else{
                    Throw "'$_' is not a valid IPScope"
                }
                #Test if the reservation has a null Hostname. 
                If ($reservation.'Hostname' -eq $null){
                    continue
                }else{
                    Write-Host "'$_' has an null hostname. "
                }
                try{
                    Add-DhcpServerv4Reservation -ComputerName $DHCPServer  -ScopeId $ScopeID -Description $reservation.'Description' -IPAddress $reservation.'IP Address' -Name $reservation.'Hostname' -ClientId TempMacAddress -Type DHCP
                    Write-Host "DHCP resrvation Created for $reservation"
                    $reservationsCreatedCount ++
                }catch{
                    Write-Host "Unable to create DHCP Reservation with ScopeID $ScopeID on the server $DHCPServer"
                }
            }catch{
                Write-Host"Error creating $reservation - $($_.Exception.Message)"
                $reservationsFailedCount ++
            }
        }   
    } 
    end{
        Write-Host "$reservationsCreated reservations created on $DHCPServer"
        Write-Host "$reservationsFailed reservations not created $DHCPServer"
        if($CommandLineOutput){
            Write-Host "Add-DHCPReservation Function: End"
        }
    }
}




 

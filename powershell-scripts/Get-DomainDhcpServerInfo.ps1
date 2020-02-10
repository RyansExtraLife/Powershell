#Function Definitions 

Function Process-DHCPScopeOptions($dhcpOptions){
    
    #Tests DHCP Scope Options for Null.
    if($dhcpOptions -NE $Null){

        #Creates headers for DHCP Scope Options in Excel Worksheet. 
    $lastRow = $currentExcelWorksheet.UsedRange.rows.count +2
        $currentExcelWorksheet.Cells.Item$lastRow,3) = "Option Name"
        $currentExcelWorksheet.Cells.Item$lastRow,3).Font.Bold= $True
        $currentExcelWorksheet.Cells.Item$lastRow,3).Font.Underline = $True
        $currentExcelWorksheet.Cells.Item$lastRow,4) = "Option Id"
        $currentExcelWorksheet.Cells.Item$lastRow,4).Font.Bold= $True
        $currentExcelWorksheet.Cells.Item$lastRow,4).Font.Underline = $True
        $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
        $currentExcelWorksheet.Cells.Item$lastRow,5) = "Option Type"
        $currentExcelWorksheet.Cells.Item$lastRow,5).Font.Bold= $True
        $currentExcelWorksheet.Cells.Item$lastRow,5).Font.Underline = $True
        $currentExcelWorksheet.Cells$lastRow,5).HorizontalALignment = -4108
        $currentExcelWorksheet.Cells.Item$lastRow,6) = "Option Value 1"
        $currentExcelWorksheet.Cells.Item$lastRow,6).Font.Bold= $True
        $currentExcelWorksheet.Cells.Item$lastRow,6).Font.Underline = $True
        $currentExcelWorksheet.Cells$lastRow,6).HorizontalALignment = -4108
        $currentExcelWorksheet.Cells.Item$lastRow,7) = "Option Value 2"
        $currentExcelWorksheet.Cells.Item$lastRow,7).Font.Bold= $True
        $currentExcelWorksheet.Cells.Item$lastRow,7).Font.Underline = $True
        $currentExcelWorksheet.Cells$lastRow,7).HorizontalALignment = -4108

        #Sorts the DHCP Scopes Options numerically by OptionID. 
        $dhcpOptions = $dhcpOptions | Sort-Object -Property OptionId

        #Iterates through each DHCP Option in the current Scope.
        forEach($dhcpOption in $dhcpOptions){
            
            #Appends DHCP Scope Option Information to Excel Worksheet.
            $lastRow = $currentExcelWorksheet.UsedRange.rows.count +1
            $currentExcelWorksheet.Cells.Item$lastRow,3) =$dhcpOption.Name
            $currentExcelWorksheet.Cells.Item$lastRow,4) =$dhcpOption.OptionId
            $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,5) =$dhcpOption.Type
            $currentExcelWorksheet.Cells$lastRow,5).HorizontalALignment = -4108
            
            if($dchpOption.Type -EQ "IPv4Address"){
                $multivaluedVariable  = $Null
                $multivaluedVariable = $DHCPOption.Value
                $currentExcelWorksheet.Cells.Item$lastRow,6) = $MultivaluedVariable[0]
                $currentExcelWorksheet.Cells$lastRow,6).HorizontalALignment = -4108
                $currentExcelWorksheet.Cells.Item$lastRow,7) = $MultivaluedVariable[1]
                $currentExcelWorksheet.Cells$lastRow,7).HorizontalALignment = -4108
            }else{
                $currentExcelWorksheet.Cells.Item$lastRow,6) =$DHCPOption.Value 
                $currentExcelWorksheet.Cells$lastRow,6).HorizontalALignment = -4108
            }
        }
    }
}

Function Process-DHCPScope ($DHCPServerScopes){
    
    #Tests DHCPServerScope for Null.
    if($dhcpServerScopes -NE $Null){ 

        #Cycles through each DHCP Scope in the current Server. 
        forEach($dhcpScope in $dhcpServerScopes){
            #Creates headers for DHCP Scope in Excel Worksheet. 
            $lastRow = $currentExcelWorksheet.UsedRange.rows.count +2
            $currentExcelWorksheet.Cells.Item($lastRow,2) = "Scope Name"
            $currentExcelWorksheet.Cells.Item$lastRow,2).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,2).Font.Underline = $True
            $currentExcelWorksheet.Cells.Item$lastRow,3) = "Scope State"
            $currentExcelWorksheet.Cells.Item$lastRow,3).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,3).Font.Underline = $True
            $currentExcelWorksheet.Cells.Item$lastRow,4) = "Scope Id"
            $currentExcelWorksheet.Cells.Item$lastRow,4).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,4).Font.Underline = $True
            $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,5) = "Lease Duration"
            $currentExcelWorksheet.Cells.Item$lastRow,5).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,5).Font.Underline = $True
            $currentExcelWorksheet.Cells$lastRow,5).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,6) = "IP Start Range"
            $currentExcelWorksheet.Cells.Item$lastRow,6).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,6).Font.Underline = $True
            $currentExcelWorksheet.Cells$lastRow,6).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,7 )= "IP End Range"
            $currentExcelWorksheet.Cells.Item$lastRow,7).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,7).Font.Underline = $True
            $currentExcelWorksheet.Cells$lastRow,7).HorizontalALignment = -4108
            
            #Appends DHCP Scope Information to Excel Worksheet.
            $lastRow = $currentExcelWorksheet.UsedRange.rows.count +1
            $currentExcelWorksheet.Cells.Item$lastRow,2) = $DHCPScope.Name
            $currentExcelWorksheet.Cells.Item$lastRow,3) = $DHCPScope.State
            $currentExcelWorksheet.Cells.Item$lastRow,4) = $DHCPScope.ScopeId.IPAddressToString
            $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,5) = $DHCPScope.LeaseDuration.Hours
            $currentExcelWorksheet.Cells$lastRow,5).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,6) = $DHCPScope.StartRange.IPAddressToString
            $currentExcelWorksheet.Cells$lastRow,6).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,7) = $DHCPScope.EndRange.IPAddressToString
            $currentExcelWorksheet.Cells$lastRow,7).HorizontalALignment = -4108
            
            #Gets DHCP Options on the Scope level.
            try{
                $dhcpOptions = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer.DnsName -ScopeId $dhcpScope.ScopeId
                Process-DHCPScopeOptions $dhcpOptions
            }catch{
                throw "Unable to invoke Get-DhcpServerv4OptionValue on $($dhcpServer.DnsName)"
            }
        } 
    }
}

Function Process-DHCPFailoverScope($DHCPServerFailoverScopes){
    
    #Tests DHCPServerFailoverScope for Null
    If($dhcpServerFailoverScopes -NE $Null){
        ForEach($dhcpServerFailoverScope in $dhcpServerFailoverScopes){
            #Creates headers for DHCP Scope in Excel Worksheet. 
            $lastRow = $currentExcelWorksheet.UsedRange.rows.count +3
            $currentExcelWorksheet.Cells.Item$lastRow,2) = "Failover Scope Name"
            $currentExcelWorksheet.Cells.Item$lastRow,2).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,2).Font.Underline = $True
            $currentExcelWorksheet.Cells.Item$lastRow,3) = "Failover Scope Server Role"
            $currentExcelWorksheet.Cells.Item$lastRow,3).Font.Bold= $True
            $currentExcelWorksheet.Cells$lastRow,3).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,4) = "Failover Scope Mode"
            $currentExcelWorksheet.Cells.Item$lastRow,4).Font.Bold= $True
            $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,5) = "Partner Server"
            $currentExcelWorksheet.Cells.Item$lastRow,5).Font.Bold= $True
            $currentExcelWorksheet.Cells.Item$lastRow,6) = "Reserve Percent"
            $currentExcelWorksheet.Cells.Item$lastRow,6).Font.Bold= $True

            #Appends DHCP Scope Information to Excel Worksheet.
            $lastRow = $currentExcelWorksheet.UsedRange.rows.count +1
            $currentExcelWorksheet.Cells.Item$lastRow,2) = $DHCPServerFailoverScope.Name
            $currentExcelWorksheet.Cells.Item$lastRow,4) = $DHCPServerFailoverScope.Mode
            $currentExcelWorksheet.Cells$lastRow,4).HorizontalALignment = -4108
            $currentExcelWorksheet.Cells.Item$lastRow,5) = $DHCPServerFailoverScope.PartnerServer
            $currentExcelWorksheet.Cells.Item$lastRow,6) = $DHCPServerFailoverScope.ReservePercent
        }
    }
}

#Main Script

#Collects DHCP Server Information from DOmain Controller. 
Write-Host "Collecting DHCP Server information"
$DHCPServers = Get-DHCPServerinDC

$TotalServers = $DHCPServers.Count
$ProgressCounter = $Null

#Creates new Excel Workbook.
$ExcelDocument = New-Object -ComObject Excel.Application
$ExcelWorkbook = $ExcelDocument.Workbooks.Add()


#Cycles through all DHCP Servers in reverse order. 
For ($x= $TotalServers; $x -gt 0; $x--){ 
    #Declares current DHCP Server from DHCP Servers array.
    $DHCPServer = $DHCPServers[$x -1]

    #Creates Progress Tracker. 
    $ProgressCounter++ 
    $PercentComplete = $ProgressCounter / $TotalServers * 100
    Write-Progress -Activity "Getting DHCP Server Information" -status "Percent Complete: $PercentComplete%" -PercentComplete $PercentComplete  -CurrentOperation "  Processeing Server: $($DHCPServer.DnsName)"

    #Creates new Excel Worksheet for current DHCP Server.
    $currentExcelWorksheet= $ExcelWorkbook.Worksheets.Add()
    $currentExcelWorksheet.Name = "$($DHCPServer.DNSName)"
    $ExcelWorkbook.ActiveSheet.PageSetup.PrintGridlines = $False
    $ExcelDocument.ActiveWindow.DisplayGridlines = $False

    #Creates headers for DHCP Server Information in Excel Worksheet.
    Write-Host "Collecting Server Information: "$($DHCPServer.DnsName)""
    $currentExcelWorksheet.Cells.Item(1,3) = "Server Name: "
    $currentExcelWorksheet.Cells.Item(1,3).Font.Bold= $True
    $currentExcelWorksheet.Cells.Item(1,5) = "Server IP Address: "
    $currentExcelWorksheet.Cells.Item(1,5).Font.Bold= $True

    #Appends DHCP Server Information to Excel Worksheet
$lastRow = $currentExcelWorksheet.UsedRange.rows.count
    $currentExcelWorksheet.Cells.Item(1,4) = $DHCPServer.DnsName 
    $currentExcelWorksheet.Cells.Item(1,6) = $DHCPServer.IPAddress.IPAddressToString

    #Gets DHCP Options on the Server level.
    $DHCPServerOptions = $Null
    $DHCPServerOptions = Get-DHCPServerv4OptionValue -ComputerName $DHCPServer.DnsName
    Process-DHCPOptions $DHCPServerOptions

    #Gets Active DHCP Scopes on the Server.
    Write-Host "Collecting Server Scope Information: "$($DHCPServer.DnsName)""
    $DHCPServerScopes = $Null
    $DHCPServerScopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer.DnsName -ErrorAction:SilentlyContinue 
    Process-DHCPScope $DHCPServerScopes

    #Gets DHCPFailover Scopes on the Server.
    Write-Host "Collecting Server Failover Information: "$($DHCPServer.DnsName)""
    $DHCPServerFailoverScopes = $Null
    $DHCPServerFailoverScopes = Get-DHCPServerv4Failover -ComputerName $DHCPServer.DnsName -ErrorAction:SilentlyContinue 
    Process-DHCPFailoverScope $DHCPServerFailoverScopes

    #
    $FormatWorksheet = $currentExcelWorksheet.UsedRange 
    $FormatWorksheet.EntireColumn.Autofit() | Out-Null

    #Provides Status Update on Server
    Write-Host "Done Processing: "$($DHCPServer.DnsName)"" 

    
} 

  
#Appends Title and saves current Workbook to filepath.
$FileExtension = ".xlsx"
$CurrentUser = $env:Username
$FilePath="C:\Users\$CurrentUser\DHCPServerInformaion$FileExtension"
$ExcelWorkbook.SaveAs($FilePath) 
$ExcelWorkbook.Close
$ExcelDocument.Quit()




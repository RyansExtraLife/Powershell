function Add-Dhcpv4DomainSearchList{
    <#
    .SYNOPSIS
    The Add-Dhcpv4DomainSearchList converts the provided dns zone list to hex and appends it to Option 119 on a dhcp scope.
        
    .DESCRIPTION
    The Add-Dhcpv4DomainSearchList cmdlet converts a list of DNS zones provided in comman seperated string value into hex.
	The cmdlet then iterates through an array of ScopeIds on a target DHCP server and sets DHCP option 119 to the converted
	hex value on the provided dhcp scopes.
        
    .PARAMETER DhcpServer
	Specifies the source dhcp server that the cmdlet will target. 

	.PARAMETER DhcpScopeID
	Specifies the source dhcp scopes(s) that the cmdlet will target. 
	
	.PARAMETER DnsSuffixSearchList
	Specifies the dns zones that will be converted to hex and appened to option 119 on the dhcp scope. If multiple DNS zones are 
	passed they will need to be sperated by a single comman with no leading or trailing spaces. 

    .OUTPUTS
  
    .EXAMPLE
    Append Option 119 to scope 192.168.0.10 on dhcp server sfo1-dhcp01.
    C:\PS> Add-Dhcpv4DomainSearchList -DhcpServer sfo1-dhcp01 -DhcpScopeId 192.168.0.1 -DnsSuffixSearchList "example.lab.com,example.corp.com,example.prod.com"
    
    .FUNCTIONALITY
    Windows DHCP
    #>
	
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true, HelpMessage = "Specify the hostname of the target dhcp server.")]
        [ValidateScript({Test-Connection -ComputerName $_ -Count 1})]
		[String]$DhcpServer,

		[Parameter(Mandatory=$true, HelpMessage = "Specify the ScopeId(s) of the target dhcp scope.")] 
		[IPAddress[]]$DhcpScopeId,
		
		[Parameter(Mandatory=$true, HelpMessage = "Specify the DNS suffix search list that will be converted to hex.")] 
		[string]$DnsSuffixSearchList
	)

	Begin{

		#Local function variables. 
		$dhcpv4Scopes = @()
		$hexDnsSuffixSearchList = @()
		
		#Invoke Get-ADComputer cmdlet on DhcpServer parameter to set varible to ADComputer object. 
		try { 
			Write-Verbose -Message "Invoking Get-ADComputer cmdlet on hostname: $DhcpServer"
            $targetADComputerObject = Get-ADComputer -Identity $DhcpServer
		}catch{
			throw "Unable to invoke Get-ADComputer cmdlet on hostname: $DhcpServer"
			break
		}

		#Validate to see if DHCP Option 119 is defined on DHCP Server. 
		try {
			Write-Verbose -Message "Invoking Get-DhcpServerv4OptionDefinition cmdlet on hostname: $($targetADComputerObject.Name)"
			$tempOptionDefinition = Get-DhcpServerv4OptionDefinition -ComputerName $targetADComputerObject.Name -OptionId 119
			if ($tempOptionDefinition -eq $null){
				Write-Host "DHCP Option 119 is not defined on DHCP Server: $($targetADComputerObject.Name). Exiting Function."
			}
		}catch{
			throw "Unable to invoke Get-DhcpServerv4OptionDefinition cmdlet on $($targetADComputerObject.Name)"
			break
		}

		#Invoke Get-DhcpServerv4Scope cmdlet on each passed DhcpScopeId parameter passed and assing the scope to an array.
		foreach($ScopeId in $DhcpScopeId){
			try{
				Write-Verbose -Message "Invoking Get-DhcpServerv4Scope cmdlet on scope: $ScopeId on DHCP Server: $($targetADComputerObject.Name)"
				$tempDhcpScope = Get-DhcpServerv4Scope -DhcpServer $targetADComputerObject -ScopeID $ScopeID
				Write-Verbose -Message "Appending $tempDhcpScope to Dhcpv4Scopes Array."
				$dhcpv4Scopes += $tempDhcpScope
			}catch{
				throw "Unable to invoke Get-DhcpServerv4Scope cmdlet on $ScopeId"
			}
		}

		Write-Verbose -Message "Spliting each DnsSuffixSearchList variable into suffix array elements."
		$dnsSuffixArray = $DnsSuffixSearchList -split "\,"

		#Iterate through each dns suffix and convert to hex.
		foreach ($dnsSuffix in $dnsSuffixArray) {
				
			#Sperate each DNS zone at each dot.
			Write-Verbose -Message "Spliting dnsSuffix: $dnsSuffix variable into zone array elements."
			$dnsZonesArray = $dnsSuffix -split "\."
				
			#Iterate through each DNS zone and converst to char.
			foreach ($dnsZone in $dnsZonesArray) {
				Write-Verbose -Message "Splitting dnsZone: $dnsZone variable into char array elements."
				$wordLength = $dnsZone.Length
				$dnsCharArray= @()
				$dnsCharArray += $wordLength
				$dnsCharArray += $dnsZone.ToCharArray()
					
				#Itterate through each 
				Write-Verbose -Message "Appending converted dnsCharArray as hex to hexDnsSuffixSearchList."
				foreach ($element in $dnsCharArray) {
					$hex = "0x" + [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($element))
					$hexDnsSuffixSearchList  += $hex
				}		
			}

			#Seperate each DNS Suffix with a 0x0.
			Write-Verbose -Message "Appending 0x0 to end of $dnsSuffix zone itteration."
			$hexDnsSuffixSearchList  += "0x0"
		}
	}

	Process {

		#Test connection to the DHCP server. 
		Write-Verbose -Message "Testing Connection on DHCP Sever: $($targetADComputerObject.Name)"
		if (Test-Connection -ComputerName $targetADComputerObject.Name -Quiet -Count 1){

			#Iterate through each valid dhcpScope passed to the function.
			foreach ($dhcpScope in $dhcpv4Scopes) {	
						
				try{
					Write-Verbose "Invoking Set-DhcpServerv4OptionValue on dhcp scope: $($dhcpScope.ScopeID) on DHCP Server: $($targetADComputerObject.Name)"
					Set-DhcpServerv4OptionValue -Computername $targetADComputerObject.Name -ScopeID $dhcpScope.ScopeID -OptionId 119 -Value $hexDnsSuffixSearchList 
				}catch{
					throw "Unable to invoke Set-DhcpServerv4OptionValue cmdlet on dhcp scope: $($dhcpScope.ScopeID) on DHCP Server: $($targetADComputerObject.Name)"
				}
			}
		}else{
			Write-Host "Unable to verify connection on DHCP Server: $($targetADComputerObject.Name)"
		}
	}

	End {

		Write-Verbose -Message "Validating Option 119 Set on passed DHCP scopes."
		#Iterate through each valid dhcpScope passed to the function.
		foreach ($dhcpScope in $dhcpv4Scopes) {	
			
			#Compare the value of option 119 in the dhcp scope to the passed Dns Suffix Search List.
			try{
				$tempOptionValue = Get-DhcpServerv4OptionValue -Computername $targetADComputerObject.Name -ScopeID $dhcpScope.ScopeID -OptionId 119
				if($tempOptionValue.value -eq $hexDnsSuffixSearchList){
					Write-Verbose -Message "Dns Suffix Search List was appeneded to Option 119 on dhcp scope: $($dhcpScope.ScopeID) on DHCP Server: $($targetADComputerObject.Name)"
				}else{
					Write-Verbose -Message "Unable to validate if Dns Suffix Search List was appeneded to Option 119 on dhcp scope: $($dhcpScope.ScopeID) on DHCP Server: $($targetADComputerObject.Name)"
				}
			}catch{
				throw "Unable to invoke Get-DhcpServerv4OptionValue on dhcp scope: $($dhcpScope.ScopeID) on DHCP Server: $($targetADComputerObject.Name)"
			}
		}
	}
}































#Script Parameters
param (
    #Varibles that store each of the the two group names. 
    [string]$groupOneName = '',
    [string]$groupTwoName = '',

    #Varibles that store the AD Group Object of each gorup.
    $firstGroupDN = @(),
    $secondGroupDN = @(),

    #Varibles that store the SamAccountName of each user nested in each group. 
    $firstGroupSAN = @(),
    $secondGroupSAN = @(),

    #Varible that holds all ADUser objects in each of the groups. 
    $allUsers = @(),

    #Varibles that store ADUser objects depending on membership.    
    $uniqueGroupOne = @(),
    $uniqueGroupTwo = @(),
    $usersinAllGroups = @()
)

#Converts the first string variable to ADGroup object. 
try {
    $firstGroupDN  = Get-ADGroup -Identity $groupOneName -Properties Member | Select -ExpandProperty Member
}catch{
    throw "Unable to invoke Get-ADGroup cmdlet on: $groupOneName"
    break
}

#Converts the second string variable to ADGroup object. 
try {
    $secondGroupDN = Get-ADGroup -Identity $groupTwoName -Properties Member | Select -ExpandProperty Member
}catch{
    throw "Unable to invoke Get-ADGroup cmdlet on: $groupOneName"
    break
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $firstGroupDN.Count

forEach ($user in $firstGroupDN){

    #Updates progress through each itteration for converting group one from DistinguesdNames to SamAccount Names. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($percentComplete)
    Write-Progress -Activity "[1/4] Converting $groupOneName DistinguisedNames to SamAccountNames" -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"
    
    #Converts group members to ADUser Objects. 
    try{
        $tempUser = Get-ADUser -Identity $user
        $firstGroupSAN  += $tempUser.SamAccountName
    }catch{
        Write-Host "Unable to invoke Get-ADUser cmdlet on: $user"
    }
}

#Iterate through each user in group one and add them to all users. 
forEach ($user in $firstGroupSAN){
    if($allUsers -notcontains $user){
        $allUsers += $user
    }
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $firstGroupDN.Count

forEach ($user in $secondGroupDN){
    
    #Updates progress through each itteration for converting group two from DistinguesdNames to SamAccount Names. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($PercentComplete)
    Write-Progress -Activity "[2/4] Converting $groupTwoName DistinguisedNames to SamAccountNames" -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"
    
    #Converts group members to ADUser Objects. 
    try{
        $tempUser = Get-ADUser -Identity $user
        $secondGroupSAN += $tempUser.SamAccountName
    }catch{
        Write-Host "Unable to invoke Get-ADUser cmdlet on: $user"
    }
}

#Iterate through each user in group one and add them to all users. 
forEach ($user in $secondGroupSAN ){
    if($allUsers -notcontains $user){
        $allUsers += $user
    }
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $thirdGroupDN.Count

#Iterates through each user and compares to members of each group. 
forEach ($user in $allUsers){

    #Updates progress through each itteration for sorting ADUser objects into groups. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($percentComplete)
    Write-Progress -Activity "[3/4] Sorting $user into Group Membership " -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"

    #Boolean truth tree to determine group membership. 
    if($firstGroupSAN -contains $user){
        if($secondGroupSAN -contains $user){
            #Group 1 = True, Group 2 = True
            $usersinAllGroups += $user
        }else {
            #Group 1 = True, Group 2 = False
            $uniqueGroupOne += $user
        }
    }else{
        #Group 1 = False, Group 2 = True
        $uniqueGroupTwo += $user
    }
}

#Find the largest array of the groups
$longestColumn = ($uniqueGroupOne.Count,$uniqueGroupTwo.Count, $usersinAllGroups.Count | Measure-Object -Maximum).Maximum


#Create and populate Excel Workbook. 
$excelDocument = New-Object -ComObject Excel.Application
$excelWorkbook = $excelDocument.Workbooks.Add()
$currentExcelWorkSheet = $excelWorkbook.WorkSheets.Add()
$currentExcelWorkSheet.Name = "Three Group Comparison"

$currentExcelWorkSheet.Cells.Item(1,1) = "Unique to $groupOne"
$currentExcelWorkSheet.Cells.Item(1,1).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,2) = "Unique to $groupTwo"
$currentExcelWorkSheet.Cells.Item(1,2).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,3) = "$groupOne and $groupTwo"
$currentExcelWorkSheet.Cells.Item(1,3).Font.Bold = $true

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $longestColumn

#Iterate through each of the groups and populate excel workbook. 
For($row = 0; $row -lt $longestColumn; $row ++){

    #Updates progress through each row of excel sheet being populated. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($percentComplete)
    Write-Progress -Activity "[5/5] Generating Excel Sheet based on comapriosn data." -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing Row: $row of $longestColumn"

    $lastRow = $currentExcelWorkSheet.UsedRange.Rows.Count +1
    If($row -lt $uniqueGroupOne.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 1) = $uniqueGroupOne[$row]
    }
    If($row -lt $uniqueGroupTwo.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 2) = $uniqueGroupTwo[$row]
    }
    If($row -lt $usersinAllGroups.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 3) = $usersinAllGroups[$row]
    }
}

$formatWorksheet = $currentExcelWorkSheet.UsedRange
$formatWorksheet.EntireColumn.Autofit() | Out-Null

$fileExtension = ".xlsx"
$currentUser = $env:Username
$filePath = "C:\Users\$currentUser\Desktop\GroupComparisons$fileExtension"
$excelWorkbook.SaveAs($filePath)
$excelWorkbook.Close
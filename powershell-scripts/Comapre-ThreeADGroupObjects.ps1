#Script Parameters
param (
    #Varibles that store each of the the three group names. 
    [string]$groupOneName = '',
    [string]$groupTwoName = '',
    [string]$groupThreeName = '',

    #Varibles that store the AD Group Object of each gorup. 
    $firstGroupDN = @(),
    $secondGroupDN = @(),
    $thirdGroupDN = @(),
    
    #Varibles that store the SamAccountName of each user nested in each group. 
    $firstGroupSAN = @(),
    $secondGroupSAN = @(),
    $thirdGroupSAN = @(),

    #Varible that holds all ADUser objects in each of the groups. 
    $allUsers = @(),

    #Varibles that store ADUser objects depending on membership.
    $uniqueGroupOne = @(),
    $uniqueGroupTwo = @(),
    $uniqueGroupThree = @(),
    $groupOneAndTwo = @(),
    $groupOneAndThree = @(),
    $groupTwoandThree = @(),
    $usersinAllGroups = @()
)

#Converts the first string variable to ADGroup object. 
try {
    $firstGroupDN = Get-ADGroup -Identity $groupOneName -Properties Member | Select -ExpandProperty Member
}catch{
    throw "Unable to invoke Get-ADGroup cmdlet on: $groupOneName"
    break
}

#Converts the second string variable to ADGroup object. 
try {
    $secondGroupDN = Get-ADGroup -Identity $groupTwoName -Properties Member | Select -ExpandProperty Member
}catch{
    throw "Unable to invoke Get-ADGroup cmdlet on: $groupTwoName"
    break
}

#Converts the third string variable to ADGroup object. 
try {
    $thirdGroupDN = Get-ADGroup -Identity $groupThreeName -Properties Member | Select -ExpandProperty Member
}catch{
    throw "Unable to invoke Get-ADGroup cmdlet on: $groupThreeName"
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
    Write-Progress -Activity "[1/5] Converting $groupOneName DistinguisedNames to SamAccountNames" -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"
    
    #Converts group members to ADUser Objects. 
    try{
        $tempUser = Get-ADUser -Identity $user
        $firstGroupSAN  += $tempUser.SamAccountName
    }catch{
        throw "Unable to invoke Get-ADUser cmdlet on: $user"
    }
}

#Iterate through each user in group one and add them to all users. 
forEach ($user in $firstGroupSAN ){
    if($allUsers -notcontains $user){
        $allUsers += $user
    }
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $secondGroupDN.Count

forEach ($user in $secondGroupDN){
    
    #Updates progress through each itteration for converting group two from DistinguesdNames to SamAccount Names. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($PercentComplete)
    Write-Progress -Activity "[2/5] Converting $groupTwoName DistinguisedNames to SamAccountNames" -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"
    
    #Converts group members to ADUser Objects. 
    try{
        $tempUser = Get-ADUser -Identity $user 
        $secondGroupSAN += $tempUser.SamAccountName
    }catch{
        throw "Unable to invoke Get-ADUser cmdlet on: $user"
    }
}

#Iterate through each user in group two and add them to all users. 
forEach ($user in $secondGroupSAN){
    if($allUsers -notcontains $user){
        $allUsers += $user
    }
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $thirdGroupDN.Count

forEach ($user in $thirdGroupDN){
    
    #Updates progress through each itteration for converting group three from DistinguesdNames to SamAccount Names. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($percentComplete)
    Write-Progress -Activity "[3/5] Converting $groupThreeName DistinguisedNames to SamAccountNames" -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"
    
    #Converts group members to ADUser Objects. 
    try{
        $tempUser = Get-ADUser -Identity $user
        $thirdGroupSAN += $tempUser.SamAccountName
    }catch{
        throw "Unable to invoke Get-ADUser cmdlet on: $user"
    }
}

#Iterate through each user in group three and add them to all users. 
forEach ($user in $thirdGroupSAN){
    if($allUsers -notcontains $user){
        $allUsers += $user
    }
}

#Initalize varibles for progress bar. 
$progressCounter = 0
$totalUsers = $allUsers.Count

#Iterates through each user and compares to members of each group. 
forEach ($user in $allUsers){

    #Updates progress through each itteration for sorting ADUser objects into groups. 
    $progressCounter ++
    $percentComplete = $progressCounter / $totalUsers * 100
    $percentComplete = [math]::Round($percentComplete)
    Write-Progress -Activity "[4/5] Sorting $user into Group Membership " -Status "Percent Complete: $percentComplete%" -PercentComplete $percentComplete -CurrentOperation " Processing User: $($user)"

    #Boolean truth tree to determine group membership. 
    if ($firstGroupSAN -contains $user){
        if($secondGroupSAN -contains $user){
            if($thirdGroupSAN -contains $user){
                #Group 1 = True,  Group 2 = True, Group 3 = True
                $usersinAllGroups += $user
            }else{
                #Group 1 = True,  Group 2 = True, Group 3 = False
                $groupOneAndTwo += $user
            }
        }else{
            If($thirdGroupSAN -contains $user){
                #Group 1 = True, Group 2 = False, Group 3 = True
                $groupOneAndThree += $user
            }else{
                #Group 1 = True, Group 2 = False, Group 3 = False
                $uniqueGroupOne += $user
            }
        }
    }else{
        if($secondGroupSAN -contains $user){  
            if($thirdGroupSAN -contains $user){
                #Group 1 = False, Group 2 = True, Group 3 = True
                $groupTwoandThree += $user
            }else{
                #Group 1 = False, Group 2 = True, Group 3 = False
                $uniqueGroupTwo += $user
            }

        }else{
            #Group 1 = False, Group 2 = False, Group 3 = True
            $uniqueGroupThree += $user
        }
    }
}

#Find the largest array of the groups
$longestColumn = ($uniqueGroupOne.Count,$uniqueGroupTwo.Count,$uniqueGroupThree.Count, $groupOneAndTwo.Count, $groupOneAndThree.Count, $groupTwoandThree.Count, $usersinAllGroups.Count | Measure-Object -Maximum).Maximum

#Create and populate Excel Workbook. 
$excelDocument = New-Object -ComObject Excel.Application
$excelWorkbook = $excelDocument.Workbooks.Add()
$currentExcelWorkSheet = $excelWorkbook.WorkSheets.Add()
$currentExcelWorkSheet.Name = "Three Group Comparison"

$currentExcelWorkSheet.Cells.Item(1,1) = "Unique to $groupOne"
$currentExcelWorkSheet.Cells.Item(1,1).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,2) = "Unique to $groupTwo"
$currentExcelWorkSheet.Cells.Item(1,2).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,3) = "Unique to $groupThree"
$currentExcelWorkSheet.Cells.Item(1,3).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,4) = "$groupOne and $groupTwo"
$currentExcelWorkSheet.Cells.Item(1,4).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,5) = "$groupOne and $groupThree"
$currentExcelWorkSheet.Cells.Item(1,5).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,6) = "$groupTwo and $groupThree"
$currentExcelWorkSheet.Cells.Item(1,6).Font.Bold = $true

$currentExcelWorkSheet.Cells.Item(1,7) = "$groupOne, $groupTwo, and $groupThree"
$currentExcelWorkSheet.Cells.Item(1,7).Font.Bold = $true

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
    If($row -lt $uniqueGroupThree.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 3) = $uniqueGroupThree[$row]
    }
    If($row -lt $groupOneAndTwo.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 4) = $groupOneAndTwo[$row]
    }
    If($row -lt $groupOneAndThree.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 5) = $groupOneAndThree[$row]
    }
    If($row -lt $groupTwoandThree.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 6) = $groupTwoandThree[$row]
    }
    If($row -lt $usersinAllGroups.count ){
        $currentExcelWorkSheet.Cells.Item($lastRow, 7) = $usersinAllGroups[$row]
    }
}

$formatWorksheet = $currentExcelWorkSheet.UsedRange
$formatWorksheet.EntireColumn.Autofit() | Out-Null

$fileExtension = ".xlsx"
$currentUser = $env:Username
$filePath = "C:\Users\$currentUser\Desktop\GroupComparisons$fileExtension"
$excelWorkbook.SaveAs($filePath)
$excelWorkbook.Close

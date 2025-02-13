Param (
    [string[]]$Subs
)

$results = @()

foreach($sub in $subs) {
    
    az account set --subscription $sub

    $cosmosAccounts = az cosmosdb list
    
    $cosmosAccounts = $cosmosAccounts | ConvertFrom-Json

    if($cosmosAccounts -ne 0){        
        foreach($dbAccount in $cosmosAccounts) {
            $result = [PSCustomObject]@{
                Subscription = $sub
                AccountName = $dbAccount.name
                BackUpPolicy = $dbAccount.backupPolicy.type
            }
    
            $results += $result
        }    
    } else {
        write-host "No cosmosDb accounts found on subscription $sub"
    }
    
}

if($results) {
    try{
        $results | Export-Csv -Path ".\output4.csv" -NoTypeInformation
        write-host "Results exported"
    } catch {
        write-host "Error exporting data"
    }
}





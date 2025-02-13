[CmdletBinding()]
Param (
    [string[]]$SubscriptionId #You can parse multiple subscription IDs and/or Subscription Names
)

$results = @()

foreach($sub in $SubscriptionId) {
    
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
        $results | Export-Csv -Path ".\CosmosDbsPolicyPerSubscription.csv" -NoTypeInformation
        write-host "Results exported"
    } catch {
        write-host "Error exporting data"
    }
} elese {
    "No results found!"
}




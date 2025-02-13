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
            $retentionPolicyContinous = $null
            $retentionPolicyPeriodic = $null
            if($dbAccount.backupPolicy.type -eq "Continuous") {
                $retentionPolicyContinous = $dbAccount.backupPolicy.continuousModeProperties.tier
                if($retentionPolicyContinous -eq "Continuous7Days") {
                    $retentionPolicyContinous = "7 Days"
                } else {
                    $retentionPolicyContinous = "30 Days"
                }
            } else {
                $retentionPolicyPeriodic = "$($dbAccount.backupPolicy.periodicModeProperties.backupRetentionIntervalInHours)" + "h"    
            }
            $result = [PSCustomObject]@{
                Subscription = $sub
                AccountName = $dbAccount.name
                BackUpPolicy = $dbAccount.backupPolicy.type
                RetentionContinous = $retentionPolicyContinous
                IntervalPeriodic = $retentionPolicyPeriodic
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
        write-host $_
    }
} else {
    "No results found!"
}
Param (
    [string[]]$SubscriptionId #You can parse multiple subscription IDs and/or Subscription Names
)

$results = @()


foreach($sub in $SubscriptionId) {
  
    az account set --subscription $sub

    $rgs = az group list
    $rgs = $rgs | ConvertFrom-Json

    foreach($rg in $rgs){
        $sqlServers = az sql server list --resource-group $rg.name
        $sqlServers = $sqlServers | ConvertFrom-Json

        foreach($sqlServer in $sqlServers) {
            $sqlDbs = az sql db list --server $sqlServer.name --resource-group $rg.name
            $sqlDbs = $sqlDbs | ConvertFrom-Json
            Write-host "Getting databases from $($sqlServer.name) SQL Servers"
            foreach($sqlDb in $sqlDbs) {
                write-host $sqlDb.name
                if($sqlDb.name -ne "master") {
                    $shortBackUpPolicy = az sql db str-policy show --server $sqlServer.name --resource-group $rg.name --name $sqlDb.name                
                    $shortBackUpPolicy = $shortBackUpPolicy | ConvertFrom-Json
                                    
                    $longBackupPolicy = az sql db ltr-policy show --server $sqlServer.name --resource-group $rg.name --name $sqlDb.name
                    $longBackupPolicy = $longBackupPolicy | ConvertFrom-Json                    
                
                    $result = [PSCustomObject]@{
                        Subscription = $sub
                        Server = $sqlServer.name
                        Database = $sqlDb.name
                        StrIntervalhours = $shortBackUpPolicy.diffBackupIntervalInHours
                        StrRetantiondays = $shortBackUpPolicy.retentionDays
                        LtrMonthly = $longBackupPolicy.monthlyRetention
                        LtrWeekly = $longBackupPolicy.weeklyRetention
                        LtrYearly = $longBackupPolicy.yearlyRetention
                        LtrWeekOfTheYear = $longBackupPolicy.weekOfYear                        
                    }

                    $results += $result
                }
            }
        }
    }   
}

if($results) {
    try{
        $results | Export-Csv -Path ".\SqlDbsPolicyPerSubscription.csv" -NoTypeInformation
        write-host "Results exported"
    } catch {
        write-host $_
    }
} else {
    "No results found!"
}
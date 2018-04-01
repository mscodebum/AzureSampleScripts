<#
Sample Script to move an Azure Logical Server to another subscription
The main benefit of this is that it will do validation, and is designed to be simple to use.

Source information about is process is here -> https://docs.microsoft.com/en-gb/azure/azure-resource-manager/resource-group-move-resources

Information Required
- Step 1
-- Source Subscription
-- Destination Subscription

- Step 2
-- DestinationResourceGroupName
-- LogicalSQLServerResoruceIdToMove
#>

$Message = @"
Purpose:
- Move an Azure Locical SQL Server that contains an Azure SQL Data Warehouse to a new subscription. This
process can be used to help move other resoruces as well. While a Azure Logical SQL Server can be moved
between subscriptions, a data warehouse cannot.

Precausions
- If you simply need to create a copy of an Azure SQL Data Warehouse to another server, there is an option
to restore the Azure SQL Data Warehouse using the New Azure SQL Data Warehouse blade in the Azure Portal.
https://docs.microsoft.com/en-us/azure/sql-data-warehouse/sql-data-warehouse-restore-database-portal

- If you need to rename your Azure SQL Data Warehouse, the documentation for ALTER DATABASE is here
https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-azure-sql-data-warehouse
Ensure that you are connected to master and not other activities are running when submitting ALTER DATABASE

- If you have orphaned logins after any of these steps, reference the following link
https://blogs.msdn.microsoft.com/joonkyulee/2017/10/08/mapping-a-login-to-a-user-in-azure-sql-data-warehouse/

"@

Clear-Host
Write-Host $Message -ForegroundColor Magenta

Write-Host "Step 1 - Validation" -ForegroundColor DarkYellow
$SourceSubscriptionId = Read-Host -Prompt "Provide the source subscription Id"
$DestinationSubscriptionId = Read-Host -Prompt "Provide the destination subscription Id"
try {
    if ((Get-AzureRmSubscription -SubscriptionName $SourceSubscriptionId).TenantId -ne (Get-AzureRmSubscription -SubscriptionName $DestinationSubscriptionId>).TenantId) {
        Write-Host "Verification failed" -ForegroundColor Red
    } else {
        Write-Host "Verification Passed" -ForegroundColor Green
    }
} catch {
    Write-Host "Unable to collect details with the information provided." -ForegroundColor Red`n
} finally {
    Remove-Variable -Name SourceSubscriptionId, DestinationSubscriptionId
}

Write-host "`nStep 2 - Information Gathering" -ForegroundColor DarkYellow
$DestinationResourceGroupName = Read-Host -Prompt "Provide the destination resource group"
$LogicalSQLServerResourceIdToMove = Read-Host -Prompt "Azure Logical SQL Server to be Moved"
try {
    Get-AzureRmResourceGroup -Name $DestinationResourceGroupName -ErrorAction Stop | Out-Null
    Get-AzureRmResource -ResourceId $LogicalSQLServerResourceIdToMove -ErrorAction Stop | Out-Null
    Write-Host "Details Verified" -ForegroundColor Green`n
} catch {
    Write-Host "Unable to collect details with the information provided." -ForegroundColor Red`n
    break
}

Write-Host "Step 3 - Resource Move" -ForegroundColor DarkYellow
try {
    Move-AzureRmResource -DestinationResourceGroupName $DestinationResourceGroupName -ResourceId $LogicalSQLServerResourceIdToMove -ErrorAction Stop
    Write-Host "Resource Moved!" -ForegroundColor Green
    Write-Host "Success!" -ForegroundColor Green`n
} catch {
    Write-Host "Unable to move the resource requested." -ForegroundColor Red`n
} finally {
    Remove-Variable -Name DestinationResourceGroupName, LogicalSQLServerResourceIdToMove
}
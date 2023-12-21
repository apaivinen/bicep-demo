$rg = "RG-Sentinel-Playbooks"
$subscription = "d781400b-6ce7-4b68-aaf2-6b71a353b7fc"

for ($i = 1; $i -le 100; $i++ ) {
    Write-Progress -Activity "Deployment in Progress" -Status "$i% Complete:" -PercentComplete $i
   
    New-AzResourceGroupDeployment -Name DemoDeployment -ResourceGroupName $rg -TemplateFile connector-o365.bicep -WarningAction:silentlycontinue

    Start-Sleep -seconds 10
}
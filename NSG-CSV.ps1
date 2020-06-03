#Connect-AzAccount
$subs = Get-AzSubscription 
$output1 = @();
$exportPath = 'your path'
$portNum = Read-Host -Prompt "Enter the Port Number"
try
{
    foreach ($sub in $subs)
    {
    #$null = $PSItem | Select-AzSubscription
    Set-AzContext -Subscription $sub | Out-Null
    $nsgs = Get-AzNetworkSecurityGroup 
    if($portNum)
    {
            foreach ($obj in $nsgs)
            {
               #$customPsObject = New-Object -TypeName PsObject
                $output1 += $obj.SecurityRules | Where-Object { $_.DestinationPortRange -eq $portNum} | Select-Object -OutVariable +output1 @{ n = 'NSG Name'; e = {$obj.Name}},
                    @{ n = 'Rule Name' ; e = {$_.Name} },
                    @{ n = 'ResourceGroupName'; e = {$obj.ResourceGroupName}},
                    @{ n = 'SourcePortRange';e = {$_.SourcePortRange}},
                    @{ n = 'DestinationPortRange';e ={$_.DestinationPortRange}},
                    @{ n = 'Access' ; expression = {$_.Access} },
                    @{ n = 'Priority' ; expression = {$_.Priority} },
                    @{ n = 'Direction'; e ={$_.Direction}} 
            } 
            $output1 | Export-Csv "$exportPath" -NoTypeInformation -Encoding ASCII

    }
    else{
            foreach ($obj in $nsgs)
            {
                Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $obj | Select-Object -OutVariable +output1 @{ n = 'NSG Name'; e = {$obj.Name}},
                    @{ n = 'Rule Name' ; e = {$_.Name} },
                    @{ n = 'ResourceGroupName'; e = {$obj.ResourceGroupName}},
                    @{ n = 'SourcePortRange';e = {$_.SourcePortRange}},
                    @{ n = 'DestinationPortRange';e ={$_.DestinationPortRange}},
                    @{ n = 'Access' ; expression = {$_.Access} },
                    @{ n = 'Priority' ; expression = {$_.Priority} },
                    @{ n = 'Direction'; e ={$_.Direction}} 
            }#$output1 | Export-Csv "$exportPath" -NoTypeInformation -Encoding ASCII
            $output1 | Export-Csv "$exportPath" -NoTypeInformation -Encoding ASCII
    };


    }
}
catch 
{
    Write-Host -ErrorAction Stop
}

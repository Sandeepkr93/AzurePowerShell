param
(
  [Parameter(Mandatory=$True)]  
  [string]
  $subscriptionId,
  
  [Parameter(Mandatory=$True)]
  [string]
  $resourceGroupName,
  
  [Parameter(Mandatory=$False)]
  [string]
  $vnets,

  [Parameter(Mandatory=$False)]
  [string]
  $subnets,

  [Parameter(Mandatory=$True)]
  [string]
  $portRanges,
  
  $exportPath = 'C:\Users\M1056612\Desktop\Azure Network Overivew ARM\NSG.csv'
)
$NsgRuleSet = @()
# sign in
Write-Host "Logging in...";
#Connect-AzAccount;

# Check subscription
Get-AzSubscription -SubscriptionId $subscriptionId -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    Write-Host -Verbose "Subscription with subcription ID " $subscriptionId " doesn't exists"
}
else
{
    Write-Host -Verbose "Subcription exists!";
    Set-AzContext -SubscriptionId $subscriptionId | Out-Null;
    #Check Resource Group Name
    Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue;
    if ($notPresent)
    {
        Write-Host -Verbose "Resource Group " $resourceGroupName " doesn't exists";
    }
    else
    {
        Write-Host -Verbose "Resource Group exists!";
        try
        {
          $vnets= Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName ;
          foreach ($vnet in $vnets)
          {
            Write-Host $vnet.Name;
            $output = Get-AzVirtualNetwork -ResourceName $vnet.Name -ResourceGroupName $resourceGroupName -ExpandResource "Subnets/NetworkSecurityGroup";
            $subnets = $output.Subnets;
            foreach($subnet in $subnets) 
            {
                $subnetrules = $subnet.NetworkSecurityGroup.SecurityRules;
                foreach($subnetrule in $subnetrules)
                {
                    if($portRanges)
                    {
                      foreach($port in $portRanges)
                      {
                        if($subnetrule.Direction -eq "Outbound")
                        {
                            $NsgRuleSet +=
                          (
                              [pscustomobject]@{ 
                                  Vnet_Name = $vnet.Name;
                                  Subnet_Name = $subnet.Name;
                                  Resource_Group_Name = $vnet.ResourceGroupName;
                                  Rule_Name=$subnetrule.Name;
                                  Source_Port_Range=$subnetrule.SourcePortRange[0];
                                  Destination_Port_Range=$subnetrule.DestinationPortRange[0];
                                  Protocol=$subnetrule.Protocol;
                                  Access=$subnetrule.Access;
                                  Priority=$subnetrule.Priority;
                                  Direction=$subnetrule.Direction;
                              }
                          )
                        }
                      }$NsgRuleSet | Export-Csv "$exportPath" -NoTypeInformation -Encoding ASCII;
                        
                    }
                    else 
                    {
                        continue;
                    }
                }
                
                
            }
          }
        }
        catch 
        {
            Write-Host -Verbose "An Error Occured!"
        }
        
    }
   
}



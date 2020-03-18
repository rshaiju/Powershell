function Create-AutomationAccount()
{
    param(
        [string]$rg,
        [string]$loc='centralus',
        [string]$accName,
        [System.Collections.IDictionary]$tags=@{}
    )

    New-AzResourceGroup -Name $rg -Location $loc -Force

    New-AzAutomationAccount -Name $accName -ResourceGroupName $rg -Location $loc -Plan Free -Tags $tags
    
}

function Create-RunBook()
{
    param([string]$name,[string]$filePath,[string] $type, [string]$automationAC, [string]$rg)

    Import-AzAutomationRunbook -Name $name -Path $filePath -Type $type -AutomationAccountName $automationAC -ResourceGroupName $rg -Force
}

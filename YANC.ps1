$packages=get-package | Group-Object Id

$result=@()
foreach($package in $packages)
{
     $packageName=$package.Name
     Write-Output "Processing package - $packageName.."
     $versions=$package.Group|select -ExpandProperty Versions -Unique|sort -desc
     $maxVersion=$versions|select -First 1
     $versionstring=$versions -join ','
     
     Write-Output "Finding the latest stable version of $packageName.."

     $candidateVersion=Find-Package -Id $package.Name -ExactMatch
     if($candidateVersion -ne $null)
     {
        $candidateVersion=$candidateVersion.Version.ToString()
     }
     $details=[pscustomobject]@{Name=$package.Name; Versions=$versionstring;MaxInstalledVersion=$maxVersion;MaxStableVersion=$candidateVersion}
     
     Write-Output "Details -$details"
     
     $result+=$details

}

$result |Export-Csv "C:\Temp\depsnew.csv"


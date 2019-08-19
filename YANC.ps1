$packages=get-package | Group-Object Id

$count=0

$result=@()
foreach($package in $packages)
{

     "`n"

     $packageName=$package.Name
     Write-Output "Processing package - $packageName.."
     $versions=$package.Group|select -ExpandProperty Versions -Unique|sort -desc
     $maxVersion=$versions|select -First 1
     $versionstring=$versions -join ','
     $applicableProjects=$package.Group.ProjectName -join ','
     
     Write-Output "Finding the latest stable version of $packageName.."

     $candidateVersion=Find-Package -Id $package.Name -ExactMatch
     if($candidateVersion -ne $null)
     {
        $candidateVersion=$candidateVersion.Version.ToString()
     }


     #If consolidated version is already applied to all the projects, skip the package
     if(($versions.Count -eq 1) -and ($versions[0] -eq  $maxVersion))
     {
        "$packageName is already up-to-date in all the projects.."
        continue
     }

     $details=[pscustomobject]@{Name=$package.Name; Versions=$versionstring;MaxInstalledVersion=$maxVersion;MaxStableVersion=$candidateVersion;ApplicableProjects=$applicableProjects;}
     
     Write-Output "Details -$details"
     
     $result+=$details

}

#select -Property  Name,Versions,MaxInstalledVersion,MaxStableVersion
$result |Export-Csv "C:\Temp\depsnew.csv"

$consolidatedPrjNames=$result|select -ExpandProperty ApplicableProjects -Unique

foreach($prjName in $consolidatedPrjNames)
{
        "Checking the applicable updates of $prjName"
        "-----------------------------------------"
        $consolidatedPackages=$result|? {$_.ApplicableProjects.Contains($prjName)}
        foreach($pkg in $consolidatedPackages)
        {
            "Consolidating Package$($pkg.Name) in $prjName"
            #Update
        }
}


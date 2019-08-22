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
     
     Write-Output "Finding the latest stable version of $packageName.."

     $latestPackage=Find-Package -Id $package.Name -ExactMatch

     $candidateVersion=if($latestPackage -ne $null){$latestPackage.Version}else{$maxVersion}

     #If consolidated version is already applied to all the projects, skip the package
     if(($versions.Count -eq 1) -and ($versions[0].Version -eq  $candidateVersion.Version))
     {
        "$packageName is already up-to-date in all the projects.."
        continue
     }
     
     $details=[pscustomobject]@{
        Name=$package.Name; 
        Versions=$($versions -join ',');
        MaxInstalledVersion=$maxVersion;
        CandidateVersion=$candidateVersion;
        applicableProjects=$($package.Group.ProjectName -join ',');
        }
     
     Write-Output "Details -$details"
     
     $result+=$details
    
     #$count++
     #
     #if($count -eq 1)
     #{
     #   break
     #}
}


$result|Export-Csv "C:\Temp\depsnew.csv"

$consolidatedPrjNames=$result|select -ExpandProperty applicableProjects -Unique

foreach($prjName in $consolidatedPrjNames.Split(','))
{
        

        #"Checking the applicable updates of $prjName"
        #"-----------------------------------------"
        #$consolidatedPackages=$result|? {$_.applicableProjects.Split(',').Contains($prjName)}
        #foreach($pkg in $consolidatedPackages)
        #{
        #    "Consolidating Package $($pkg.Name) in $prjName"
        #    
        #    #$installedPackage=get-package $pkg.Name -ProjectName $prjName
        #    #
        #    #"Currently installed : $($installedPackage.Version.Version.ToString())"
        #    #"Candidate : $( $pkg.CandidateVersion)"
        #    
        #    Update-Package $pkg.Name -ProjectName $prjName 
        #}


        Try
        {
            Update-Package -ProjectName $prjName 
            "Updated all packages in $prjName" | Out-File "C:\Temp\updatelog.txt"
        }
        Catch
        {
            $ErrorMessage = $_.Exception.Message
            "Error updating packages in $prjName : $ErrorMessage" | Out-File "C:\Temp\updatelog.txt"
        }
}


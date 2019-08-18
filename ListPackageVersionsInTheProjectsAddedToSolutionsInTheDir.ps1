
function Get-ReferredPackages
{
    param([string]$slnPath,[System.IO.Fileinfo[]]$slns)

    $prjs=New-Object System.Collections.Generic.List[System.IO.FileInfo]
    $packages=New-Object "System.Collections.Generic.Dictionary``2[String,System.Collections.Generic.List[string]]"


    foreach($sln in $slns){
        $prjLInes=Get-Content $sln.FullName|? {$_.StartsWith('Project(') -and  $_.Contains('.csproj')}
        foreach($line in $prjLInes)
        {
            $hasMatch= $line -match '.*"(.*\\)(.*.csproj)'
            if($hasMatch)
            {
                $prjDir=$Matches[1]
                $prjName=$Matches[2]
                if(Test-Path "$($slnPath)$($prjDir)")
                {
                    $prj=dir "$($slnPath)$($prjDir)" $prjName
                    $prjs.Add($prj)
                }
            }
        }
    }

    $prjs=$prjs|Select-Object -Unique


    foreach($prj in $prjs){
        $pkgFile=dir $prj.DirectoryName "packages.config"
        if($pkgFile -ne $null){
            [xml]$cfg= get-content $pkgFile.FullName
            foreach($pkgRef in $cfg.packages.package){
                $pkgVersions= $packages[$pkgRef.id]
                if($pkgVersions -eq $null){
                    $versionList=New-Object System.Collections.Generic.List[string]
                    $versionList.Add($pkgRef.version)
                    $packages.Add($pkgRef.id,$versionList)
                }else{
                    $pkgVersions.Add($pkgRef.version)
                    $packages[$pkgRef.id]=$pkgVersions|Select-Object -Unique
                }
            }
        }
    }

    $packages

}

$slnPath="D:\Dev\HRCB\"


$slns=dir $slnPath *.sln
#
Get-ReferredPackages $slnPath $slns



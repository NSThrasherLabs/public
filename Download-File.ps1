##############################################
#Script Title: Download File PowerShell Tool
#Script File Name: Download-File.ps1 
#Author: Ron Ratzlaff  
#Date Created: 4/21/2016 
##############################################

#Requires -Version 3.0

Function Download-File
{
    <#  
      .SYNOPSIS  
        
          The "Download-File" function allows a file to be downloaded from a specified online source location to a specified local file path location.  

      .DESCRIPTION

          The "Download-File" function contains a total of four parameters, two of which are switching parameters that do not accept any values, but are simply used to tell the function to perform a specific action after the file has been downloaded from a specified online location. This script requires PowerShell version 3 and this function uses the System.Net.WebClient class, because it seems to provide more expedient download times that other methods.

      .PARAMETER WebSourceLocation

          Enter the full URL path to the file that you wish to download.

      .PARAMETER DownloadFilePath
      
        Enter the full local path to the target location you wish to download the file to and include a filename at the end. 

      .PARAMETER DisplayProperties
      
        A switching parameter that displays the following properties of the downloaded file: DownloadDate, DownloadLocation, DownloadTime, FileName, FileSize(KB), FileSize(MB)
        
      .PARAMETER OpenLocation
      
        A switching parameter that does not accept any value, but rather is used to tell the function to open the path location where the file was downloaded to. 
          
      .EXAMPLE
          
          Download a file and keep the same file name as the original
          
          Download-File -WebSourceFile 'https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' -DownloadFilePath "$env:USERPROFILE\Desktop\Windows6.1-KB2819745-x64-MultiPkg.msu"

      .EXAMPLE
          
          Download a file and change the file name from the original
          
          Download-File -WebSourceFile 'https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' -DownloadFilePath "$env:USERPROFILE\Desktop\PowerShellv4x64.msu"

      .EXAMPLE
          
          Download a file and display the file download properties
          
          Download-File -WebSourceFile 'https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' -DownloadFilePath "$env:USERPROFILE\Desktop\PowerShellv4x64.msu" -DisplayProperties
          
      .EXAMPLE
          
          Download a file and open the location it was downloaded to
          
          Download-File -WebSourceFile 'https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' -DownloadFilePath "$env:USERPROFILE\Desktop\PowerShellv4x64.msu" -OpenLocation

      .EXAMPLE
          
          Download a file and open the location and display the file download properties
          
          Download-File -WebSourceFile 'https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' -DownloadFilePath "$env:USERPROFILE\Desktop\PowerShellv4x64.msu" -DisplayProperties -OpenLocation
    #>

          
    [cmdletbinding()]
    
    Param 
    (
        [Parameter(Mandatory = $true, 
            HelpMessage='Enter the web source location of the content you wish to download')]
            [ValidateNotNullOrEmpty()]
            [Alias('WSF')]   
            [string]$WebSourceFile, 
            
        [Parameter(Mandatory = $true, 
            HelpMessage='Enter the local file path location you wish to download the content to')]
            [ValidateNotNullOrEmpty()]
            [Alias('DFP')]   
            [IO.FileInfo]$DownloadFilePath,

        [Parameter(HelpMessage='Use this parameter to display the file download properties')]
            [ValidateNotNullOrEmpty()]
            [Alias('DP')]   
            [switch]$DisplayProperties,

        [Parameter(HelpMessage='Use this parameter to open the download location the file was downloaed to')]
            [ValidateNotNullOrEmpty()]
            [Alias('OL')]   
            [switch]$OpenLocation
    )
    
    Begin 
    {
        $NewLine = "`r`n"
        
        $StartDownload = Get-Date

        $DownloadLocation = $DownloadFilePath | Split-Path

        Try
        {
            $WebClient = New-Object System.Net.WebClient
        }

        Catch
        {
            $NewLine 
            
            Write-Warning -Message "The following error occurred: $_"

            $NewLine

            Write-Output -Verbose 'This script will now exit'

            $NewLine
            
            Break
        }

        If (Test-Path -Path $DownloadLocation)
        {
            $NewLine

            Write-Output -Verbose "The following path was found: $DownloadLocation"

            $NewLine
        }

        Else
        {
            $NewLine
            
            Write-Warning -Message "The following path could not be found: $DownloadLocation)"

            $NewLine

            Write-Output -Verbose 'This script will now exit'

            $NewLine 

            Break
        }
    }

    Process
    {   
        Try
        {
            Write-Output -Verbose 'Attempting to download file, please wait...'

            $NewLine
            
            $WebClient.DownloadFile($WebSourceFile, $DownloadFilePath)
        }

        Catch
        {
            $NewLine 
            
            Write-Warning -Message "The following error occurred: $_"

            $NewLine
            
            Break
        }

        $FileName = Get-Item -Path $DownloadFilePath
            
        $DownloadTime = Write-Output -Verbose "$((Get-Date).Subtract($StartDownload).Seconds) seconds"

        $DownloadedFilePath = Get-Item -Path "$DownloadFilePath"

        $KBSize = $DownloadedFilePath.length/1KB

        $MBSize = $DownloadedFilePath.length/1MB

        If ($PSBoundParameters.ContainsKey('DisplayProperties'))
        {
                [pscustomobject] @{
                'DownloadTime' = $DownloadTime;
                'DownloadDate' = Get-Date;
                'DownloadLocation' = $DownloadLocation;
                'FileName' = $FileName.Name;
                'FileSize(KB)' = $KBSize.ToString('#.#');
                'FileSize(MB)' = $MBSize.ToString('#.#');
            }
        }

        If ($PSBoundParameters.ContainsKey('OpenLocation'))
        {
            Invoke-Item -Path $DownloadLocation
        }
    }

    End {}
}
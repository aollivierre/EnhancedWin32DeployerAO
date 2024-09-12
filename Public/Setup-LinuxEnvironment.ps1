# function Setup-LinuxEnvironment {
#     # Get the base paths from the global variables
#     Setup-Win32GlobalPaths

#     # Import the module using the Linux path
#     Import-Module $LinuxModulePath -Verbose

#     # Convert paths from Windows to Linux format
#     # $global:AOscriptDirectory = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
#     # $global:directoryPath = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot\Win32Apps-DropBox"
#     # $global:Repo_Path = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
#     $global:IntuneWin32App = Convert-WindowsPathToLinuxPath -WindowsPath "C:\Code\IntuneWin32App\IntuneWin32App.psm1"

#     Import-Module $global:IntuneWin32App -Verbose -Global


#     $global:AOscriptDirectory = "$PSscriptroot"
#     $global:directoryPath = "$PSscriptroot/Win32Apps-DropBox"
#     $global:Repo_Path = "$PSscriptroot"
#     $global:Repo_winget = "$global:Repo_Path/Win32Apps-DropBox"
# }
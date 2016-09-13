param($installPath, $toolsPath, $package, $project)

# Define a log function
function WriteLog($info)
{
	Write-Output $info
	$script:log = $script:log + $info + "`n`n"
}
$script:log = "Starting install - $(Get-Date)`n--------------------------------------`n`n"


#### INITIALIZE
$projectFullName = $project.FullName
$fileInfo = new-object -typename System.IO.FileInfo -ArgumentList $projectFullName
$projectDirectory = $fileInfo.DirectoryName
$logFile = $projectDirectory + "\Backload\Logs\backload.install.log"

WriteLog ("Project root path: $($projectDirectory)")



#####  TASK 1: REMOVE SCHEMA FILE IF CONFIG FILE NOT EXITS -> NEW INSTALL  #####

WriteLog ("Task 1/1: REMOVE SCHEMA FILE IF CONFIG FILE NOT EXITS")


$configItem = $project.ProjectItems | where { $_.Name -eq "Web.Backload.config" }
if (!$configItem) {
	$schemaItem = $project.ProjectItems | where { $_.Name -eq "Web.Backload.xsd" }
	if ($schemaItem) {
		WriteLog (">>>>>>  Remove schema $($schemaItem.Name). Schema is now in \Backload\Config folder.")
		
		$schemaItem.Delete()
	} else {
		WriteLog (">>>>>>  Schema file not found. Removing not necessary.")
	}
} else {
	WriteLog (">>>>>>  Found config file from previous installation. Schema file not removed.")
}
WriteLog ("Task 1: FINISHED")

# Open upgrade info web site
$DTE.ItemOperations.Navigate("https://github.com/blackcity/Backload/wiki/Upgrade-and-migration")


WriteLog ("INSTALLATION DONE.")
$script:log | Out-File $logFile





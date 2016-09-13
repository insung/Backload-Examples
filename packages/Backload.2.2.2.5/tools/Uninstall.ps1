param($installPath, $toolsPath, $package, $project)

# Define a log function
function WriteLog($info)
{
	Write-Output $info
	$script:log = $script:log + $info + "`n`n"
}
$script:log = "Starting uninstall - $(Get-Date)`n--------------------------------------`n`n"


#### INITIALIZE
$projectFullName = $project.FullName
$fileInfo = new-object -typename System.IO.FileInfo -ArgumentList $projectFullName
$projectDirectory = $fileInfo.DirectoryName
$logFile = $projectDirectory + "\Backload\Logs\backload.bundles.uninstall.log"

WriteLog ("Project root path: $($projectDirectory)")




#####  TASK 1: REMOVE BACKLOAD BUNDLES FROM \APP_START\BUNDLECONFIG.CS FILE  #####

WriteLog ("Task 1/1: REMOVE BACKLOAD BUNDLES FROM \APP_START\BUNDLECONFIG.CS FILE")


$appStart = $project.ProjectItems | where { $_.Name -eq "App_Start" }
if ($appStart) {

	WriteLog (">>>>>>  Search for BundleConfig.cs file.")
		
	$bundles = $appStart.ProjectItems | where { $_.Name -eq "BundleConfig.cs" }
	if ($bundles) {
		WriteLog (">>>>>>  Found BundleConfig.cs file.")
		
		$bundles.Open()
		$bundles.Document.Activate()
		$bundles.Document.Selection.StartOfDocument()
		
		WriteLog (">>>>>>  Document BundleConfig.cs opened.")
		
		# Remove using statement
		if ($bundles.Document.Selection.FindText("using Backload.Bundles;")) {
		
			$bundles.Document.Selection.SelectLine()
			$bundles.Document.Selection.Delete()
			
			WriteLog (">>>>>>  Using statement deleted from BundleConfig.cs.")
		}
		
		# Remove comment if any
		if ($bundles.Document.Selection.FindText("// Add or remove this line for the bundeling feature")) {
		
			$bundles.Document.Selection.SelectLine()
			$bundles.Document.Selection.Delete()
			
			WriteLog (">>>>>>  Using statement removed from BundleConfig.cs.")
		}

		# Remove register method
		if ($bundles.Document.Selection.FindText("BackloadBundles.RegisterBundles(bundles);")) {
		
			$bundles.Document.Selection.SelectLine()
			$bundles.Document.Selection.Delete()
			
			WriteLog (">>>>>>  Call to BackloadBundles.RegisterBundles() removed from BundleConfig.cs.")
		}
		
		# Remove blank line if any
		$bundles.Document.Selection.SelectLine()
		if ([String]::IsNullOrWhiteSpace($bundles.Document.Selection.Text)) {
		
			$bundles.Document.Selection.Delete()
		}
		
		$bundles.Document.Close(0)
		
		WriteLog (">>>>>>  Document BundleConfig.cs closed.")

	} else {
		WriteLog (">>>>>>  BundleConfig.cs not found.")
	}
} else {
	WriteLog (">>>>>>  App_Start folder not found.")
}
WriteLog ("Task 1/1: FINISHED.")


WriteLog ("DEINSTALLATION DONE.")
$script:log | Out-File $logFile
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

$asax = $project.ProjectItems | where { $_.Name -eq "Global.asax" }
$appStart = $project.ProjectItems | where { $_.Name -eq "App_Start" }
$bundles = $appStart.ProjectItems | where { $_.Name -eq "BundleConfig.cs" }

$logFile = $projectDirectory + "\Backload\Logs\backload.bundles.install.log"
$feature_installed = $FALSE
$asaxReady = $FALSE

WriteLog ("Project root path: $($projectDirectory)")



#####  TASK 1: MAKE SURE BUNDLING IS ENABLED IN GLOBAL.ASAX #####
WriteLog ("TASK 1/2: MAKE SURE BUNDLING IS ENABLED IN GLOBAL.ASAX")


if ($asax) {

	$asaxCs = $asax.ProjectItems | where {$_.Name -eq "Global.asax.cs" }

	if ($asaxCs) {

		WriteLog (">>>>>>  Found Global.asax.cs file.")
	
		$asaxCs.Open()
		$asaxCs.Document.Activate()
		$asaxCs.Document.Selection.StartOfDocument()

		WriteLog (">>>>>>  Document Global.asax.cs opened.")

		
		WriteLog (">>>>>>  Search for using System.Web.Optimization; statement")
		
		if  (!($asaxCs.Document.Selection.FindText("using System.Web.Optimization)"))) {
			$asaxCs.Document.Selection.Text = "using System.Web.Optimization;"
			
			WriteLog (">>>>>>  Added using System.Web.Optimization statement")
		}
		
		
		WriteLog (">>>>>>  Search for BundleConfig.RegisterBundles() call.")

		if  (!($asaxCs.Document.Selection.FindText("BundleConfig.RegisterBundles(BundleTable.Bundles)"))) {
	
			if  ($asaxCs.Document.Selection.FindText("protected void Application_Start()")) {
				$asaxCs.Document.Selection.FindText("{")
				$asaxCs.Document.Selection.CharRight()
				#$asaxCs.Document.Selection.Collapse()
				$asaxCs.Document.Selection.NewLine()
				$asaxCs.Document.Selection.Text = "BundleConfig.RegisterBundles(BundleTable.Bundles);"
				$asaxCs.Document.Selection.NewLine()

				WriteLog (">>>>>>  Call BundleConfig.RegisterBundles() added to Global.asax.cs.")
			
				$asaxReady = $TRUE
			} else {
		
				WriteLog (">>>>>>  Could not add bundling to Global.asax.cs. Feature not available.")
			}
		} else {
	
			WriteLog (">>>>>>  Found call to BundleConfig.RegisterBundles(). No action needed.")
		
			$asaxReady = $TRUE
		}

		$asaxCs.Document.Close(0)

		WriteLog (">>>>>>  Document Global.asax.cs closed.")

	} else {

		WriteLog (">>>>>>  Global.asax.cs not found. Feature not available.")
	}
} else {

	WriteLog (">>>>>>  Global.asax not found. Feature not available.")
}
WriteLog ("Task 1/2: FINISHED")





#####  TASK 2: ADD BACKLOAD BUNDLES TO \APP_START\BUNDLECONFIG.CS FILE  #####

if ($asaxReady) {

	WriteLog ("TASK 2/2: ADD BACKLOAD BUNDLES TO \APP_START\BUNDLECONFIG.CS FILE")

	if ($appStart) {
		
		if($bundles) {
			WriteLog (">>>>>>  Found BundleConfig.cs file.")
			
			$bundles.Open()
			$bundles.Document.Activate()
			$bundles.Document.Selection.StartOfDocument()

			WriteLog (">>>>>>  Document BundleConfig.cs opened.")
			
			
			WriteLog (">>>>>>  Search for using Backload.Bundles; statement.")
							
			if  (!($bundles.Document.Selection.FindText("using Backload.Bundles;"))) {
				
				$bundles.Document.Selection.Text = "using Backload.Bundles;"
				
				WriteLog (">>>>>>  Using statement added to BundleConfig.cs.")
			}

			
			WriteLog (">>>>>>  Find the position at the beginning of the RegisterBundles method and add the text.")

			If (-Not ($bundles.Document.Selection.FindText("BackloadBundles.RegisterBundles(bundles);"))) {
			
				If ($bundles.Document.Selection.FindText("(BundleCollection bundles)")) {
				
					$bundles.Document.Selection.FindText("{")
					$bundles.Document.Selection.Collapse()
					$bundles.Document.Selection.NewLine()
					$bundles.Document.Selection.Text = "// Add or remove this line for the bundeling feature"
					$bundles.Document.Selection.NewLine()
					$bundles.Document.Selection.Text = "BackloadBundles.RegisterBundles(bundles);"
					$bundles.Document.Selection.NewLine()
					
					WriteLog (">>>>>>  Call BackloadBundles.RegisterBundles() added to BundleConfig.cs.")
				}
			}
			$bundles.Document.Close(0)

			WriteLog (">>>>>>  Document BundleConfig.cs closed.")
			
			
			# Delete Backload.BundleConfig.cs. We only need this, if no bundeling is installed
			$bundles_dummy = $appStart.ProjectItems | where { $_.Name -eq "Backload.BundleConfig.cs" }
			if($bundles_dummy) {
				$bundles_dummy.Delete()
			}
			
			WriteLog (">>>>>>  Document Backload.BundleConfig.cs deleted.")
		
			$feature_installed = $true
			
		} else {
		
			WriteLog (">>>>>>  BundleConfig.cs not found.")
			
			# Rename Backload.BundleConfig.cs to BundleConfig.cs.
			$bundles_dummy = $appStart.ProjectItems | where { $_.Name -eq "Backload.BundleConfig.cs" }
			if($bundles_dummy) {
				$bundles_dummy.Name = "BundleConfig.cs"
			}
			
			WriteLog (">>>>>>  Backload.BundleConfig.cs renamed to BundleConfig.cs.")

			$feature_installed = $true
		}
	} else {
	
		WriteLog (">>>>>>  App_Start folder not found. Bundle feature not available.")
	}
	
} else {

	# Delete Backload.BundleConfig.cs, because bundling is not available
	if ($appStart) {
		$bundles_dummy = $appStart.ProjectItems | where { $_.Name -eq "Backload.BundleConfig.cs" }
		if($bundles_dummy) {
			$bundles_dummy.Delete()
		}
		
		WriteLog (">>>>>>  Backload.BundleConfig.cs deleted, because bundling is not available.")
	
		$feature_installed = $false
	}
}
WriteLog ("Task 2/2: FINISHED.")


WriteLog ("INSTALLATION DONE.")
$script:log | Out-File $logFile






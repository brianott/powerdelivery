function Initialize-SSISPackagesDeliveryModule {

	Register-DeliveryModuleHook 'PostDeploy' {
	
		$moduleConfig = Get-BuildModuleConfig
		$ssisPackages = $moduleConfig.SSISPackages

		if ($ssisPackages) {
		
			Invoke-ConfigSections $ssisPackages "Invoke-SSIS"
		}
	}
}
function Initialize-RoundhouseDeliveryModule {

	Register-DeliveryModuleHook 'PostDeploy' {
	
		$moduleConfig = Get-BuildModuleConfig
		$roundhouseDatabases = $moduleConfig.Roundhouse

		if ($roundhouseDatabases) {
		
			Invoke-ConfigSections $roundhouseDatabases "Invoke-Roundhouse"
		}
	}
}
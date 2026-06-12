function Get-ModuleConfig { 
    [CmdletBinding()] 
    [OutputType([PSCustomObject])] 
    param( 
        [string]$configPath = "$PSScriptRoot\..\Config\moduleConfig.json" 
    ) 
    process { 
        if (Test-Path $configPath) { 
            $configData = Get-Content -Path $configPath -Raw | ConvertFrom-Json 
            return $configData 
        } 
        else { 
            Write-Warning "Module configuration file not found at: $configPath" 
            return [PSCustomObject]@{ 
                Error = "No module config file found." 
            } 
        } 
    } 
}
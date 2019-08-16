@{
    # Set up a mini virtual environment...
    PSDependOptions  = @{
        AddToPath  = $True
        Target     = 'BuildOutput\modules'
        Parameters = @{
        }
    }

    BuildHelpers     = 'latest'
    InvokeBuild      = 'latest'
    Pester           = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS          = 'latest'
    psdeploy         = 'latest'
}

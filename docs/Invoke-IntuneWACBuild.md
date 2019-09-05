---
external help file: IntuneWAC-help.xml
Module Name: IntuneWAC
online version:
schema: 2.0.0
---

# Invoke-IntuneWACBuild

## SYNOPSIS
This function will generate the json file that wille be uploaded to the graph

## SYNTAX

```
Invoke-IntuneWACBuild [-ConfigFile] <String> [[-OutputPath] <String>] [[-TemplatePath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function is meant to generete the JSON files that will be uploaded to the graph

## EXAMPLES

### EXAMPLE 1
```
Invoke-IntuneWACBuild -configFile .\examples\settings.json -templatePath .\examples\templates -OutputPath .\output -verbose
```

### EXAMPLE 2
```
Invoke-IntuneWACBuild -ConfigFile ".\examples\settings.json" -templatePath ".\examples\templates" -OutputPath ".\output"
```

## PARAMETERS

### -ConfigFile
Path to the config File

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Path where the JSON files will be saced

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplatePath
Path to the JSON template files that will be used

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

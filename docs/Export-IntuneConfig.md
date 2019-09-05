---
external help file: IntuneWAC-help.xml
Module Name: IntuneWAC
online version:
schema: 2.0.0
---

# Export-IntuneConfig

## SYNOPSIS
This function is used to Export the current configuration

## SYNTAX

```
Export-IntuneConfig [[-FilePath] <String>] [-ConfType] <String> [<CommonParameters>]
```

## DESCRIPTION
The function exports the current configuration of Intune

## EXAMPLES

### EXAMPLE 1
```
Export-IntuneConfig -ConfType Configuration -FilePath "C:\sources\pkm-intune\demo" -Verbose
```

Export Current configuration to spicified folder

### EXAMPLE 2
```
Export-IntuneConfig -ConfType All -FilePath "C:\sources\pkm-intune\demo"
```

Export Current configuration with verbose support

## PARAMETERS

### -FilePath
specify the path where you want to export the configuration to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfType
specify which type of config type you want to export: 'Configuration', 'Compliance', 'Script', 'All'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
NAME: Export-IntuneConfig

## RELATED LINKS

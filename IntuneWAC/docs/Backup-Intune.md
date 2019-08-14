---
external help file: IntuneWAC-help.xml
Module Name: IntuneWAC
online version:
schema: 2.0.0
---

# Backup-Intune

## SYNOPSIS
This function is used to authenticate with the Graph API REST interface

## SYNTAX

```
Backup-Intune [-Param] [<CommonParameters>]
```

## DESCRIPTION
The function authenticate with the Graph API Interface using username and password or using applicationID and Password

## EXAMPLES

### EXAMPLE 1
```
Get-authToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
```

Authenticates you with the Graph API interface

## PARAMETERS

### -Param
coming

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
NAME: Backup-Intune

## RELATED LINKS

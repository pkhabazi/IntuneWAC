---
external help file: IntuneWAC-help.xml
Module Name: IntuneWAC
online version:
schema: 2.0.0
---

# Get-AuthToken

## SYNOPSIS
This function is used to authenticate with the Graph API REST interface

## SYNTAX

```
Get-AuthToken [[-UserName] <String>] [[-Password] <String>] [[-ClientId] <String>] [[-ClientSecret] <String>]
 [-TenantId] <String> [[-RefreshToken] <String>] [-Authtype] <String> [<CommonParameters>]
```

## DESCRIPTION
The function authenticate with the Graph API Interface using username and password or using applicationID and Password

## EXAMPLES

### EXAMPLE 1
```
Get-authToken -clientId "clientId" -clientSecret "clientSecret" -tenantId "tenantID" -Authtype Application
```

Authenticates you with the Graph API interface

### EXAMPLE 2
```
Get-authToken -userName "UserName" -password "Password" -tenantId "tenantID" -Authtype User -Verbose
```

Authenticates you with the Graph API interface

## PARAMETERS

### -UserName
coming

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

### -Password
coming

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

### -ClientId
coming

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

### -ClientSecret
coming

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
coming

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshToken
coming

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Authtype
coming

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
NAME: Get-authToken

## RELATED LINKS

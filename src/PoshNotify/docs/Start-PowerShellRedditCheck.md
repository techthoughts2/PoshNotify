---
external help file: PoshNotify-help.xml
Module Name: PoshNotify
online version:
schema: 2.0.0
---

# Start-PowerShellRedditCheck

## SYNOPSIS
Retrieves the top 5 posts from /r/PowerShell and sends them in a properly formatted message.

## SYNTAX

```
Start-PowerShellRedditCheck [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Engages the reddit.com site and returns the top 5 posts from /r/PowerShell subreddit and sends them in a properly formatted message.

## EXAMPLES

### EXAMPLE 1
```
Start-PowerShellRedditCheck
```

Sends message containing the top 5 posts from /r/PowerShell.

## PARAMETERS

### -Force
Skip confirmation

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None
## NOTES
This took a lot longer to make than I thought it would.

## RELATED LINKS

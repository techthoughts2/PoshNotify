---
external help file: PoshNotify-help.xml
Module Name: PoshNotify
online version:
schema: 2.0.0
---

# Start-PowerShellBlogCheck

## SYNOPSIS
Evaluates if a new PowerShell blog post has been published and sends slack messages notifying of the post.

## SYNTAX

```
Start-PowerShellBlogCheck [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Evaluates PowerShell rss feed.
If a blog blob is not found, one will be populated.
The blog blob will be evaluated against rss information to determine if a new post is available.
If it is, the blob will be updated and slack messages will be sent.

## EXAMPLES

### EXAMPLE 1
```
Start-PowerShellBlogCheck
```

Evalutes PowerShell blog rss, updates blog blob as required, sends slack messages as required.

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

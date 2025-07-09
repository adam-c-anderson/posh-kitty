$osc = "`e]"
$st = "`e\"

# Save the original prompt function
if (-not (Test-Path Function:\OriginalPrompt)) {
    $function:OriginalPrompt = $function:prompt
}

function prompt {
    # OSC 133;A - indicates start of prompt
    # This is used by Final Term to indicate the start of a new prompt
    Write-Host -NoNewline "${osc}133;A${st}"

    # OSC 7 - Set the current working directory in the terminal
    $p = $executionContext.SessionState.Path.CurrentLocation
    if ($p.Provider.Name -eq "FileSystem") {
        $provider_path = $p.ProviderPath -Replace "\\", "/"
        Write-Host -NoNewline "${osc}7;file://${env:COMPUTERNAME}/${provider_path}${st}"
    }

    # Call the original prompt function and capture its output
    $originalPrompt = & $function:OriginalPrompt

    # Return the prompt string (don't Write-Host it, let PowerShell display it)
    # Append OSC 133;B - indicates end of prompt
    # This is used by Final Term to indicate the prompt is ready for input
    return "$originalPrompt${osc}133;B${st}"
}

# Save the original continuation prompt only once
if (-not (Get-Variable -Name OriginalContinuationPrompt -Scope Script -ErrorAction SilentlyContinue)) {
    $script:OriginalContinuationPrompt = (Get-PSReadLineOption).ContinuationPrompt
}
Set-PSReadLineOption -ContinuationPrompt "${osc}133;A;k=s${st}$script:OriginalContinuationPrompt"

# Override Out-Default to inject escape codes before all output
# Out-Default is a cmdlet, not a function, so we need to use a different approach
function Out-Default {
    param([Parameter(ValueFromPipeline = $true)] $InputObject)
    
    begin {
        # Output escape code before command output
        Write-Host -NoNewline "${osc}133;C${st}"
        $allObjects = @()
    }
    
    process {
        # Collect all objects instead of processing them individually
        $allObjects += $InputObject
    }
    
    end {
        # Send all collected objects to the original Out-Default at once
        # This preserves the formatting context and header grouping
        $allObjects | Microsoft.PowerShell.Core\Out-Default
        
        # Determine exit status for Final Term specification
        $exitCode = 0
        
        # Check various error conditions
        if ($null -ne $LASTEXITCODE) {
            $exitCode = $LASTEXITCODE
        } elseif ($Error.Count -gt 0) {
            # PowerShell error occurred
            $exitCode = 1
        } elseif ($? -eq $false) {
            # Command failed
            $exitCode = 1
        }
        
        # 133;D;exit_code - indicates command finished with exit code
        Write-Host -NoNewline "${osc}133;D;${exitCode}${st}"
    }
}

# kitty hyperlinked ls support; depends on gls (install with `brew install coreutils`)
if (Get-Command gls -ErrorAction SilentlyContinue) {
    function ls { gls --hyperlink --color @args }
}

# kitty hyperlinked grep support; depends on rg (install with `brew install ripgrep`)
# To fully enable this, you also need to configure open-actions.conf
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function hg { kitten hyperlinked-grep @args }
}
# posh-kitty
Full implementation of PowerShell integration for [kitty terminal](https://sw.kovidgoyal.net/kitty/).

All protocols for marking the prompt as listed in [Notes for shell developers](https://sw.kovidgoyal.net/kitty/shell-integration/#notes-for-shell-developers) are fulfilled.

The full list of features that this enables are listed [here](https://sw.kovidgoyal.net/kitty/shell-integration/#features).

# Installing

1. Copy `Posh-Kitty.psm1` into your PS module path. If you don't know what your PS module path is, check `$env:PSModulePath`.
2. In your profile script, load the module with `Import-Module Posh-Kitty`. If you don't know where your profile script is, check `$PROFILE`.

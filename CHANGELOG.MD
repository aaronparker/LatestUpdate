# Change Log

## v1.0.1.27

### General

- Inline help updates, code style formatting
- Update module description
- Update module release notes link

### Private functions

- Add `Test-PSCore` for testing when environment is PowerShell Core
- Add suppression of PSUseDeclaredVarsMoreThanAssignments for PSScriptAnalyzer false positive in `Select-LatestUpdate`
- Pester tests now test `Select-LatestUpdate`

### Public functions

- Update `Get-LatestUpdate` and `Save-LatestUpdate` with support for PowerShell Core
- Better error handling in `Import-LatestUpdate`

### Tests

- Add Pester tests for `Test-PSCore`

## v1.0.1.20

### General

- Fix ProjectUri

### Private functions

- Rename `Get-ValidPath` (from `Test-UpdateParameter`)
- Simplify `Import-MdtModule` output
- Add `New-MdtDrive`
- Add `Remove-MdtDrive`
- Improve `New-MdtPackagesFolder` robustness, update output
- Update `Select-LatestUpdate` notes
- Update `Select-UniqueUrl` notes

### Public functions

- Update `Get-LatestUpdate` inline help
- Update `Import-LatestUpdate` inline help, parameters, new MDT drive, more robust action when creating the MDT package folder
- Fix pipeline support for `Save-LatestUpdate`

### Tests

- Detailed Pester tests for Private and Public functions

## v1.0.1.11

- First v1 public release
- Published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/LatestUpdate/)

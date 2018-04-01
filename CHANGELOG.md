# Change Log

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
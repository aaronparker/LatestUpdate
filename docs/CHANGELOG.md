# Change Log

## v2.4.1.97

### Public Functions

* Update Microsoft update feed issue handling. The Microsoft Atom/RSS feeds [https://support.microsoft.com/en-au/help/4089498](https://support.microsoft.com/en-au/help/4089498) used by this module do not consistently include the required information to find the update list. `Get-LatestUpdate`, `Get-LatestFlash` and `Get-LatestServicingStack` now exit more gracefully if the required content cannot be found and write a warning to alert of the issue.

### Private Functions

* Add `PSPath` alias to `Get-ValidPath`

### Tests

* A check is performed before running `Save-LatestUpdate` to avoid download if the tests are not running in AppVeyor. This avoids having to wait for downloads on my slow home internet when running tests.

## v2.4.0.89

### Public Functions

- Removed support for Windows 10 1511 (build 10586) in `Get-LatestUpdate` as updates for this build are no longer available in the update feed. Support for Windows 10 1511 finished in October 2017 with the last update being made available in April 2018
- Updated `Get-LatestUpdate` to return only .MSU updates. Fixes issue #27  and #23
- Account for missing architecture and version strings in `Get-LatestFlash`
- Updated `Import-LatestUpdate` to create packages folders such as "Windows 10\1803", where the parent folder does not already exist. Fixes issue #30 
- Updated code to fix removing existing packages with -Clean in `Import-LatestUpdate`. Fixes issue #29 
- Updated LINK in comments in public functions to point to https://docs.stealthpuppy.com/latestupdate

### Private Functions

- Fix an issue where stepping through multiple KBs was not handled correctly in `Get-LatestServicingStack`
- Add additional error checking to `Get-LatestServicingStack`
- Update private function `Get-UpdateDownloadArray` to fix download URLs returned for .MSU and .EXE updaters for Windows 7
- Update logic in private function `New-MdtPackagesFolder` to cater for multiple paths (e.g. parent\child)

## v2.3.1.81

### Private Functions

- Fix version string for Windows Server 2016/2019, Windows Server 2008 R2, Windows 7 in `Get-UpdateDownloadArray`

### Tests

- Add Pester tests for `Get-LatestUpdate -WindowsBuild Windows8` and `Get-LatestUpdate -WindowsBuild Windows7`

## v2.3.0.78

### Public Functions

- Ensure `Get-LatestUpdate`, `Get-LatestServicingStack` & `Get-LatestFlash` return consistent output
- Sort output in `Get-LatestFlash` and `Get-LatestUpdate` on Version property

### Private Functions

- Update `Get-UpdateDownloadArray` to add Version property to function outputs

### Tests

- Add tests for Version property in all public functions

## v.2.2.0.74

### Public Functions

- Add `Get-LatestServicingStack` Public function to return Servicing Stack updates for Windows 10 versions.
- Update module description

### Tests

- Add Pester tests for `Get-LatestServicingStack`

## v2.1.0.69

### Public Functions

- Added `Get-LastestFlash` public function to return the latest Adobe Flash Player updates for Windows 10, Windows Server 2016 / 2019 etc.
- Update module version to 2.1
- Add -ForceWebRequest parameter to `Save-LatestUpdate` to enable force usage of `Invoke-WebRequest` over `Start-BitsTransfer` even on Windows PowerShell
- Update `Save-WebRequest` to use private function `Test-PSCore` to test whether module is running under PowerShell Core and to use `Invoke-WebRequest` over `Start-BitsTransfer`

### Private Functions

- Added private functions `Get-KbUpdateArray`, `Get-RxString`, `Get-UpdateCatalogLink`, `Get-UpdateCatalogLink`, `Get-UpdateDownloadArray`, `Get-UpdateFeed` to optimise shared code across `Get-LastestFlash` and `Get-LatestUpdate` public functions.

### Tests

- Update Public and Private function Pester tests

## v2.0.0.51

### Public Functions

- Changed to use RSS Atom feed for each version of Windows. This feed is kept up to date by Microsoft (Thanks to @BladeFireLight)
- Changed process to determine latest update based on Windows 10 build minor number instead of KB number (Thanks to @BladeFireLight)
- Updated `Get-LatestUpdate` to return an array of all processor architectures. Returns KB, Architecture, Note, URL to the pipeline that can be filtered in a script
- Removed dynamic parameters -Architecture, -SearchString as these are no longer needed
- Updated `Get-LatestUpdate` to support Windows 10 1809
- Improved error handling and feed retrieval in `Get-LatestUpdate`
- Updated `Save-LatestUpdate` to support new output from `Get-LatestUpdate`

### Tests

- Update Pester tests in `PublicFunctions.Tests.ps1` to support new output format in `Get-LatestUpdate`

## v1.1.0.38

### Public Functions

- Modified `Invoke-WebRequest` calls within `Get-LatestUpdate` and `Save-LatestUpdate` to use the `UseBasicParsing` parameter, removing the reliance on Internet Explorer, and enabling the script to work in PowerShell 6

## v1.1.0.37

### Public Functions

- Updated `Get-LatestUpdate` to support Windows 10 1803 (17134)

## v1.1.0.36

### Public Functions

- Fix inline help examples for `Import-LatestUpdate` to address issue #11

### Tests

- Update Pester tests in `PublicFunctions.Tests.ps1` to ensure successful tests for `Get-LatestUpdate` using `Should -Not -BeNullOrEmpty`

## v1.1.0.34

### General

- Update module version
- Inline help updates
- Module description updates

### Public Functions

- Add support for Windows 8.1 / 7 (and Windows Server 2012 R2 / 2008 R2) to `Get-LatestUpdate`
- Change parameters with `-WindowsVersion`, `-Build`, `-Architecture` in `Get-LatestUpdate` to support Windows OS changes

### Private Functions
- Add private function New-DynamicParam to support `-WindowsVersion`, `-Build`, `-Architecture` in `Get-LatestUpdate`

### Tests

- Update Pester tests

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

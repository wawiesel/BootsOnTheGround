# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

## [unreleased] - YYYY-MM-DD

### Added
- none.

### Changed
- none.

### Deprecated
- none.

### Removed
- travis CI because could not get it to work

### Fixed
- none.

### Security
- none.

---

## [v0.12.0] - 2017-08-27

### Added
- BOOST/MATH TPL with distributions, quaternions, special functions and more

### Changed
- upgraded to HunterGate v0.19.84
- interface to botgHuntTPL, now passing arguments for HUNTER_ADD_PACKAGE and FIND_PACKAGE

---

## [v0.11.1] - 2017-08-05

### Fixed
- issue where botgPackagesList macro was not parsing directory paths correctly.

---

## [v0.11.0] - 2017-08-05

### Added
- this change log!
- botgTPLsList macro for registering TPLs in a project's TPLsList.cmake file.

### Changed
- botgPackagesList, so the BootsOnTheGround package is implicitly added.
  Providing it is now an error.

### Deprecated
- botgProjectContents, to be replaced with botgPackagesList.

### Removed
- botgAddTPL macro. Instead use botgPackageDependencies.

### Fixed
- some random debugging output of test regexes.

---

# Clipboard

Every time you make a new release branch off develop, just
copy-paste this to restart the change log entry.

## [unreleased] - YYYY-MM-DD

### Added
- none.

### Changed
- none.

### Deprecated
- none.

### Removed
- none.

### Fixed
- none.

### Security
- none.


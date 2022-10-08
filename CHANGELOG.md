## [1.3.6] - 2022-10-08
### Added
*  added a CHANGELOG.md file
*  added specific non-handling of screen modes

### Fixed
*  fixed indexing error when escape code included no integers

## [1.3.5] - 2021-02-05
### Changed
*  Output no longer includes useless spans.

### Fixed
*  better handling of non-display code amidst display ones

## [1.3.4] - 2021-02-05
### Changed
*  now supports building under Crystal v0.35.1

### Fixed
*  fixed missing end span edge case

## [1.3.3] - 2018-10-01
## [1.3.2] - 2018-10-01
### Fixed
*  Corrected bug where the ends of escape sequences were not being correctly detected

## [1.3.1] - 2018-09-03
### Deprecated
* [\[4\]](https://github.com/masukomi/oho/issues/4) corrects detection and handling of rgb color escape sequences

## [1.3.0] - 2018-06-15
### Added
*  Added Support for ITU's T.416 / 8613-6  color codes

## [1.2.0] - 2018-06-05
### Added
*  Added support for customer styling via -s arg

### Fixed
*  further corrections to default background and foreground handling

## [1.1.1] - 2018-06-05
### Fixed
*  Corrected problem where requesting --help resulted in double output
*  Corrected background and foreground color handling

## [1.1.0] - 2018-05-26
### Added
*  Added print media CSS for better PDF conversions

### Fixed
*  simplified build.sh to remove some git complications

## [1.0.0] - 2018-05-25

# OguryCore

All notable changes to this project will be documented in this file. The project adheres to [Semantic Versioning](http://semver.org).

---
## [1.3.0](https://github.com/Ogury/sdk-core-ios/tree/1.3.0) (2022/11/10)

### Changed

- Add gestion of url error.
- Review log management.

## [1.2.0](https://github.com/Ogury/sdk-core-ios/tree/1.2.0) (2022/06/14)

### Changed

- Fixed an issue with OguryLogLevel visibility.

## [1.1.0](https://github.com/Ogury/sdk-core-ios/tree/1.1.0) (2022/04/14)

### Added

- Added the `getFrameworkType` method for monitoring & fixed an issue with `getVersion` method [SPY-10902]

### Changed

- Improved the logs [SPY-10822]

## [1.0.0](https://github.com/Ogury/sdk-core-ios/tree/1.0.0) (2022/01/25)

Official release.

### Added

- Added Consent Token generation [SPY-10530]

## [0.2.1](https://github.com/Ogury/sdk-core-ios/tree/0.2.1) (2020/12/16)

### Changed

- Improved OguryError to take NSInteger instead of a hardcoded enum

## [0.2.0](https://github.com/Ogury/sdk-core-ios/tree/0.2.0) (2020/11/18)

### Added

- Added NetworkClient [ADV-7946]

## [0.1.7](https://github.com/Ogury/sdk-core-ios/tree/0.1.7) (2020/11/17)

### Added

- Added missing method for CM IDFA managment

## [0.1.6](https://github.com/Ogury/sdk-core-ios/tree/0.1.6) (2020/11/16)

### Fixed

- Fixed XCFramework product name when suffix

## [0.1.5](https://github.com/Ogury/sdk-core-ios/tree/0.1.5) (2020/11/12)

### Added

- Added IDFA Manager in Core SDK [ADV-7943]

## [0.1.4](https://github.com/Ogury/sdk-core-ios/tree/0.1.4) (2020/11/10)

### Fixed

- Removed `VALID_ARCHS` build setting.

## [0.1.3](https://github.com/Ogury/sdk-core-ios/tree/0.1.3) (2020/11/02)

### Fixed

- Used `copy` instead of `retain` for the `eventSubscriber`'s `eventHandler` property [ADV-6916]

## [0.1.2](https://github.com/Ogury/sdk-core-ios/tree/0.1.2) (2020/10/19)

### Changed

- Improved event entry instanciation [ADV-7237]

### Fixed

- Fixed an issue with the CI performing archiving instead of building

## [0.1.1](https://github.com/Ogury/sdk-core-ios/tree/0.1.1) (2020/09/24)

### Fixed

- Removed unwanted unavailable initialiser

## [0.1.0](https://github.com/Ogury/sdk-core-ios/tree/0.1.0) (2020/09/23)

### Changed

- Moved EventBus headers into private membership [ADV-6916]

## [0.1.0-beta-3](https://github.com/Ogury/sdk-core-ios/tree/0.1.0-beta-3) (2020/08/31)

### Changed

- Greatly improved TravisCI & `fastlane` configurations

## [0.1.0-beta-2](https://github.com/Ogury/sdk-core-ios/tree/0.1.0-beta-2) (2020/08/25)

### Changed

- Tweaked TravisCI regex

## [0.1.0-beta-1](https://github.com/Ogury/sdk-core-ios/tree/0.1.0-beta-1) (2020/08/24)

Initial release

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2018-08-27
### Changed
- Exposed `minimumLineSpacing` and `minimumInteritemSpacing` properties to the Obj-C runtime.

## [1.2.0] - 2018-08-23
### Added
- Added `minimumLineSpacing` and `minimumInteritemSpacing` properties for setting the minimum spacing to use between lines of items in the grid and the minimum spacing to use between items in the same row respectively.

## [1.1.1] - 2018-08-14
### Changed
- Moved `FlexibleRowHeightGridLayout.swift` -> `FlexibleRowHeightGridLayout/Classes/FlexibleRowHeightGridLayout.swift`
- Moved `FlexibleRowHeightGridLayoutDelegate.swift` -> `FlexibleRowHeightGridLayout/Classes/FlexibleRowHeightGridLayoutDelegate.swift`

## [1.1.0] - 2018-08-09
### Added
- Added an example app comparing `UICollectionViewFlowLayout` and `FlexibleRowHeightGridLayout`.

### Changed
- Fixed issue whereby `FlexibleRowHeightGridLayout` initializer was inaccessible due not being marked as public.
- In `FlexibleRowHeightGridLayoutDelegate` the following methods have been changed:
	- `func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat` *becomes ->* `@objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout, referenceHeightForFooterInSection section: Int) -> CGFloat`
	- `@objc optional func collectionView(_ collectionView: UICollectionView, referenceHeightForHeaderInSection section: Int) -> CGFloat` *becomes ->* `@objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout, referenceHeightForFooterInSection section: Int) -> CGFloat`
	- `@objc optional func collectionView(_ collectionView: UICollectionView, referenceHeightForFooterInSection section: Int) -> CGFloat` *becomes ->* `@objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout, referenceHeightForFooterInSection section: Int) -> CGFloat`

## [1.0.0] - 2018-08-08
### Added
- Support for sections including headers and / or footers.

## [0.2.0] - 2018-08-07
### Added
- Support for Swift Package Manager when using Xcode 11.

## [0.1.0] - 2018-08-06
### Added
- A UICollectionView grid layout designed to support Dynamic Type by allowing the height of each row to size to fit content.
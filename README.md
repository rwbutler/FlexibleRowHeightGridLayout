![FlexibleRowHeightGridLayout](https://github.com/rwbutler/FlexibleRowHeightGridLayout/raw/master/docs/images/flexible-row-banner.png)

[![CI Status](https://img.shields.io/travis/rwbutler/FlexibleRowHeightGridLayout.svg?style=flat)](https://travis-ci.org/rwbutler/FlexibleRowHeightGridLayout)
[![Version](https://img.shields.io/cocoapods/v/FlexibleRowHeightGridLayout.svg?style=flat)](https://cocoapods.org/pods/FlexibleRowHeightGridLayout)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FlexibleRowHeightGridLayout.svg?style=flat)](https://cocoapods.org/pods/FlexibleRowHeightGridLayout)
[![Platform](https://img.shields.io/cocoapods/p/FlexibleRowHeightGridLayout.svg?style=flat)](https://cocoapods.org/pods/FlexibleRowHeightGridLayout)
[![Twitter](https://img.shields.io/badge/twitter-@ross_w_butler-blue.svg?style=flat)](https://twitter.com/ross_w_butler)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org/)

FlexibleRowHeightGridLayout is a `UICollectionViewLayout` which lays out self-sizing cells in a grid and is designed to support accessibility, in particular, [Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically). It is designed to automatically re-layout with changes in text size on the device (`UIContentSizeCategory`). Row heights are flexible with this layout i.e. each row may have different height where the height of the row is determined by the tallest cell in the row so that the row height will always fit the content within the row.

<div align="center">
    <img width="414" height="438" src="https://github.com/rwbutler/FlexibleRowHeightGridLayout/raw/master/docs/images/flexible-row-heights.png" alt="Illustration of flexible row heights">
</div>

To learn more about how to use FlexibleRowHeightGridLayout take a look at the [blog post](https://medium.com/@rwbutler/accessible-uicollectionviews-with-dynamic-type-and-self-sizing-cells-b06330c14c4c) or make use of the table of contents below:

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
	- [Cocoapods](#cocoapods)
	- [Carthage](#carthage)
	- [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)
	- [FlexibleRowHeightGridLayoutDelegate](#flexiblerowheightgridlayoutdelegate)
- [FAQs](#faqs)
- [Author](#author)
- [License](#license)
- [Additional Software](#additional-software)
	- [Frameworks](#frameworks)
	- [Tools](#tools)

## Features

- [x] Grid layout supporting changes in text size - will automatically re-layout with changes in `UIContentSizeCategory` ([Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically)).
- [x] Supports self-sizing [UICollectionViewCells](https://developer.apple.com/documentation/uikit/uicollectionviewcell).
- [x] Supports sections including headers and / or footers.

## Requirements

FlexibleRowHeightGridLayout is written in Swift 5.0 and is available on iOS 8.0 or higher.

## Installation

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager which integrates dependencies into your Xcode workspace. To install it using [Ruby gems](https://rubygems.org/) run:

```bash
gem install cocoapods
```

To install FlexibleRowHeightGridLayout using Cocoapods, simply add the following line to your Podfile:

```ruby
pod "FlexibleRowHeightGridLayout"
```

Then run the command:

```ruby
pod install
```

For more information [see here](https://cocoapods.org/#getstarted).

### Carthage

Carthage is a dependency manager which produces a binary for manual integration into your project. It can be installed via [Homebrew](https://brew.sh/) using the commands:

```bash
brew update
brew install carthage
```

In order to integrate FlexibleRowHeightGridLayout into your project via Carthage, add the following line to your project's Cartfile:

```ogdl
github "rwbutler/FlexibleRowHeightGridLayout"
```

From the macOS Terminal run `carthage update --platform iOS` to build the framework then drag `FlexibleRowHeightGridLayout.framework` into your Xcode project.

For more information [see here](https://github.com/Carthage/Carthage#quick-start).

### Swift Package Manager

Xcode 11 includes support for [Swift Package Manager](https://swift.org/package-manager/). In order to add FlexibleRowHeightGridLayout to your project in Xcode 11, from the `File` menu select `Swift Packages` and then select `Add Package Dependency`.

A dialogue will request the package repository URL which is:

```
https://github.com/rwbutler/FlexibleRowHeightGridLayout
```

After verifying the URL, Xcode will prompt you to select whether to pull a specific branch, commit or versioned release into your project. 


Proceed to the next step by where you will be asked to select the package product to integrate into a target. There will be a single package product named `FlexibleRowHeightGridLayout` which should be pre-selected. Ensure that your main app target is selected from the rightmost column of the dialog then click Finish to complete the integration.

## Usage

In order to have your `UICollectionView` make use of `FlexibleRowHeightGridLayout` to layout content you may either instantiate a new instance and assign it to the collection view's `collectionViewLayout` property if your collection view is defined in Interface Builder as follows:

```
let layout = FlexibleRowHeightGridLayout()
layout.delegate = self
collectionView.collectionViewLayout = layout
// Following line is only required if content has already been loaded before collectionViewLayout property set.
collectionView.reloadData()
```

Or, if your `UICollectionView` is instantiated programmatically then you may pass the layout to the `UICollectionView`'s initializer:

```
let layout = FlexibleRowHeightGridLayout()
layout.delegate = self
let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
```

Notice that in both cases you are required to provide an implementation of the layout's delegate -`FlexibleRowHeightGridLayoutDelegate`.

### FlexibleRowHeightGridLayoutDelegate

The delegate defines two methods which must be implemented in order to allow `FlexibleRowHeightGridLayout` to layout items correctly. These are:

* `func collectionView(_ collectionView: UICollectionView,  layout: FlexibleRowHeightGridLayout, heightForItemAt indexPath: IndexPath) -> CGFloat`

Should return the height of the item for the given `IndexPath`. Using this information the layout is able to calculate the correct height for the row. When calculating the height of text, you find it useful to make use of `NSString`'s [func boundingRect(with size: options: attributes: context:) -> CGRect](https://developer.apple.com/documentation/foundation/nsstring/1524729-boundingrect) function as follows:

```
let constraintRect = CGSize(width: columnWidth, height: .greatestFiniteMagnitude)
let textHeight = "Some text".boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
```
    
* `func numberOfColumns(for size: CGSize) -> Int`

Should return the number of columns in the `UICollectionView`'s grid when the `UICollectionView` is of the specified size. For example, the `UICollectionView` may have larger bounds when the device is in landscape and therefore you may want your `UICollectionView` to have 4 columns when the device is in landscape orientation and only 3 when in portrait.

There are another two delegate methods which may optionally be implemented should you wish to include a header and / or footer as part of your UICollectionView:

* `@objc optional func collectionView(_ collectionView: UICollectionView,  layout: FlexibleRowHeightGridLayout, referenceHeightForHeaderInSection section: Int) -> CGFloat`

Should return the height of the header in your UICollectionView. If the value returned from this function is zero than no header will be added.

* `@objc optional func collectionView(_ collectionView: UICollectionView,  layout: FlexibleRowHeightGridLayout, referenceHeightForFooterInSection section: Int) -> CGFloat`

Should return the height of the footer in your UICollectionView. If the value returned from this function is zero than no footer will be added.

## FAQS

### Does this layout support section headers and / or footers?

Yes, in order to add a section header and / or footer to your UICollectionView ensure that you provide an implementation for the two optional delegate methods in `FlexibleRowHeightGridLayoutDelegate`:

 * `@objc optional func collectionView(_ collectionView: UICollectionView,  layout: FlexibleRowHeightGridLayout, referenceHeightForHeaderInSection section: Int) -> CGFloat`

* `@objc optional func collectionView(_ collectionView: UICollectionView,  layout: FlexibleRowHeightGridLayout, referenceHeightForFooterInSection section: Int) -> CGFloat`

## Author

[Ross Butler](https://github.com/rwbutler)

## License

FlexibleRowHeightGridLayout is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Additional Software

### Controls

* [AnimatedGradientView](https://github.com/rwbutler/AnimatedGradientView) - Powerful gradient animations made simple for iOS.

|[AnimatedGradientView](https://github.com/rwbutler/AnimatedGradientView) |
|:-------------------------:|
|[![AnimatedGradientView](https://raw.githubusercontent.com/rwbutler/AnimatedGradientView/master/docs/images/animated-gradient-view-logo.png)](https://github.com/rwbutler/AnimatedGradientView) 

### Frameworks

* [Cheats](https://github.com/rwbutler/Cheats) - Retro cheat codes for modern iOS apps.
* [Connectivity](https://github.com/rwbutler/Connectivity) - Improves on Reachability for determining Internet connectivity in your iOS application.
* [FeatureFlags](https://github.com/rwbutler/FeatureFlags) - Allows developers to configure feature flags, run multiple A/B or MVT tests using a bundled / remotely-hosted JSON configuration file.
* [FlexibleRowHeightGridLayout](https://github.com/rwbutler/FlexibleRowHeightGridLayout) - A UICollectionView grid layout designed to support Dynamic Type by allowing the height of each row to size to fit content.
* [Skylark](https://github.com/rwbutler/Skylark) - Fully Swift BDD testing framework for writing Cucumber scenarios using Gherkin syntax.
* [TailorSwift](https://github.com/rwbutler/TailorSwift) - A collection of useful Swift Core Library / Foundation framework extensions.
* [TypographyKit](https://github.com/rwbutler/TypographyKit) - Consistent & accessible visual styling on iOS with Dynamic Type support.
* [Updates](https://github.com/rwbutler/Updates) - Automatically detects app updates and gently prompts users to update.

|[Cheats](https://github.com/rwbutler/Cheats) |[Connectivity](https://github.com/rwbutler/Connectivity) | [FeatureFlags](https://github.com/rwbutler/FeatureFlags) | [Skylark](https://github.com/rwbutler/Skylark) | [TypographyKit](https://github.com/rwbutler/TypographyKit) | [Updates](https://github.com/rwbutler/Updates) |
|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Cheats](https://raw.githubusercontent.com/rwbutler/Cheats/master/docs/images/cheats-logo.png)](https://github.com/rwbutler/Cheats) |[![Connectivity](https://github.com/rwbutler/Connectivity/raw/master/ConnectivityLogo.png)](https://github.com/rwbutler/Connectivity) | [![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-logo.png)](https://github.com/rwbutler/FeatureFlags) | [![Skylark](https://github.com/rwbutler/Skylark/raw/master/SkylarkLogo.png)](https://github.com/rwbutler/Skylark) | [![TypographyKit](https://raw.githubusercontent.com/rwbutler/TypographyKit/master/docs/images/typography-kit-logo.png)](https://github.com/rwbutler/TypographyKit) | [![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-logo.png)](https://github.com/rwbutler/Updates)

### Tools

* [Config Validator](https://github.com/rwbutler/ConfigValidator) - Config Validator validates & uploads your configuration files and cache clears your CDN as part of your CI process.
* [IPA Uploader](https://github.com/rwbutler/IPAUploader) - Uploads your apps to TestFlight & App Store.
* [Palette](https://github.com/rwbutler/TypographyKitPalette) - Makes your [TypographyKit](https://github.com/rwbutler/TypographyKit) color palette available in Xcode Interface Builder.

|[Config Validator](https://github.com/rwbutler/ConfigValidator) | [IPA Uploader](https://github.com/rwbutler/IPAUploader) | [Palette](https://github.com/rwbutler/TypographyKitPalette)|
|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Config Validator](https://raw.githubusercontent.com/rwbutler/ConfigValidator/master/docs/images/config-validator-logo.png)](https://github.com/rwbutler/ConfigValidator) | [![IPA Uploader](https://raw.githubusercontent.com/rwbutler/IPAUploader/master/docs/images/ipa-uploader-logo.png)](https://github.com/rwbutler/IPAUploader) | [![Palette](https://raw.githubusercontent.com/rwbutler/TypographyKitPalette/master/docs/images/typography-kit-palette-logo.png)](https://github.com/rwbutler/TypographyKitPalette)
BZipCompression
===============

[![Build Status](https://travis-ci.org/blakewatters/BZipCompression.png?branch=master)](https://travis-ci.org/blakewatters/BZipCompression)
![Pod Version](http://cocoapod-badges.herokuapp.com/v/BZipCompression/badge.png) 
![Pod Platform](http://cocoapod-badges.herokuapp.com/p/BZipCompression/badge.png)

**An Objective-C interface to the BZip2 compression library**

[BZip2](http://bzip.org/) is freely available, patent free, high-quality data compressor. It is highly portable and C library implementations are available on all OS X and iOS devices.

BZipCompression is a simple Objective-C interface to the BZip2 compression library. It wraps the low level interface of the bz2 C library into a straightforward, idiomatic Objective-C class.

## Features

* Decompress `NSData` instances containing data that was compressed with the BZip2 algorithm.
* Compress an `NSData` instance containing arbitrary data into a bzip2 representation.

## Usage

The library is implemented as a static interface with only two public methods: one for compression and one for decompression.

### Decompressing Data

```objc
NSURL *compressedFileURL = [[NSBundle mainBundle] URLForResource:@"SomeLargeFile" withExtension:@".json.bz2"];
NSData *compressedData = [NSData dataWithContentsOfURL:compressedFileURL];
NSError *error = nil;
NSData *decompressedData = [BZipCompression decompressedDataWithData:compressedData error:&error];
```

### Compressing Data

```objc
NSData *stringData = [@"You probably want to read your data from a file or another data source rather than using string literals." dataUsingEncoding:NSUTF8StringEncoding];
NSError *error = nil;
NSData *compressedData = [BZipCompression compressedDataWithData:stringData blockSize:BZipDefaultBlockSize workFactor:BZipDefaultWorkFactor error:&error];
```

## Installation

BZipCompression is extremely lightweight and has no direct dependencies outside of the Cocoa Foundation framework and the BZip2 library. As such, the library can be trivially be installed into any Cocoa project by directly adding the source code and linking against libbz2. Despite this fact, we recommend installing via CocoaPods as it provides modularity and easy version management.

### Via CocoaPods

The recommended approach for installing BZipCompression is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via CocoaPods **>= 0.24.0** using Git **>= 1.8.0** installed via Homebrew.

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and Create and Edit your Podfile and add BZipCompression:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
platform :ios, '5.0' 
# Or platform :osx, '10.7'
pod 'BZipCompression', '~> 1.0.0'
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

### Via Source Code

Simply add `BZipCompression.h` and `BZipCompression.m` to your project and `#import "BZipCompression.h"`.

## Unit Tests

BZipCompression is tested using the [Expecta](https://github.com/specta/Expecta) library of unit testing matchers. In order to run the tests, you must do the following:

1. Install the dependencies via CocoaPods: `pod install`
1. Open the workspace: `open BZipCompression.xcworkspace`
1. Run the specs via the **Product** menu > **Test**

## Credits

Blake Watters

- http://github.com/blakewatters
- http://twitter.com/blakewatters
- blakewatters@gmail.com

## License

BZipCompression is available under the Apache 2 License. See the LICENSE file for more info.

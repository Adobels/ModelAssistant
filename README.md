
<p align="center"><img src="HeaderImage/HeaderImage.png" width="800" height="200"/>

 An assistant to manage the interactions between view and model


[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/ModelAssistant.svg)](https://github.com/ssamadgh/ModelAssistant/blob/master/LICENSE)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ModelAssistant.svg)](https://img.shields.io/cocoapods/v/ModelAssistant.svg)
[![Platform](https://img.shields.io/cocoapods/p/ModelAssistant.svg?style=flat)](https://ssamadgh.github.io/ModelAssistant)
[![codebeat badge](https://codebeat.co/badges/b9643fd8-9f23-49e6-82ae-f43de233ca8a)](https://codebeat.co/projects/github-com-ssamadgh-modelassistant-master)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@ssamadgh-blue.svg?style=flat)](https://twitter.com/ssamadgh)


ModelAssistant is a mediator between the view and model. This framework is tailored to work in conjunction with views that present collections of objects. 
These views typically expect their data source to present results as a list of sections made up of rows. ModelAssistant can efficiently analyze model objects and categorize them in sections. In addition it updates adopted view to its delegate, based on model objects changes.

- [Features](#features)
- [What's New](#what's-New)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md)
	- **Preparation -** [Preparing Model Object](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-model-object), [Preparing View](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-view), [Preparing Delegate](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-delegate)
	- **Interaction -** [Documentation](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#documentation), [Examples](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#examples)
- [Advanced Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md)
	- **MAEntitiy** [Inheritance](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#inheritance), [Hashable](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#hashable)
	- **ModelAssistant** [More Configurations](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#more-configurations), [Export Entities](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#export-entities), [Using with Core Data and Realm](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#using-with-core-data-and-realm)


## Features
- [x] Inserting / Removing / Ordering / Updating model objects
- [x] Notifies changes to view
- [x] Full compatible with UITableView and UICollectionView
- [x] Supports Sections
- [x] Supports index titles
- [x] Compatible with Server data source
- [x] Compatible with all kind of persistent stores
- [x] Compatible with all design patterns
- [x] **Easy to use**
- [x] **Thread safe**
- [x] **Fault Ability**
- [x] [Complete Documentation](https://ssamadgh.github.io/ModelAssistant/)

## What's New:

### Version 1.1.3:

Now using modelAssitant is really easy with just two lines of codes, and delegates will be implement automatically to your collection view.

See [Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md) for new way of implementing modelAssistant.


### Version 1.0.8.3:

Upgraded to Swift 5
	
### Version 1.0.8:
- **Fault Ability:**  Now you can make entities in an specific range fault or fire them. For more information see [Advanced Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#mafaultable)


## Requirements

- iOS 8.0+ 
- Xcode 8.3+
- Swift 3.1+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ModelAssistant into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do

    pod 'ModelAssistant'
    
end

```
If you are not upgraded to Swift 4.2, use the last non-swift 4.2 compatible release:

If you are using swift 4, replace `pod 'ModelAssistant'` with this:

```ruby
pod 'ModelAssistant', '1.0.1' #Swift 4
```
 
 If you are using swift 3, replace `pod 'ModelAssistant'` with this:

```ruby 
pod 'ModelAssistant', '1.0.0' #Swift 3
```
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ModelAssistant into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ssamadgh/ModelAssistant"
```

Run `carthage update --platform iOS` to build the framework and drag the built `ModelAssistant.framework` into your Xcode project.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ModelAssistant into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add ModelAssistant as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/ssamadgh/ModelAssistant.git
  ```

- Open the new `ModelAssistant` folder, and drag the `ModelAssistant.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `ModelAssistant.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `ModelAssistant.xcodeproj` folders each with a `ModelAssistant.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `ModelAssistant.framework`.


- And that's it!

  > The `ModelAssistant.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.
  

## FAQ

### What is the position of ModelAssistant in design patterns?
ModelAssistant is fully compatible with all kind of design patterns. It doesn't violate them, instead it finds its place and sit there!
As a guide the position of ModelAssistant in some of famous design patterns is as follows:

Design Pattern  | ModelAssistant Position
------------- | -------------
MVC | Controller
MVP  | Presenter
MVVM  | ViewModel
VIPER  | Presenter


## Credits

ModelAssistant is owned and maintained by the [Seyed Samad Gholamzadeh](http://ssamadgh@gmail.com). You can follow me on Twitter at [@ssamadgh](https://twitter.com/ssamadgh) for project updates and releases.

## License

ModelAssistant is released under the MIT license. [See LICENSE](https://github.com/ssamadgh/ModelAssistant/blob/master/LICENSE) for details.

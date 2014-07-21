iOS Data Client SDK
===================

The Data SDK requires iOS 6.0 or greater.


Data SDK Usage
--------------

For more information please visit the [docs site](https://github.com/cfmobile/docs-datasync-ios)


Building the SDK
----------------

Although you do not need any extra libraries or frameworks to build the project itself, you will need to modify your local Xcode installation in order to support building universal frameworks.  You will need to use the [iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) project in order to build this project. First ensure that XCode is closed, then clone the Universal Framework repository and run the `install.sh` script in the `Real Framework` subdirectory.

The source code of the project is divided into two separate projects:

 * MSSData - The redistributable portion of the framework.

 * MSSDataSpecs - This target produces an application that links against the MSSData source code directly and runs the unit tests.

	* Unit tests implemented using [Kiwi](https://github.com/kiwi-bdd/Kiwi).
	* Dependency management with [CocoaPods](http://cocoapods.org/).


Building the Framework
----------------------

The "MSSData" target produces a universal framework suitable for building against arm and simulator platforms.  This target depends on the [iOS Universal Framework](https://github.com/kstenerud/iOS-Universal-Framework) build system to produce this framework.

To build the framework, make sure the iOS Universal Framework is installed and load the MSSData project in Xcode.  Select the "MSSData" target and select "Archive" from the "Build" menu in Xcode.  After the project is built, Xcode should open a Finder window containing the resultant framework.

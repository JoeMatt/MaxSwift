# MaxSwift
Create a Cycling '74 Max external written in Swift

# Building
1. Modify MaxSwift/MaxSwift.modulemap include paths to your directory (bug workaround)
2. Customize MaxSwift.swift 
3. Build and run. 
4. Requires Max 6 or 7 being installed. Edit scheme -> Run -> Info -> Executable if Max app cannot be found.
5. build/maxswift.mxo can be used in your own Max patches after building


# TODO
+ Cleanup MaxSwift.swift. Break Max extensions into new files
+ Fix module map paths
+ Fix anymessage
+ Add inlet / outlet support
+ Add support for initialing any class by parameter

# WISHLIST
+ JIT compile Swift source

------
See ObjectiveMax for Objective-C https://github.com/pascal/ObjectiveMax

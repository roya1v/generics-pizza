#if canImport(UIKit)
import UIKit
public typealias ImageData = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias ImageData = NSImage
#else
#error("Not supported platform")
#endif

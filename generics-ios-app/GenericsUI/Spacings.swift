//
//  Spacings.swift
//  
//
//  Created by Mike S. on 14/05/2023.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public extension CGFloat {

    /// 2.0
    static var tiny: CGFloat {
        2.0
    }

    /// 4.0
    static var small: CGFloat {
        4.0
    }

    /// 8.0
    static var normal: CGFloat {
        8.0
    }

    /// 16.0
    static var big: CGFloat {
        16.0
    }

    /// 48.0
    static var huge: CGFloat {
        48.0
    }
}

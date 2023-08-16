//
//  TextField.swift
//  GenericsUIKit
//
//  Created by Mike S. on 16/08/2023.
//

import UIKit

public class TextField: UITextField {

    public init() {
        super.init(frame: .zero)

        borderStyle = .roundedRect
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

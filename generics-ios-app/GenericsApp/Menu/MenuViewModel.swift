//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation
import Factory

final class MenuViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var repository


}

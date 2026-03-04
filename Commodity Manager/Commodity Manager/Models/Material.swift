//
//  Materials.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI

struct Material: Identifiable, Hashable {

    let id = UUID()

    var name: String
    var store: String
    var price: String
    var quantity: String
    var image: UIImage?
}

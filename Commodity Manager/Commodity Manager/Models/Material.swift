//
//  Materials.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import Foundation

struct Material: Identifiable {
    let id = UUID()
    var name: String
    var storeName: String
    var quantity: String
    var price: String
}

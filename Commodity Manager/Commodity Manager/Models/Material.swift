//
//  Materials.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI
import Foundation

struct Material: Identifiable, Codable, Equatable, Hashable { //260422 수정

    // 기존: 생성 시각 정보 없음
    // let id = UUID()
    let id: UUID

    var name: String
    var store: String
    var price: String
    var quantity: String
    var image: UIImage?
    var color: MaterialColor //260422 수정

    // 추가: 타임스탬프
    var createdAt: Date
    var updatedAt: Date?

    // 단가 기능 제거됨: 기존 계산 프로퍼티 보존용 주석
    // var unitPrice: Double {
    //     let priceValue = Double(price) ?? 0
    //     let qtyValue = Double(quantity) ?? 1
    //     return qtyValue > 0 ? priceValue / qtyValue : priceValue
    // }

    // 명시적 이니셜라이저 추가 (기본값 포함)
    init(id: UUID = UUID(),
         name: String,
         store: String,
         price: String,
         quantity: String,
         image: UIImage? = nil,
         color: MaterialColor, //260422 수정
         createdAt: Date = Date(),
         updatedAt: Date? = Date()) {
        self.id = id
        self.name = name
        self.store = store
        self.price = price
        self.quantity = quantity
        self.image = image
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
//260422 수정
extension Material {

    enum CodingKeys: String, CodingKey {

        case id

        case name

        case store

        case price

        case quantity

        case color

        case createdAt

        case updatedAt

        // ❌ image 제외

    }

}
//260422 수정

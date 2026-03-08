//
//  Materials.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI

struct Material: Identifiable, Hashable {

    // 기존: 생성 시각 정보 없음
    // let id = UUID()
    let id: UUID

    var name: String
    var store: String
    var price: String
    var quantity: String
    var image: UIImage?
    var color: MaterialColor = .gray

    // 추가: 타임스탬프
    var createdAt: Date
    var updatedAt: Date?

    // 계산 프로퍼티: 단가 (가격/수량)
    // 수량이 0이거나 파싱 실패 시 분모를 1로 간주하여 방어적으로 계산합니다.
    var unitPrice: Double {
        let priceValue = Double(price) ?? 0
        let qtyValue = Double(quantity) ?? 1
        return qtyValue > 0 ? priceValue / qtyValue : priceValue
    }

    // 명시적 이니셜라이저 추가 (기본값 포함)
    init(id: UUID = UUID(),
         name: String,
         store: String,
         price: String,
         quantity: String,
         image: UIImage? = nil,
         color: MaterialColor = .gray,
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


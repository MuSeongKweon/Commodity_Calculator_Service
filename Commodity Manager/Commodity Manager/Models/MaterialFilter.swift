//
//  MaterialFilter.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//

import Foundation

enum FilterType: String, CaseIterable, Identifiable {

    case alphabetical = "가나다"
    case color = "색상"
    case newest = "최신"
    case oldest = "오래된"
    case quantity = "재고"
    case price = "단가"

    var id: String { rawValue }
}

//
//  MaterialSortHelper.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/11/26.
//

import Foundation

struct MaterialSortHelper {

    static func sortedMaterials(
        _ materials: [Material],
        selectedFilter: FilterType?,
        sortOrder: SortOrder
    ) -> [Material] {

        guard let selectedFilter else { return materials }

        switch selectedFilter {

        case .alphabetical:
            return materials.sorted {
                sortOrder == .asc
                ? $0.name < $1.name
                : $0.name > $1.name
            }

        case .quantity:
            return materials.sorted {
                let lhs = Int($0.quantity) ?? 0
                let rhs = Int($1.quantity) ?? 0

                return sortOrder == .asc
                ? lhs < rhs
                : lhs > rhs
            }

        case .price:
            return materials.sorted {
                let lhs = Int($0.price) ?? 0
                let rhs = Int($1.price) ?? 0

                return sortOrder == .asc
                ? lhs < rhs
                : lhs > rhs
            }

        case .color:
            return materials.sorted {
                ($0.image?.description ?? "") < ($1.image?.description ?? "")
            }

        case .time:
            return materials.sorted {
                let lhs = $0.updatedAt ?? $0.createdAt
                let rhs = $1.updatedAt ?? $1.createdAt
                return sortOrder == .asc ? (lhs < rhs) : (lhs > rhs)
            }
        }
    }
    static func isShortage(
        item: Material,
        selected: [UUID: Int]
    ) -> Bool {

        let selectedQty = selected[item.id, default: 0]
        let stock = Int(item.quantity) ?? 0

        return selectedQty > stock
    }
    static func shortageAmount(
        item: Material,
        selected: [UUID: Int]
    ) -> Int {

        let selectedQty = selected[item.id, default: 0]
        let stock = Int(item.quantity) ?? 0

        return max(0, selectedQty - stock)
    }
}


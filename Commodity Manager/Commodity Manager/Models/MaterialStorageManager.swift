//
//  MaterialStorageManager.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/23/26.
//

import SwiftUI

struct SavedMaterial: Codable, Identifiable {
    let id: UUID
    let name: String
    let store: String
    let price: String
    let quantity: String
    let imageData: Data?
    let color: MaterialColor
    let createdAt: Date
    let updatedAt: Date
}

final class MaterialStorageManager {
    static let shared = MaterialStorageManager()
    private init() {}
    private let key = "materials"
    // 저장
    func save(_ materials: [Material]) {
        let saved = materials.map { material in
            SavedMaterial(
                id: material.id,
                name: material.name,
                store: material.store,
                price: material.price,
                quantity: material.quantity,
                imageData: material.image?.jpegData(compressionQuality: 0.8),
                color: material.color,
                createdAt: material.createdAt,
                updatedAt: material.updatedAt ?? Date()
            )
        }
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    // 불러오기
    func load() -> [Material] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedMaterial].self, from: data)
        else { return [] }
        return decoded.map {
            Material(
                id: $0.id,
                name: $0.name,
                store: $0.store,
                price: $0.price,
                quantity: $0.quantity,
                image: $0.imageData.flatMap { UIImage(data: $0) },
                color: $0.color,
                createdAt: $0.createdAt,
                updatedAt: $0.updatedAt
            )
        }
    }
}

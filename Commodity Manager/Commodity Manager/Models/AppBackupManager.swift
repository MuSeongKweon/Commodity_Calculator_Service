//
//  AppBackupManager.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 5/2/26.
//

import Foundation
import SwiftUI
import UIKit

struct AppBackupFile: Codable {
    let backupVersion: Int
    let createdAt: Date
    let materials: [SavedMaterial]
    let colors: [SavedColorItem]
}

final class AppBackupManager {

    static let shared = AppBackupManager()

    private init() {}

    func makeJSONBackupData() throws -> Data {
        let materials = MaterialStorageManager.shared.load()
        let colors = ColorStorageManager.shared.load()

        let savedMaterials = materials.map { material in
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

        let savedColors = colors.map { item in
            SavedColorItem(
                id: item.id,
                red: item.materialColor.red,
                green: item.materialColor.green,
                blue: item.materialColor.blue,
                opacity: item.materialColor.opacity,
                name: item.materialColor.name
            )
        }

        let backup = AppBackupFile(
            backupVersion: 1,
            createdAt: Date(),
            materials: savedMaterials,
            colors: savedColors
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        return try encoder.encode(backup)
    }
    
    func restoreFromJSONBackupData(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(AppBackupFile.self, from: data)
        
        let materials = backup.materials.map { saved in
            Material(
                id: saved.id,
                name: saved.name,
                store: saved.store,
                price: saved.price,
                quantity: saved.quantity,
                image: saved.imageData.flatMap { UIImage(data: $0) },
                color: saved.color,
                createdAt: saved.createdAt,
                updatedAt: saved.updatedAt
            )
        }

        let colors = backup.colors.map { saved in
            let materialColor = MaterialColor(
                id: saved.id,
                name: saved.name,
                red: saved.red,
                green: saved.green,
                blue: saved.blue,
                opacity: saved.opacity
            )
            return UserColorItem(
                id: saved.id,
                materialColor: materialColor
            )
        }

        MaterialStorageManager.shared.save(materials)

        ColorStorageManager.shared.save(colors)

    }
}

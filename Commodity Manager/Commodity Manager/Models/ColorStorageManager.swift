//
//  ColorStorageManager.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/23/26.
//
import SwiftUI

// 저장용 모델

struct SavedColorItem: Codable, Identifiable {

    let id: UUID

    let red: Double

    let green: Double

    let blue: Double

    let opacity: Double

    let name: String

}

// 실제 앱 모델

struct UserColorItem: Identifiable, Equatable {

    let id: UUID

    var materialColor: MaterialColor
    
    //var name: String

}

final class ColorStorageManager {

    static let shared = ColorStorageManager()

    private init() {}

    private let key = "userColors"

    // ✅ 저장

    func save(_ items: [UserColorItem]) {

        let savedItems = items.map { item in

            SavedColorItem(

                id: item.id,

                red: item.materialColor.red,

                green: item.materialColor.green,

                blue: item.materialColor.blue,

                opacity: item.materialColor.opacity,

                name: item.materialColor.name

            )

        }

        if let data = try? JSONEncoder().encode(savedItems) {

            UserDefaults.standard.set(data, forKey: key)

        }

    }

    // ✅ 불러오기

    func load() -> [UserColorItem] {

        guard let data = UserDefaults.standard.data(forKey: key),

              let decoded = try? JSONDecoder().decode([SavedColorItem].self, from: data)

        else {

            return []

        }

        return decoded.map {

            let materialColor = MaterialColor(

                id: $0.id,

                name: $0.name,

                red: $0.red,

                green: $0.green,

                blue: $0.blue,

                opacity: $0.opacity

            )

            return UserColorItem(

                id: $0.id,

                materialColor: materialColor,
                
                //name: $0.name

            )

        }

    }

    // 삭제

    func clear() {

        UserDefaults.standard.removeObject(forKey: key)

    }

}

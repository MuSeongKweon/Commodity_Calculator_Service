//
//  MaterialColor.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//

import SwiftUI

enum MaterialColor: String, CaseIterable, Hashable {

    case gray
    case red
    case orange
    case yellow
    case green
    case blue

    var color: Color {

        switch self {

        case .gray:
            return Color.gray.opacity(0.2)

        case .red:
            return Color.red.opacity(0.25)

        case .orange:
            return Color.orange.opacity(0.25)

        case .yellow:
            return Color.yellow.opacity(0.25)

        case .green:
            return Color.green.opacity(0.25)

        case .blue:
            return Color.blue.opacity(0.25)
        }
    }
}

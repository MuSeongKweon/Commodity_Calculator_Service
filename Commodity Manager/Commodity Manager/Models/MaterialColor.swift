//
//  MaterialColor.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//
/*
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
 */
import SwiftUI
//260422 수정
struct MaterialColor: Identifiable, Codable, Equatable, Hashable {

    // MARK: - Properties

    let id: UUID

    var name: String

    var red: Double

    var green: Double

    var blue: Double

    var opacity: Double

    // MARK: - Init

    init(

        id: UUID = UUID(),

        name: String,

        red: Double,

        green: Double,

        blue: Double,

        opacity: Double = 1.0

    ) {

        self.id = id

        self.name = name

        self.red = red

        self.green = green

        self.blue = blue

        self.opacity = opacity

    }

    // MARK: - SwiftUI Color 변환

    var color: Color {

        Color(

            .sRGB,

            red: red,

            green: green,

            blue: blue,

            opacity: opacity

        )

    }

}

extension MaterialColor {

    static func from(color: Color, name: String = "Custom") -> MaterialColor {

        #if os(iOS)

        let uiColor = UIColor(color)

        var r: CGFloat = 0

        var g: CGFloat = 0

        var b: CGFloat = 0

        var a: CGFloat = 0

        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return MaterialColor(

            name: name,

            red: Double(r),

            green: Double(g),

            blue: Double(b),

            opacity: Double(a)

        )

        #else

        return MaterialColor(name: name, red: 0, green: 0, blue: 0)

        #endif

    }

}

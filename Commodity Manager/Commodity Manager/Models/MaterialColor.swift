//
//  MaterialColor.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//
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
    //선택된 색상의 명도/상대 휘도 계산 기능 추가
    //글자색을 .black 또는 .white로 자동 판단하는 프로퍼티 추가
    private var relativeLuminance: Double {

            func linearized(_ value: Double) -> Double {

                if value <= 0.03928 {

                    return value / 12.92

                } else {

                    return pow((value + 0.055) / 1.055, 2.4)

                }

            }

            let r = linearized(red)

            let g = linearized(green)

            let b = linearized(blue)

            return 0.2126 * r + 0.7152 * g + 0.0722 * b

        }

        var readableTextColor: Color {

            let luminance = relativeLuminance

            let contrastWithBlack = (luminance + 0.05) / 0.05

            let contrastWithWhite = 1.05 / (luminance + 0.05)

            return contrastWithBlack >= contrastWithWhite ? .black : .white

        }

        var readableSecondaryTextColor: Color {

            readableTextColor.opacity(0.75)

        }

}

//
//  Untitled.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MaterialCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 80)
                .cornerRadius(8)

            Text("재료 이름")
                .font(.headline)

            Text("구매처")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("남은 수량: 100g")
                .font(.caption)

            Text("단가: 1,000원")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

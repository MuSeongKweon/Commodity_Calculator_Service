//
//  Untitled.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MaterialCardView: View {
    
    var name: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

            // ← 여기에 커서 표시(아이콘) 추가
            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.7))
                .padding(8)
        }
    }
}

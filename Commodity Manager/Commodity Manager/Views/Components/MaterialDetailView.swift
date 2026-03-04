//
//  MaterialDetailView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MaterialDetailView: View {
    var index: Int

    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .cornerRadius(12)

            Text("재료 이름")
                .font(.largeTitle)

            Text("구매처: ABC 상회")
                .font(.title3)
                .foregroundColor(.gray)

            Text("총 가격: 10,000원")
                .font(.title2)

            Text("남은 수량: 500g")
                .font(.title2)

            Spacer()
        }
        .padding()
        .navigationTitle("상세정보")
    }
}

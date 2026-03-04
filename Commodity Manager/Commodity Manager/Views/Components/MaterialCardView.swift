//
//  MaterialCardView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//  Filter again at 3/5/26

import SwiftUI

struct MaterialCardView: View {

    var material: Material

    var body: some View {

        VStack(alignment: .leading, spacing: 6){

            // 사진
            if let image = material.image {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height:80)
                    .clipped()
                    .cornerRadius(8)

            } else {

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height:80)
                    .cornerRadius(8)
            }

            // 재료 이름
            Text(material.name)
                .font(.headline)

            // 구매처
            Text("구매처: \(material.store)")
                .font(.caption)
                .foregroundColor(.secondary)

            // 가격
            Text("가격: \(material.price)")
                .font(.caption)

            // 수량
            Text("수량: \(material.quantity)")
                .font(.caption)
        }

        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius:2)
    }
}

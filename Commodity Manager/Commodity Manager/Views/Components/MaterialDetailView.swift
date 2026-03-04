//
//  MaterialDetailView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MaterialDetailView: View {

    var material: Material

    var body: some View {

        ScrollView {

            VStack(spacing:20) {

                if let image = material.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height:200)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height:200)
                        .cornerRadius(12)
                }

                VStack(alignment:.leading, spacing:12) {

                    HStack {
                        Text("재료 이름")
                        Spacer()
                        Text(material.name)
                    }

                    HStack {
                        Text("구매 가게")
                        Spacer()
                        Text(material.store)
                    }

                    HStack {
                        Text("가격")
                        Spacer()
                        Text(material.price)
                    }

                    HStack {
                        Text("수량")
                        Spacer()
                        Text(material.quantity)
                    }
                }
                .font(.title3)
                .padding()

                Spacer()
            }
            .padding()
        }
        .navigationTitle("재료 상세")
    }
}

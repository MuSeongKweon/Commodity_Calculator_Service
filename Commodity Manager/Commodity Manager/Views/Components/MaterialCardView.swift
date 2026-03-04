//
//  Untitled.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MaterialCardView: View {

    var name: String
    var image: UIImage?

    var body: some View {

        VStack(alignment: .leading){

            if let image {

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

            Text(name)
                .font(.headline)

            Text("구매처")
                .font(.caption)

            Text("남은 수량: 100")
                .font(.caption)
        }

        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius:2)
    }
}

//
//  SearchBar.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("검색...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: { text = "" }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

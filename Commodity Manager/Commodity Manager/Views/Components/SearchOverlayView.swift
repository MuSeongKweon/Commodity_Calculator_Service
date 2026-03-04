//
//  SearchBar.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI

struct SearchOverlayView: View {

    @Binding var searchText: String
    @Binding var isSearching: Bool

    var body: some View {

        VStack {
            HStack {
                TextField("검색", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("취소") {
                    searchText = ""
                    isSearching = false
                }
            }
            .padding()

            Spacer()
        }
        .background(Color.black.opacity(0.35))
        .ignoresSafeArea()
    }
}

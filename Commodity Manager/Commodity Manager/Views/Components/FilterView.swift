//
//  FilterView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//

import SwiftUI

struct FilterView: View {

    @Binding var selectedFilter: FilterType?
    @Environment(\.dismiss) var dismiss

    var body: some View {

        NavigationView {

            List {

                ForEach(FilterType.allCases) { filter in

                    Button {

                        if selectedFilter == filter {
                            selectedFilter = nil
                        } else {
                            selectedFilter = filter
                        }

                    } label: {

                        HStack {

                            Text(filter.rawValue)

                            Spacer()

                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("필터")
        }
    }
}

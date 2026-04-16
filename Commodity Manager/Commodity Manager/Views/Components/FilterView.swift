//
//  FilterView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/5/26.
//

import SwiftUI

struct FilterView: View {
    
    @Binding var selectedFilter: FilterType?
    @Binding var sortOrder: SortOrder //추가
    var hideColorOption: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            
            List {
                // 🔴 1️⃣ 정렬 방향 (여기에 넣는다)
                Section(header: Text("정렬 방향")) {
                    
                    Button {
                        
                        sortOrder = sortOrder == .asc ? .desc : .asc
                        
                    } label: {
                        
                        HStack {
                            Text(sortOrder == .asc ? "오름차순" : "내림차순")
                            Spacer()
                            Image(systemName: sortOrder == .asc ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                // 🔴 2️⃣ 기존 필터 리스트
                Section(header: Text("필터")) {
                    ForEach((hideColorOption ? FilterType.allCases.filter { $0 != .color } : FilterType.allCases)) { filter in
                        
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
}


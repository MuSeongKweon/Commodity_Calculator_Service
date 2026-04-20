//
//  ColorFilteredListView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/8/26.
//

import SwiftUI

struct ColorFilteredListView: View {

    let color: MaterialColor
    @Binding var materials: [Material]

    @State private var showAddView = false

    // 🔴 편집 상태
    @State private var isEditing = false
    @State private var selectedItems = Set<UUID>()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {

                ScrollView {
                    Color.clear
                        .frame(height: 0.1)
                        .id("top")
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        ForEach(materials.filter { $0.color == color }) { item in
                            
                            if let index = materials.firstIndex(where: { $0.id == item.id }) {
                                
                                NavigationLink {
                                    
                                    MaterialDetailView(material: $materials[index])
                                    
                                } label: {
                                    
                                    ZStack(alignment: .topTrailing) {
                                        
                                        MaterialCardView(material: item)
                                        
                                        // 🔴 선택 체크 UI
                                        if isEditing {
                                            
                                            Button {
                                                
                                                if selectedItems.contains(item.id) {
                                                    selectedItems.remove(item.id)
                                                } else {
                                                    selectedItems.insert(item.id)
                                                }
                                                
                                            } label: {
                                                
                                                Image(systemName:
                                                        selectedItems.contains(item.id)
                                                      ? "checkmark.circle.fill"
                                                      : "circle")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .padding(6)
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }

                ScrollToTopOverlay(
                    action: {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    },
                    bottomPadding: 16,
                    trailingPadding: 16,
                    size: 56,
                    backgroundColor: .white,
                    iconColor: .gray,
                    systemImageName: "arrow.up.circle.fill"
                )
            }
        }
        .navigationTitle(color.displayName)

        // 🔴 상단 편집 버튼
        .toolbar {

            ToolbarItemGroup(placement: .navigationBarTrailing) {

                Button {

                    isEditing.toggle()
                    selectedItems.removeAll()

                } label: {
                    Image(systemName: "square.and.pencil")
                }
                if isEditing {
                    Button {
                        materials.removeAll { selectedItems.contains($0.id) }
                        selectedItems.removeAll()
                        isEditing = false
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                // 추가
                Button {
                    showAddView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        // 🔴 추가 화면
        .sheet(isPresented: $showAddView) {
            AddMaterialView(materials: $materials)
        }
    }
}

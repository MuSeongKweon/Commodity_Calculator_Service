//
//  MaterialCalculatorView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/9/26.
//

import SwiftUI

struct MaterialCalculatorView: View {

    @Binding var materials: [Material]
    @State private var selectedColorFilter: MaterialColor? = nil

    // 선택된 카드 + 사용 수량
    @State private var selected: [UUID: Int] = [:]
    @State private var selectedFilter: FilterType? //필터 선택 관련
    @State private var sortOrder: SortOrder = .asc //오름차순 내림차순 관련
    @State private var showFilter = false //필터 접근 관련
    
    func increase(_ item: Material) {
        selected[item.id, default: 0] += 1
    }

    func decrease(_ item: Material) {
        if selected[item.id, default: 0] > 0 {
            selected[item.id, default: 0] -= 1
        }
    }
    
    var filteredMaterials: [Material] {
        MaterialSortHelper.sortedMaterials(
            materials,
            selectedFilter: selectedFilter,
            sortOrder: sortOrder
        )
    }
    
    // 색상 그룹 생성 (계산기에서도 색상 그룹 화면을 사용할 때 필요)
    var groupedMaterials: [MaterialColor: [Material]] {
        Dictionary(grouping: materials) { $0.color }
    }
    
    func isShortage(_ item: Material) -> Bool {

        let selectedQty = selected[item.id, default: 0]
        let stock = Int(item.quantity) ?? 0

        return selectedQty > stock
    }
    
    func shortageAmount(_ item: Material) -> Int {

        let selectedQty = selected[item.id, default: 0]
        let stock = Int(item.quantity) ?? 0

        return selectedQty - stock
    }
    
    
    var body: some View {

        VStack {

            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            if selectedFilter == .color {
                // 색상 필터 선택 시: 색상 그룹 화면으로 전환
                CalculatorColorGroupsView(
                    groups: groupedMaterials,
                    materials: $materials,
                    selectedQuantities: $selected
                )
                .padding()
            } else {
                ScrollView {

                    LazyVGrid(columns: columns, spacing: 16) {

                        ForEach(filteredMaterials) { item in

                            VStack {

                                MaterialCardView(material: item)

                                HStack {

                                    Button { decrease(item) } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .disabled((selected[item.id] ?? 0) == 0)

                                    Text("\(selected[item.id, default: 0])")

                                    Button { increase(item) } label: {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                // 🔴 부족 수량 표시
                                if isShortage(item) {

                                    Text("재고 부족: \(shortageAmount(item))개 부족")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

            // 🔴 총액 표시
            if selectedFilter != .color {
                VStack(spacing: 12) {
                    
                    Text("총액")
                        .font(.headline)
                    
                    Text("₩ \(totalPrice)")
                        .font(.title)
                        .bold()
                    
                    // 🔴 저장 버튼 (현재는 동작 X)
                    Button {
                        
                        // TODO: 엑셀 저장 (추후 구현)
                        
                    } label: {
                        
                        Text("저장")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("원자재 계산")
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilter = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterView(
                selectedFilter: $selectedFilter,
                sortOrder: $sortOrder
            )
        }
    }

    // 🔴 총액 계산 로직
    var totalPrice: Int {

        materials.reduce(0) { result, item in

            let quantity = selected[item.id, default: 0]
            let price = Int(item.price) ?? 0

            return result + (price * quantity)
        }
    }
}

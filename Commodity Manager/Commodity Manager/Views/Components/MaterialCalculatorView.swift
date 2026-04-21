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

    @State private var isSearching: Bool = false
    @State private var searchText: String = ""

    func increase(_ item: Material) {
        selected[item.id, default: 0] += 1
    }

    func decrease(_ item: Material) {
        if selected[item.id, default: 0] > 0 {
            selected[item.id, default: 0] -= 1
        }
    }

    // 선택 수량 전체 초기화
    func resetSelection() {
        selected.removeAll()
    }
    
    var filteredMaterials: [Material] {
        let searched = searchText.isEmpty ? materials : materials.filter { m in
            m.name.localizedCaseInsensitiveContains(searchText) ||
            m.store.localizedCaseInsensitiveContains(searchText) ||
            m.price.localizedCaseInsensitiveContains(searchText) ||
            m.quantity.localizedCaseInsensitiveContains(searchText)
        }
        return MaterialSortHelper.sortedMaterials(
            searched,
            selectedFilter: selectedFilter,
            sortOrder: sortOrder
        )
    }
    
    // 선택 수량이 있는 항목을 상단으로 정렬 (기존 필터/정렬 결과는 그룹 내에서 유지)
    var prioritizedMaterials: [Material] {
        // 안정적인 정렬을 위해, 현재 필터/정렬 결과를 기준으로 그룹화 후 병합
        let selectedItems = filteredMaterials.filter { (selected[$0.id] ?? 0) > 0 }
        let unselectedItems = filteredMaterials.filter { (selected[$0.id] ?? 0) == 0 }
        return selectedItems + unselectedItems
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
        ScrollViewReader { proxy in
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
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView {
                            Color.clear
                                .frame(height: 0.1)
                                .id("top")

                            LazyVGrid(columns: columns, spacing: 16) {

                                ForEach(prioritizedMaterials) { item in

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

                        ScrollToTopOverlay(
                            action: {
                                withAnimation(.easeInOut) {
                                    // Without ScrollViewReader here, we cannot call proxy. Keep placeholder for future integration.
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

                // 🔴 총액 표시
                if selectedFilter != .color {
                    VStack(spacing: 12) {
                        
                        Text("총액")
                            .font(.headline)
                        
                        Text("₩ \(formattedTotalPrice)")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { isSearching = true }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    resetSelection()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .accessibilityLabel("선택 초기화")
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterView(
                selectedFilter: $selectedFilter,
                sortOrder: $sortOrder
            )
        }
        .overlay(
            Group {
                if isSearching {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isSearching = false }
                        }
                    VStack {
                        HStack {
                            TextField("재료 검색", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("취소") {
                                searchText = ""
                                withAnimation { isSearching = false }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding()
                        Spacer()
                    }
                }
            }
        )
    }

    // 🔴 총액 계산 로직 (소수 단가 지원)
    var totalPrice: Double {
        materials.reduce(0.0) { result, item in
            let quantity = Double(selected[item.id, default: 0])
            let price = Double(item.price) ?? 0.0
            return result + (price * quantity)
        }
    }

    // 🔴 총액 표시 포맷 (소수점 최대 2자리, 불필요한 0 제거)
    private var formattedTotalPrice: String {
        let value = totalPrice
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}


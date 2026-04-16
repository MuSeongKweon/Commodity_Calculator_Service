import SwiftUI

struct CalculatorColorFilteredListView: View {

    let color: MaterialColor
    @Binding var materials: [Material]
    @Binding var selectedQuantities: [UUID: Int]

    @State private var selectedFilter: FilterType? = nil
    @State private var sortOrder: SortOrder = .asc
    @State private var showFilter: Bool = false

    @State private var isSearching: Bool = false
    @State private var searchText: String = ""

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private func increase(_ item: Material) {
        selectedQuantities[item.id, default: 0] += 1
    }

    private func decrease(_ item: Material) {
        if selectedQuantities[item.id, default: 0] > 0 {
            selectedQuantities[item.id, default: 0] -= 1
        }
    }

    // 선택 수량 전체 초기화
    private func resetSelection() {
        selectedQuantities.removeAll()
    }

    // 현재 화면(선택한 색상)의 총액 계산
    private var totalPrice: Int {
        materials.filter { $0.color == color }.reduce(0) { result, item in
            let qty = selectedQuantities[item.id, default: 0]
            let price = Int(item.price) ?? 0
            return result + (qty * price)
        }
    }

    // 현재 색상 범위 내에서 필터/정렬 적용
    private var filteredMaterials: [Material] {
        let colorScoped = materials.filter { $0.color == color }
        let searched = searchText.isEmpty ? colorScoped : colorScoped.filter { material in
            material.name.localizedCaseInsensitiveContains(searchText) ||
            material.store.localizedCaseInsensitiveContains(searchText) ||
            material.price.localizedCaseInsensitiveContains(searchText) ||
            material.quantity.localizedCaseInsensitiveContains(searchText)
        }
        return MaterialSortHelper.sortedMaterials(
            searched,
            selectedFilter: selectedFilter,
            sortOrder: sortOrder
        )
    }

    // 현재 색상에 해당하는 항목 중 선택 수량이 있는 항목을 상단으로 배치
    private var prioritizedItems: [Material] {
        let selectedItems = filteredMaterials.filter { (selectedQuantities[$0.id] ?? 0) > 0 }
        let unselectedItems = filteredMaterials.filter { (selectedQuantities[$0.id] ?? 0) == 0 }
        return selectedItems + unselectedItems
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(prioritizedItems) { item in
                    VStack {
                        MaterialCardView(material: item)
                        HStack {
                            Button { decrease(item) } label: {
                                Image(systemName: "minus.circle")
                            }
                            .disabled((selectedQuantities[item.id] ?? 0) == 0)

                            Text("\(selectedQuantities[item.id, default: 0])")

                            Button { increase(item) } label: {
                                Image(systemName: "plus.circle")
                            }
                        }
                        // 🔴 부족 수량 표시
                        if MaterialSortHelper.isShortage(
                            item: item,
                            selected: selectedQuantities
                        ) {
                            Text("재고 부족: \(MaterialSortHelper.shortageAmount(item: item, selected: selectedQuantities))개")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 160)
        }
        .navigationTitle(color.displayName)
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
                sortOrder: $sortOrder,
                hideColorOption: true
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
        if isSearching != true {
            // 하단 합계 + 저장 UI (MaterialCalculatorView와 동일한 형식)
            VStack(spacing: 12) {
                Text("총액")
                    .font(.headline)
                
                Text("₩ \(totalPrice)")
                    .font(.title)
                    .bold()
                
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

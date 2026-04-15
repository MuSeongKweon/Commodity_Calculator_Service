import SwiftUI

struct CalculatorColorFilteredListView: View {

    let color: MaterialColor
    @Binding var materials: [Material]
    @Binding var selectedQuantities: [UUID: Int]

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

    // 현재 화면(선택한 색상)의 총액 계산
    private var totalPrice: Int {
        materials.filter { $0.color == color }.reduce(0) { result, item in
            let qty = selectedQuantities[item.id, default: 0]
            let price = Int(item.price) ?? 0
            return result + (qty * price)
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(materials.filter { $0.color == color }) { item in
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

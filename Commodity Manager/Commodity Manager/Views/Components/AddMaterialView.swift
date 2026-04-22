//
//  AddMaterialView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//  Filter again at Git 3/5/26

import SwiftUI
import PhotosUI

// 사용자 정의 색상 아이템 (색상 + 이름)
fileprivate struct UserColorItem: Identifiable, Equatable {
    let id = UUID()
    var color: Color
    var name: String
}

struct AddMaterialView: View {

    @Environment(\.dismiss) var dismiss

    @Binding var materials: [Material]

    @State private var materialName = ""
    @State private var storeName = ""
    @State private var price = ""
    @State private var quantity = ""

    @State private var isPriceValid: Bool = true
    @State private var isQuantityValid: Bool = true

    private var isFormValid: Bool {
        // price allows decimal numbers; allow 0 and 0.x, but disallow other leading zeros like 01 or 00.5
        let priceIsNumber = Double(price) != nil
        let priceHasValidLeading: Bool = {
            if price == "0" { return true }
            if price.hasPrefix("0.") { return true }
            return !price.hasPrefix("0")
        }()
        // quantity allows integers; allow 0, but disallow other leading zeros like 01
        let quantityIsInt = Int(quantity) != nil
        let quantityHasValidLeading: Bool = {
            if quantity == "0" { return true }
            return !quantity.hasPrefix("0")
        }()
        return !materialName.isEmpty && priceIsNumber && priceHasValidLeading && quantityIsInt && quantityHasValidLeading
    }

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    
    
    // 색상 관련
    @State private var selectedColor: MaterialColor = MaterialColor(name: "Custom", red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
    
    // 사용자 추가 색상들 (최대 20개)
    @State private var userColorItems: [UserColorItem] = []
    @State private var selectedCustomColor: UserColorItem? = nil
    
    @State private var showingColorPicker: Bool = false
    @State private var tempPickedColor: Color = .gray
    @State private var showingEditSheet: Bool = false
    
    @State private var tempPickedName: String = ""
    @State private var isDeleteMode: Bool = false
    @State private var selectionForDelete: Set<UUID> = []
    @State private var isEditNameMode: Bool = false

    var body: some View {

        NavigationView{

            ScrollView{

                VStack(spacing:20){

                    // 사진 선택
                    PhotosPicker(selection:$selectedItem,
                                 matching:.images){

                        if let selectedImage{
                            selectedImage
                                .resizable()
                                .scaledToFit()
                                .frame(height:150)
                        }else{
                            VStack{
                                Image(systemName:"photo")
                                    .font(.largeTitle)
                                Text("사진 추가")
                            }
                            .frame(height:150)
                        }
                    }
                    .onChange(of: selectedItem) { oldValue, newValue in
                        guard let newItem = newValue else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedUIImage = uiImage
                                selectedImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                    
                    // 색상 선택 UI (1번째: 사용자 직접 선택, 2~6번째: 사용자 색상 리스트 스크롤, 7번째: 편집)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("카드 색상")
                            .font(.headline)

                        HStack(spacing: 12) {
                            // 1) 사용자 직접 선택
                            Button {
                                // 현재 선택 미리보기는 tempPickedColor로 표시
                                tempPickedColor = selectedCustomColor?.color ?? .gray
                                tempPickedName = selectedCustomColor?.name ?? ""
                                showingColorPicker = true
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedCustomColor?.color ?? tempPickedColor)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.secondary, lineWidth: 1)
                                            )
                                        Image(systemName: "plus")
                                            .foregroundStyle(.white)
                                    }
                                    Text("직접선택")
                                        .font(.caption2)
                                }
                            }
                            .buttonStyle(.plain)
                            .sheet(isPresented: $showingColorPicker) {
                                VStack(spacing: 16) {
                                    Text("색상 선택")
                                        .font(.headline)
                                    ColorPicker("색상", selection: $tempPickedColor, supportsOpacity: true)
                                        .padding()

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("색상 이름")
                                            .font(.subheadline)
                                        TextField("예: 민트, 라이트 블루", text: $tempPickedName)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    .padding(.horizontal)

                                    HStack {
                                        Button("취소") {
                                            tempPickedName = ""
                                            showingColorPicker = false
                                        }
                                        Spacer()
                                        Button("추가") {
                                            // 선택된 색상을 이름과 함께 저장 (최대 20개)
                                            let name = tempPickedName.trimmingCharacters(in: .whitespacesAndNewlines)
                                            let finalName = name.isEmpty ? "사용자 색상 \(userColorItems.count + 1)" : name
                                            if userColorItems.count < 20 {
                                                let item = UserColorItem(color: tempPickedColor, name: finalName)
                                                userColorItems.append(item)
                                                selectedCustomColor = item
                                                selectedColor = MaterialColor.from(color: item.color, name: item.name)
                                            } else {
                                                // 용량 초과 시 선택만 갱신
                                                selectedCustomColor = UserColorItem(color: tempPickedColor, name: finalName)
                                                selectedColor = MaterialColor.from(color: tempPickedColor, name: finalName)
                                            }
                                            tempPickedName = ""
                                            showingColorPicker = false
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .presentationDetents([.medium])
                                .padding()
                            }

                            // 2)~6) 사용자 색상 리스트 (좌우 스크롤, 최대 20개를 스크롤로 접근)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(userColorItems) { item in
                                        Button {
                                            selectedCustomColor = item
                                        } label: {
                                            VStack(spacing: 4) {
                                                Circle()
                                                    .fill(item.color)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Circle()
                                                            .stroke((selectedCustomColor == item) ? Color.black : Color.primary.opacity(0.2), lineWidth: (selectedCustomColor == item) ? 3 : 1)
                                                    )
                                                Text(item.name)
                                                    .font(.caption2)
                                                    .lineLimit(1)
                                                    .frame(width: 52)
                                            }
                                            .padding(.vertical, 4)
                                            .frame(height: 64, alignment: .top)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(Text(item.name))
                                    }
                                }
                                .frame(height: 64)
                            }
                            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)

                            // 7) 편집 버튼 (추가된 색상 삭제)
                            Button {
                                showingEditSheet = true
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.secondary, lineWidth: 1)
                                            )
                                        Image(systemName: "slider.horizontal.3")
                                            .foregroundStyle(.primary)
                                    }
                                    Text("편집")
                                        .font(.caption2)
                                }
                            }
                            .buttonStyle(.plain)
                            .sheet(isPresented: $showingEditSheet) {
                                NavigationView {
                                    List {
                                        if userColorItems.isEmpty {
                                            Text("추가된 색상이 없습니다.")
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Section(header: Text("추가된 색상")) {
                                                ForEach($userColorItems) { $item in
                                                    HStack(spacing: 12) {
                                                        Circle()
                                                            .fill(item.color)
                                                            .frame(width: 24, height: 24)
                                                        if isDeleteMode {
                                                            // 삭제 모드: 선택 체크박스
                                                            Button {
                                                                if selectionForDelete.contains(item.id) {
                                                                    selectionForDelete.remove(item.id)
                                                                } else {
                                                                    selectionForDelete.insert(item.id)
                                                                }
                                                            } label: {
                                                                Image(systemName: selectionForDelete.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                            }
                                                        }
                                                        if isEditNameMode {
                                                            TextField("색상 이름", text: $item.name)
                                                                .textFieldStyle(.roundedBorder)
                                                        } else {
                                                            Text(item.name)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .navigationTitle("색상 편집")
                                    .toolbar {
                                        ToolbarItem(placement: .topBarLeading) {
                                            Button(isDeleteMode ? "취소" : "삭제") {
                                                isDeleteMode.toggle()
                                                if isDeleteMode { isEditNameMode = false }
                                                if !isDeleteMode { selectionForDelete.removeAll() }
                                            }
                                        }
                                        ToolbarItem(placement: .topBarTrailing) {
                                            HStack(spacing: 16) {
                                                if isDeleteMode {
                                                    Button("전체선택") {
                                                        selectionForDelete = Set(userColorItems.map { $0.id })
                                                    }
                                                    Button("삭제", role: .destructive) {
                                                        let ids = selectionForDelete
                                                        userColorItems.removeAll { ids.contains($0.id) }
                                                        if let selected = selectedCustomColor, ids.contains(selected.id) {
                                                            selectedCustomColor = nil
                                                        }
                                                        selectionForDelete.removeAll()
                                                        isDeleteMode = false
                                                    }
                                                } else {
                                                    Button(isEditNameMode ? "완료" : "수정") {
                                                        isEditNameMode.toggle()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onChange(of: showingEditSheet) { oldValue, newValue in
                                if newValue == false {
                                    // 편집 시트가 닫힐 때 편집 상태 초기화
                                    isEditNameMode = false
                                    isDeleteMode = false
                                    selectionForDelete.removeAll()
                                }
                            }
                        }
                    }
                    .onChange(of: selectedCustomColor) { oldValue, newValue in
                        if let newValue = newValue {
                            selectedColor = MaterialColor.from(color: newValue.color, name: newValue.name)
                        }
                    }

                    // 재료 이름
                    TextField("재료 이름", text:$materialName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 가게 이름
                    TextField("구매처", text:$storeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 가격 (단가)
                    TextField("가격", text:$price)
                        .keyboardType(.decimalPad)
                        .onChange(of: price) { oldValue, newValue in
                            let numeric = Double(newValue) != nil
                            let leadingOK: Bool = {
                                if newValue == "0" { return true }
                                if newValue.hasPrefix("0.") { return true }
                                return !newValue.hasPrefix("0")
                            }()
                            isPriceValid = numeric && leadingOK
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isPriceValid {
                        Text("숫자만 입력하고 선행 0은 금지됩니다 (0, 0.5 허용 / 01, 00.5 불가)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // 수량 (재고)
                    TextField("수량", text:$quantity)
                        .keyboardType(.numberPad)
                        .onChange(of: quantity) { oldValue, newValue in
                            let numeric = Int(newValue) != nil
                            let leadingOK: Bool = {
                                if newValue == "0" { return true }
                                return !newValue.hasPrefix("0")
                            }()
                            isQuantityValid = numeric && leadingOK
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isQuantityValid {
                        Text("정수만 입력하고 선행 0은 금지됩니다 (0, 1, 10 허용 / 01 불가)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // 생성 버튼
                    Button(action:{

                        // 최종 유효성 검사: 숫자 이외 입력 시 생성 불가
                        let priceNumeric = Double(price) != nil
                        let priceLeadingOK: Bool = {
                            if price == "0" { return true }
                            if price.hasPrefix("0.") { return true }
                            return !price.hasPrefix("0")
                        }()
                        isPriceValid = priceNumeric && priceLeadingOK
                        let qtyNumeric = Int(quantity) != nil
                        let qtyLeadingOK: Bool = {
                            if quantity == "0" { return true }
                            return !quantity.hasPrefix("0")
                        }()
                        isQuantityValid = qtyNumeric && qtyLeadingOK
                        guard isFormValid else { return }

                        if !materialName.isEmpty {
                            let now = Date()
                            let newMaterial = Material(
                                name: materialName,
                                store: storeName,
                                price: price,
                                quantity: quantity,
                                image: selectedUIImage,
                                color: selectedColor,
                                createdAt: now,
                                updatedAt: now
                            )
                            materials.append(newMaterial)
                            dismiss()
                        }

                    }){
                        Text("생성")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth:.infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)

                }
                .padding()
            }
            .navigationTitle("재료 추가")
        }
    }
}


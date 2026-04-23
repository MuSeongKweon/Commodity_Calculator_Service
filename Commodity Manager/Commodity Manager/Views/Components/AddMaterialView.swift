//
//  AddMaterialView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//  Filter again at Git 3/5/26

import SwiftUI
import PhotosUI

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
                    
                    ColorPickerSectionView(selectedColor: $selectedColor)

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
                            MaterialStorageManager.shared.save(materials) // 🔴 재료 카드 추가 시 저장
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

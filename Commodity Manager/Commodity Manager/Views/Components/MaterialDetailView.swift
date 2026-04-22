//
//  MaterialDetailView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//  Filter again in git 3/5/26

import SwiftUI
import PhotosUI

struct MaterialDetailView: View {

//    var material: Material
    @Binding var material: Material

    // 편집 상태 및 편집용 필드
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedStore: String = ""
    @State private var editedPrice: String = ""
    @State private var editedQuantity: String = ""
    @State private var editedImage: UIImage? = nil
    @State private var showImagePicker = false
    // 🔴 PhotosPicker 상태
    @State private var selectedItem: PhotosPickerItem?
    
    //❗️색상 편집 추가
    @State private var editedColor: MaterialColor = MaterialColor(name: "Custom", red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)

    @State private var isEditedPriceValid: Bool = true
    @State private var isEditedQuantityValid: Bool = true

    private var isEditFormValid: Bool {
        let priceIsNumber = Double(editedPrice) != nil
        // allow "0" and "0.xxx", but disallow other leading zeros like "01", "00.5"
        let priceHasValidLeading: Bool = {
            if editedPrice == "0" { return true }
            if editedPrice.hasPrefix("0.") { return true }
            return !editedPrice.hasPrefix("0")
        }()
        let quantityIsInt = Int(editedQuantity) != nil
        // allow "0", but disallow other leading zeros like "01"
        let quantityHasValidLeading: Bool = {
            if editedQuantity == "0" { return true }
            return !editedQuantity.hasPrefix("0")
        }()
        return priceIsNumber && priceHasValidLeading && quantityIsInt && quantityHasValidLeading
    }
    

    var body: some View {

        ScrollView {

            VStack(spacing:20) {

                if isEditing {
                    if let image = editedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height:200)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height:200)
                            .cornerRadius(12)
                    }
                    HStack {
                        // 기존: 수동 시트 토글 방식 (주석 처리)
                        // Button("사진 변경") { showImagePicker = true }
                        // 새 구현: PhotosPicker 사용
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("사진 변경")
                        }
                        Spacer()
                        Button("사진 제거") { editedImage = nil }
                    }
                } else {
                    if let image = material.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height:200)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height:200)
                            .cornerRadius(12)
                    }
                }
                
                //❗️색상 편집 추가
                if isEditing {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("카드 색상")
                            .font(.headline)

                        // 현재 색상 미리보기와 ColorPicker
                        HStack(spacing: 12) {
                            Circle()
                                .fill(editedColor.color)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.secondary, lineWidth: 1))
                            ColorPicker("색상 선택", selection: Binding(
                                get: { editedColor.color },
                                set: { newColor in
                                    let mc = MaterialColor.from(color: newColor, name: editedColor.name)
                                    editedColor = mc
                                }
                            ), supportsOpacity: true)
                        }
                    }
                    .padding(.horizontal)
                }

                if isEditing {
                    VStack(alignment:.leading, spacing:12) {
                        HStack {
                            Text("재료 이름")
                            Spacer()
                            TextField("이름", text: $editedName)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("구매 가게")
                            Spacer()
                            TextField("가게", text: $editedStore)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("가격")
                            Spacer()
                            TextField("가격", text: $editedPrice)
                                .keyboardType(.decimalPad)
                                .onChange(of: editedPrice) { oldValue, newValue in
                                    let numeric = Double(newValue) != nil
                                    let leadingOK: Bool = {
                                        if newValue == "0" { return true }
                                        if newValue.hasPrefix("0.") { return true }
                                        return !newValue.hasPrefix("0")
                                    }()
                                    isEditedPriceValid = numeric && leadingOK
                                }
                                .multilineTextAlignment(.trailing)
                        }
                        if isEditing && !isEditedPriceValid {
                            Text("숫자만 입력하고 선행 0은 금지됩니다 (0, 0.5 허용 / 01, 00.5 불가)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        HStack {
                            Text("수량")
                            Spacer()
                            TextField("수량", text: $editedQuantity)
                                .keyboardType(.numberPad)
                                .onChange(of: editedQuantity) { oldValue, newValue in
                                    let numeric = Int(newValue) != nil
                                    let leadingOK: Bool = {
                                        if newValue == "0" { return true }
                                        return !newValue.hasPrefix("0")
                                    }()
                                    isEditedQuantityValid = numeric && leadingOK
                                }
                                .multilineTextAlignment(.trailing)
                        }
                        if isEditing && !isEditedQuantityValid {
                            Text("정수만 입력하고 선행 0은 금지됩니다 (0, 1, 10 허용 / 01 불가)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .font(.title3)
                    .padding()
                } else {
                    VStack(alignment:.leading, spacing:12) {
                        HStack {
                            Text("재료 이름")
                            Spacer()
                            Text(material.name)
                        }
                        HStack {
                            Text("구매 가게")
                            Spacer()
                            Text(material.store)
                        }
                        HStack {
                            Text("가격")
                            Spacer()
                            Text(material.price)
                        }
                        HStack {
                            Text("수량")
                            Spacer()
                            Text(material.quantity)
                        }
                    }
                    .font(.title3)
                    .padding()
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("재료 상세")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "완료" : "수정") {
                    if isEditing {
                        // 최종 유효성 검사
                        let priceNumeric = Double(editedPrice) != nil
                        let priceLeadingOK: Bool = {
                            if editedPrice == "0" { return true }
                            if editedPrice.hasPrefix("0.") { return true }
                            return !editedPrice.hasPrefix("0")
                        }()
                        isEditedPriceValid = priceNumeric && priceLeadingOK
                        let qtyNumeric = Int(editedQuantity) != nil
                        let qtyLeadingOK: Bool = {
                            if editedQuantity == "0" { return true }
                            return !editedQuantity.hasPrefix("0")
                        }()
                        isEditedQuantityValid = qtyNumeric && qtyLeadingOK
                        guard isEditFormValid else { return }
                        // 저장: 바인딩된 material에 반영
                        material.name = editedName
                        material.store = editedStore
                        material.price = editedPrice
                        material.quantity = editedQuantity
                        material.image = editedImage
                        //❗️색상 업데이트
                        material.color = editedColor
                        // 변경: 수정 시간 갱신
                        // 기존: 수정 시간 미갱신
                        material.updatedAt = Date()
                        isEditing.toggle()
                    } else {
                        // 편집 시작 시 현재 값 로드
                        editedName = material.name
                        editedStore = material.store
                        editedPrice = material.price
                        editedQuantity = material.quantity
                        editedImage = material.image
                        //❗️색상 로드
                        editedColor = material.color
                        // 초기 유효성 상태 동기화
                        let priceNumeric = Double(editedPrice) != nil
                        let priceLeadingOK: Bool = {
                            if editedPrice == "0" { return true }
                            if editedPrice.hasPrefix("0.") { return true }
                            return !editedPrice.hasPrefix("0")
                        }()
                        isEditedPriceValid = priceNumeric && priceLeadingOK
                        let qtyNumeric = Int(editedQuantity) != nil
                        let qtyLeadingOK: Bool = {
                            if editedQuantity == "0" { return true }
                            return !editedQuantity.hasPrefix("0")
                        }()
                        isEditedQuantityValid = qtyNumeric && qtyLeadingOK
                        isEditing.toggle()
                    }
                }
                .disabled(isEditing && !isEditFormValid)
            }
        }
        // 새 구현: PhotosPicker 선택 변경 시 이미지 로드
        .onChange(of: selectedItem) { oldValue, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    editedImage = uiImage
                }
            }
        }
        .onAppear {
            editedName = material.name
            editedStore = material.store
            editedPrice = material.price
            editedQuantity = material.quantity
            editedImage = material.image
            let priceNumeric = Double(editedPrice) != nil
            let priceLeadingOK: Bool = {
                if editedPrice == "0" { return true }
                if editedPrice.hasPrefix("0.") { return true }
                return !editedPrice.hasPrefix("0")
            }()
            isEditedPriceValid = priceNumeric && priceLeadingOK
            let qtyNumeric = Int(editedQuantity) != nil
            let qtyLeadingOK: Bool = {
                if editedQuantity == "0" { return true }
                return !editedQuantity.hasPrefix("0")
            }()
            isEditedQuantityValid = qtyNumeric && qtyLeadingOK
        }
    }
}


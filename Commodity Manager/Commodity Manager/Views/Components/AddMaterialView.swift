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
        // price allows decimal numbers, quantity allows integers
        let priceIsNumber = Double(price) != nil
        let quantityIsInt = Int(quantity) != nil
        return !materialName.isEmpty && priceIsNumber && quantityIsInt
    }

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    
    
    // 색상 관련
    @State private var selectedColor: MaterialColor = .gray
    
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
                    
                    // 색상 선택 UI add feature
                    VStack(alignment:.leading){

                        Text("카드 색상")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators:false){

                            HStack{

                                ForEach(MaterialColor.allCases, id:\.self){ color in

                                    Circle()
                                        .fill(color.color)
                                        .frame(width:40,height:40)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth:3)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
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
                            isPriceValid = Double(newValue) != nil
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isPriceValid {
                        Text("숫자만 입력해주세요 (예: 1200 또는 1200.5)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // 수량 (재고)
                    TextField("수량", text:$quantity)
                        .keyboardType(.numberPad)
                        .onChange(of: quantity) { oldValue, newValue in
                            isQuantityValid = Int(newValue) != nil
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isQuantityValid {
                        Text("숫자만 입력해주세요 (정수)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // 생성 버튼
                    Button(action:{

                        // 최종 유효성 검사: 숫자 이외 입력 시 생성 불가
                        isPriceValid = Double(price) != nil
                        isQuantityValid = Int(quantity) != nil
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


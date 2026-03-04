//
//  AddMaterialView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/4/26.
//

import SwiftUI
import PhotosUI

struct AddMaterialView: View {

    @Environment(\.dismiss) var dismiss

    @Binding var materials: [Material]

    @State private var materialName = ""
    @State private var storeName = ""
    @State private var price = ""
    @State private var quantity = ""

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?

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

                    // 재료 이름
                    TextField("재료 이름", text:$materialName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 가게 이름
                    TextField("구매처", text:$storeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 가격
                    TextField("가격", text:$price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 수량
                    TextField("수량", text:$quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 생성 버튼
                    Button(action:{

                        if !materialName.isEmpty {
                            let newMaterial = Material(
                                name: materialName,
                                store: storeName,
                                price: price,
                                quantity: quantity,
                                image: selectedUIImage
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
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                }
                .padding()
            }
            .navigationTitle("재료 추가")
        }
    }
}


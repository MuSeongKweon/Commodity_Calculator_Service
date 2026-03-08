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
    @State private var editedColor: MaterialColor = .gray
    

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

                        ScrollView(.horizontal, showsIndicators: false) {

                            HStack {

                                ForEach(MaterialColor.allCases, id: \.self) { color in

                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    editedColor == color ? Color.black : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                        .onTapGesture {
                                            editedColor = color
                                        }
                                }
                            }
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
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("수량")
                            Spacer()
                            TextField("수량", text: $editedQuantity)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
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
                        // 저장: 바인딩된 material에 반영
                        material.name = editedName
                        material.store = editedStore
                        material.price = editedPrice
                        material.quantity = editedQuantity
                        material.image = editedImage
                        //❗️색상 업데이트
                        material.color = editedColor
                    } else {
                        // 편집 시작 시 현재 값 로드
                        editedName = material.name
                        editedStore = material.store
                        editedPrice = material.price
                        editedQuantity = material.quantity
                        editedImage = material.image
                        //❗️색상 로드
                        editedColor = material.color
                    }
                    isEditing.toggle()
                }
            }
        }
        // 기존: 더미 이미지 시트 (주석 처리)
        // .sheet(isPresented: $showImagePicker) {
        //     VStack(spacing: 16) {
        //         Text("이미지 선택은 추후 구현")
        //         Button("더미 이미지 적용") {
        //             let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        //             let img = renderer.image { ctx in
        //                 UIColor.systemTeal.setFill()
        //                 ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        //             }
        //             editedImage = img
        //             showImagePicker = false
        //         }
        //         Button("닫기") { showImagePicker = false }
        //     }
        //     .padding()
        // }
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
        }
    }
}


//
//  MaterialDetailView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//  Filter again in git 3/5/26

import SwiftUI

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

    var body: some View {

        ScrollView {

            VStack(spacing:20) {

/* 기존 이미지 표시
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
*/
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
                        Button("사진 변경") { showImagePicker = true }
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


/* 기존 정적 정보 표시
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
*/
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
                    } else {
                        // 편집 시작 시 현재 값 로드
                        editedName = material.name
                        editedStore = material.store
                        editedPrice = material.price
                        editedQuantity = material.quantity
                        editedImage = material.image
                    }
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            VStack(spacing: 16) {
                Text("이미지 선택은 추후 구현")
                Button("더미 이미지 적용") {
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
                    let img = renderer.image { ctx in
                        UIColor.systemTeal.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
                    }
                    editedImage = img
                    showImagePicker = false
                }
                Button("닫기") { showImagePicker = false }
            }
            .padding()
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

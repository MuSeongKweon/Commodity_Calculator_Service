//
//  Untitled.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//

import SwiftUI

struct MainPageView: View {

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // 검색 상태
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var searchResult:[String] = []
    @State private var isSearchMode = false

    // 🔴 수정 (삭제 가능하도록 변경)
    @State private var materialsState = [
        "사과","딸기","수박","Apple","Banana",
        "Milk","Sugar","밀가루","버터","초콜릿"
    ]

    // 🔴 추가 (편집 상태)
    @State private var isEditing = false
    @State private var selectedItems = Set<String>()

    func performSearch(){
        if searchText.isEmpty{
            searchResult = materialsState
        }else{
            searchResult = materialsState.filter{
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }

        isSearchMode = true
        isSearching = false
    }

    // 🔴 추가 삭제 함수
    func deleteSelected(){
        materialsState.removeAll { selectedItems.contains($0) }
        selectedItems.removeAll()
        isEditing = false
    }

    var body: some View {

        NavigationView {

            ZStack{

                ScrollView{

                    LazyVGrid(columns: columns, spacing: 16){

                        ForEach(isSearchMode ? searchResult : materialsState, id:\.self){ item in

                            ZStack(alignment:.topTrailing){

                                MaterialCardView(name: item)

                                // 🔴 편집모드 선택 표시
                                if isEditing{
                                    Button(action:{
                                        if selectedItems.contains(item){
                                            selectedItems.remove(item)
                                        } else{
                                            selectedItems.insert(item)
                                        }
                                    }){
                                        Image(systemName:
                                                selectedItems.contains(item)
                                                ? "checkmark.circle.fill"
                                                : "circle")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                            .padding(6)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                // 검색 overlay
                if isSearching{

                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack{

                        HStack{

                            TextField("재료 검색", text:$searchText)
                                .submitLabel(.search)
                                .onSubmit{
                                    performSearch()
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button("취소"){
                                searchText = ""
                                isSearching = false
                                isSearchMode = false
                            }
                        }

                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding()

                        Spacer()
                    }
                }

                // 🔴 삭제 버튼 UI
                if isEditing{
                    VStack{
                        Spacer()

                        Button(action:{
                            deleteSelected()
                        }){
                            Text("삭제")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth:.infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding()
                        }
                    }
                }
            }

            .navigationTitle("원자재")

            .toolbar{

                ToolbarItem(placement:.navigationBarLeading){
                    Button(action:{}){
                        Image(systemName:"slider.horizontal.3")
                    }
                }

                ToolbarItemGroup(placement:.navigationBarTrailing){

                    Button(action:{
                        withAnimation{
                            isSearching = true
                        }
                    }){
                        Image(systemName:"magnifyingglass")
                    }

                    // 🔴 편집 버튼 동작
                    Button(action:{
                        isEditing.toggle()
                        selectedItems.removeAll()
                    }){
                        Image(systemName:"square.and.pencil")
                    }
                }
            }
        }
    }
}

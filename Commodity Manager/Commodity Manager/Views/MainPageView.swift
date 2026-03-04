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

    // 🔴 추가
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var searchResult:[String] = []
    @State private var isSearchMode = false

    // 더미 데이터
    let materials = [
        "사과","딸기","수박","Apple","Banana",
        "Milk","Sugar","밀가루","버터","초콜릿"
    ]

    // 🔴 추가
    func performSearch(){
        if searchText.isEmpty{
            searchResult = materials
        }else{
            searchResult = materials.filter{
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }

        isSearchMode = true
        isSearching = false
    }

    var body: some View {

        NavigationView {

            ZStack{

                ScrollView{

                    LazyVGrid(columns: columns, spacing: 16){

                        // 🔴 수정
                        ForEach(isSearchMode ? searchResult : materials, id:\.self){ item in

                            NavigationLink(destination: MaterialDetailView(index: 0)){
                                MaterialCardView(name: item)
                            }
                            .buttonStyle(PlainButtonStyle())
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

                                // 🔴 추가 (엔터 처리)
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
            }

            .navigationTitle("원자재")

            .toolbar{

                ToolbarItem(placement:.navigationBarLeading){
                    Button(action:{}){
                        Image(systemName:"slider.horizontal.3")
                    }
                }

                ToolbarItemGroup(placement:.navigationBarTrailing){

                    // 🔴 수정
                    Button(action:{
                        withAnimation{
                            isSearching = true
                        }
                    }){
                        Image(systemName:"magnifyingglass")
                    }

                    Button(action:{}){
                        Image(systemName:"square.and.pencil")
                    }
                }
            }
        }
    }
}

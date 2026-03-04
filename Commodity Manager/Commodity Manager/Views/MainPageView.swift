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
    @State private var searchResult:[Material] = []
    @State private var isSearchMode = false
    
    @State private var showAddView = false

    // 🔴 Material 모델 사용
    @State private var materialsState: [Material] = [
//        Material(name: "사과", store: "과일상회", price: "5000", quantity: "10", image: nil),
//        Material(name: "딸기", store: "마트", price: "7000", quantity: "5", image: nil),
//        Material(name: "수박", store: "농산물시장", price: "15000", quantity: "3", image: nil)
    ]

    // 편집 상태
    @State private var isEditing = false
    @State private var selectedItems = Set<UUID>()

    // 검색
    func performSearch(){
        if searchText.isEmpty{
            searchResult = materialsState
        }else{
            searchResult = materialsState.filter{
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        isSearchMode = true
        isSearching = false
    }

    // 삭제
    func deleteSelected(){
        materialsState.removeAll { selectedItems.contains($0.id) }
        selectedItems.removeAll()
        isEditing = false
    }

    var body: some View {

        NavigationView {

            ZStack{

                ScrollView{

                    LazyVGrid(columns: columns, spacing: 16){

                        ForEach(isSearchMode ? searchResult : materialsState) { item in

                            NavigationLink(destination: MaterialDetailView(material: item)) {

                                ZStack(alignment:.topTrailing){

                                    MaterialCardView(name: item.name)

                                    if isEditing{
                                        Button(action:{
                                            if selectedItems.contains(item.id){
                                                selectedItems.remove(item.id)
                                            } else{
                                                selectedItems.insert(item.id)
                                            }
                                        }){
                                            Image(systemName:
                                                    selectedItems.contains(item.id)
                                                    ? "checkmark.circle.fill"
                                                    : "circle")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .padding(6)
                                        }
                                    }
                                }
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

                // 삭제 버튼
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
            
            .sheet(isPresented: $showAddView) {
                AddMaterialView(materials: $materialsState)
            }
            
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
                    
                    Button(action:{
                        showAddView = true
                    }){
                        Image(systemName:"plus")
                    }

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

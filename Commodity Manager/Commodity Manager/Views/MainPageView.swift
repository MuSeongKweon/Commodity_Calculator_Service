//
//  MainPageView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//  Filter again 3/5/26

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

    // 필터 상태
    @State private var showFilter = false
    @State private var selectedFilter: FilterType?

    // Material 데이터
    @State private var materialsState: [Material] = []

    // 편집 상태
    @State private var isEditing = false
    @State private var selectedItems = Set<UUID>()

    // 검색
    func performSearch(){
        if searchText.isEmpty{
            searchResult = materialsState
        }else{
            searchResult = materialsState.filter{
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.store.localizedCaseInsensitiveContains(searchText) ||
                $0.price.localizedCaseInsensitiveContains(searchText) ||
                $0.quantity.localizedCaseInsensitiveContains(searchText)
            }
        }
        isSearchMode = true
    }

    // 삭제
    func deleteSelected(){
        materialsState.removeAll { selectedItems.contains($0.id) }
        selectedItems.removeAll()
        isEditing = false
    }

    // 정렬 기준: 최신/오래된은 시간 기반으로 처리합니다.
    // Material에 createdAt(Date)와 updatedAt(Date?)가 있다고 가정합니다.
    func sortedMaterials(_ materials:[Material]) -> [Material] {

        guard let selectedFilter else { return materials }

        switch selectedFilter {

        case .alphabetical:
            return materials.sorted{ $0.name < $1.name }

        case .color:
            return materials.sorted{ ($0.image?.description ?? "") < ($1.image?.description ?? "") }

        case .newest:
            // 기존: UUID 문자열 비교 (생성 시각 보장하지 않음)
            // return materials.sorted{ $0.id.uuidString > $1.id.uuidString }
            // 변경: 타임스탬프 기반 (updatedAt 우선, 없으면 createdAt 사용)
            return materials.sorted {
                let lhs = $0.updatedAt ?? $0.createdAt
                let rhs = $1.updatedAt ?? $1.createdAt
                return lhs > rhs
            }

        case .oldest:
            // 기존: UUID 문자열 비교 (생성 시각 보장하지 않음)
            // return materials.sorted{ $0.id.uuidString < $1.id.uuidString }
            // 변경: 타임스탬프 기반 (updatedAt 우선, 없으면 createdAt 사용)
            return materials.sorted {
                let lhs = $0.updatedAt ?? $0.createdAt
                let rhs = $1.updatedAt ?? $1.createdAt
                return lhs < rhs
            }

        case .quantity:
            return materials.sorted{
                Int($0.quantity) ?? 0 < Int($1.quantity) ?? 0
            }

        case .price:
            return materials.sorted{
                Int($0.price) ?? 0 < Int($1.price) ?? 0
            }
        }
    }

    var body: some View {

        NavigationView {

            ZStack{

                ScrollView{

                    LazyVGrid(columns: columns, spacing: 16){

                        ForEach(sortedMaterials(isSearchMode ? searchResult : materialsState)) { item in

                            if let index = materialsState.firstIndex(where: { $0.id == item.id }) {
                                NavigationLink(destination: MaterialDetailView(material: $materialsState[index])) {

                                    ZStack(alignment:.topTrailing){

                                        MaterialCardView(material: item)

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
                                .buttonStyle(.plain)
                            } else {
                                // Fallback: 바인딩을 찾지 못한 경우 읽기 전용으로 표시
                                NavigationLink(destination: MaterialDetailView(material: .constant(item))) {
                                    ZStack(alignment:.topTrailing){
                                        MaterialCardView(material: item)
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
                                .buttonStyle(.plain)
                            }

                        }
                    }
                    .padding()
                }

                // 검색 overlay
                if isSearching{

                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isSearching = false
                            performSearch()
                        }

                    VStack{

                        HStack{

                            TextField("재료 검색", text:$searchText)
                                .onChange(of: searchText) {
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
                        .background(.ultraThinMaterial)
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
            
            .toolbar {

                ToolbarItem(placement:.navigationBarLeading){
                    Button(action:{}){
                        Image(systemName:"slider.horizontal.3")
                    }
                }

                ToolbarItemGroup(placement:.navigationBarTrailing){

                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    
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
                        Image(systemName:"trash")
                    }
                }
            }

            .sheet(isPresented: $showAddView) {
                AddMaterialView(materials: $materialsState)
            }

            // 필터 시트
            .sheet(isPresented:$showFilter){
                FilterView(selectedFilter: $selectedFilter)
            }
        }
    }
}


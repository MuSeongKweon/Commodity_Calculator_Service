//
//  MainPageView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 3/3/26.
//  Filter again 3/5/26

import SwiftUI

// enum 추가
enum SortOrder {
    case asc
    case desc
}

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
    @State private var sortOrder: SortOrder = .asc //상태 변수 추가
    
    // 색상 필터 상태
    @State private var selectedColorFilter: MaterialColor? = nil
    
    // Material 데이터
    @State private var materialsState: [Material] = []

    // 편집 상태
    @State private var isEditing = false
    @State private var selectedItems = Set<UUID>()
    
    // 원자재 계산 기능
    @State private var showCalculator = false
    @State private var showSidebar = false
    
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
        MaterialStorageManager.shared.save(materialsState) // 🔴 재료 카드 삭제 시 업데이트 위함
    }
    func toggleSelection(_ id: UUID) {

        if selectedItems.contains(id) {

            selectedItems.remove(id)

        } else {

            selectedItems.insert(id)

        }

    }
    
    var filteredMaterials: [Material] {
        MaterialSortHelper.sortedMaterials(
            materialsState,
            selectedFilter: selectedFilter,
            sortOrder: sortOrder
        )
    }

    // 색상 그룹 생성
    var groupedMaterials: [MaterialColor:[Material]] {

        Dictionary(grouping: materialsState) { $0.color }
    }
    
    private var sidebarMenu: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink {
                MaterialCalculatorView(materials: $materialsState)
            } label: {
                Label("원자재 계산", systemImage: "")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            NavigationLink {
                SettingsView()
            } label: {
                Label("설정", systemImage: "gearshape")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }

    var body: some View {

        NavigationView {

            ZStack{

                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView{
                            Color.clear
                                .frame(height: 0.1)
                                .id("top")

                            if selectedFilter == .color {

                                // 색상 그룹(뭉치) 화면 표시
                                ColorGroupsView(
                                    groups: groupedMaterials,
                                    selectedColorFilter: $selectedColorFilter,
                                    materials: $materialsState
                                )
                                .padding()
                                 
                            } else {
                                LazyVGrid(columns: columns, spacing: 16){

                                    ForEach(
                                        MaterialSortHelper.sortedMaterials(
                                            isSearchMode ? searchResult : materialsState,
                                            selectedFilter: selectedFilter,
                                            sortOrder: sortOrder
                                        )
                                    ) { item in

                                        if let index = materialsState.firstIndex(where: { $0.id == item.id }) {
                                            if isEditing {

                                                ZStack(alignment: .topTrailing) {

                                                    MaterialCardView(material: item)

                                                    Image(systemName:

                                                            selectedItems.contains(item.id)

                                                            ? "checkmark.circle.fill"

                                                            : "circle")

                                                        .font(.title2)

                                                        .foregroundColor(.blue)

                                                        .padding(6)

                                                }

                                                .contentShape(Rectangle())

                                                .onTapGesture {

                                                    toggleSelection(item.id)

                                                }

                                            } else {

                                                NavigationLink(destination: MaterialDetailView(

                                                    material: $materialsState[index],

                                                    materials: $materialsState

                                                )) {

                                                    MaterialCardView(material: item)

                                                }

                                                .buttonStyle(.plain)

                                            }
                                             
                                        } else {
                                            
                                            // Fallback: 바인딩을 찾지 못한 경우

                                            if isEditing {

                                                ZStack(alignment: .topTrailing) {

                                                    MaterialCardView(material: item)

                                                    Image(systemName:

                                                            selectedItems.contains(item.id)

                                                            ? "checkmark.circle.fill"

                                                            : "circle")

                                                        .font(.title2)

                                                        .foregroundColor(.blue)

                                                        .padding(6)

                                                }

                                                .contentShape(Rectangle())

                                                .onTapGesture {

                                                    toggleSelection(item.id)

                                                }

                                            } else {

                                                NavigationLink(destination: MaterialDetailView(

                                                    material: .constant(item),

                                                    materials: $materialsState

                                                )) {

                                                    MaterialCardView(material: item)

                                                }

                                                .buttonStyle(.plain)

                                            }

                                        }

                                    }
                                }
                                .padding()
                            }
                        }

                        ScrollToTopOverlay(
                            action: {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            },
                            bottomPadding: 16,
                            trailingPadding: 16,
                            size: 56,
                            backgroundColor: .white,
                            iconColor: .gray,
                            systemImageName: "arrow.up.circle.fill"
                        )
                    }
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
                
                // 사이드바
                if showSidebar {

                    HStack {

                        sidebarMenu
                        .padding()
                        .frame(width: 150)
                        .background(Color.white)

                        Spacer()
                    }
                    .background(Color.black.opacity(0.3))
                    .onTapGesture {
                        withAnimation {
                            showSidebar = false
                        }
                    }
                     
                }
            }
            
            .navigationTitle("원자재")
            
            .toolbar {
                
                ToolbarItem(placement:.navigationBarLeading){
                    Button {
                        withAnimation {
                            showSidebar.toggle()
                        }
                    } label: {
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
                FilterView(selectedFilter: $selectedFilter,sortOrder: $sortOrder)
            }
        }
        .onAppear {
            materialsState = MaterialStorageManager.shared.load() // 🔴 시작 시 load
        }
        .onChange(of: materialsState) { _, newValue in
            MaterialStorageManager.shared.save(newValue) // 🔴 저장 트리거
        }
    }
}


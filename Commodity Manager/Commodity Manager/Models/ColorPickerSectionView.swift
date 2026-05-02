//
//  ColorPickerSectionView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/23/26.
//
import SwiftUI

struct ColorPickerSectionView: View {

    @Binding var selectedColor: MaterialColor
    
    @Binding var materials: [Material] //색상 편집 시 기존 카드 색상 변경 작업 - 새로 추가

    @State private var userColorItems: [UserColorItem] = []

    @State private var selectedCustomColor: UserColorItem? = nil

    @State private var showingColorPicker = false

    @State private var tempPickedColor: Color = .gray

    @State private var tempPickedName: String = ""
    
    @State private var showingEditSheet: Bool = false
    @State private var isDeleteMode: Bool = false
    @State private var selectionForDelete: Set<UUID> = []
    @State private var isEditNameMode: Bool = false
    
    @State private var draftColorNames: [UUID: String] = [:]
    @FocusState private var focusedColorNameID: UUID?

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text("카드 색상")

                .font(.headline)

            HStack {
                // 1) 사용자 직접 선택
                Button {
                    // 현재 선택 미리보기는 tempPickedColor로 표시
                    tempPickedColor = selectedCustomColor?.materialColor.color ?? .gray
                    tempPickedName = selectedCustomColor?.materialColor.name ?? ""
                    showingColorPicker = true
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(selectedCustomColor?.materialColor.color ?? tempPickedColor)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                        }
                        Text("직접선택")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingColorPicker) {
                    VStack(spacing: 16) {
                        Text("색상 선택")
                            .font(.headline)
                        //ColorPicker("색상", selection: $tempPickedColor, supportsOpacity: true)
                        ColorPicker("색상", selection: $tempPickedColor, supportsOpacity: false) //투명도를 허용하면 실제 카드 배경색이 뒤 배경과 섞이기 때문에, 저장된 RGB만으로 글자색을 정확히 판단하기 어렵습니다.
                            .padding()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("색상 이름")
                                .font(.subheadline)
                            TextField("예: 민트, 라이트 블루", text: $tempPickedName)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)

                        HStack {
                            Button("취소") {
                                tempPickedName = ""
                                showingColorPicker = false
                            }
                            Spacer()
                            Button("추가") {
                                // 선택된 색상을 이름과 함께 저장 (최대 20개)
                                let name = tempPickedName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let finalName = name.isEmpty ? "사용자 색상 \(userColorItems.count + 1)" : name
                                if userColorItems.count < 20 {
                                    let newMaterialColor = MaterialColor.from(color: tempPickedColor, name: finalName)

                                    let item = UserColorItem(

                                        id: newMaterialColor.id,

                                        materialColor: newMaterialColor
                                        
                                        //name: finalName

                                    )

                                    userColorItems.append(item)

                                    ColorStorageManager.shared.save(userColorItems)

                                    selectedCustomColor = item

                                    selectedColor = newMaterialColor
                                } else {
                                    // 용량 초과 시 선택만 갱신
                                    let tempMaterialColor = MaterialColor.from(color: tempPickedColor, name: finalName)
                                    let tempItem = UserColorItem(
                                        id: tempMaterialColor.id,
                                        materialColor: tempMaterialColor
                                    )
                                    selectedCustomColor = tempItem
                                    selectedColor = tempMaterialColor
                                    /*selectedCustomColor = UserColorItem(id: UUID(), materialColor: selectedColor, name: finalName)
                                    selectedColor = MaterialColor.from(color: tempPickedColor, name: finalName)*/
                                }
                                tempPickedName = ""
                                showingColorPicker = false
                            }
                        }
                        .padding(.horizontal)
                    }
                    .presentationDetents([.medium])
                    .padding()
                }

                // 2)~6) 사용자 색상 리스트 (좌우 스크롤, 최대 20개를 스크롤로 접근)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(userColorItems) { item in
                            Button {
                                selectedCustomColor = item
                                selectedColor = item.materialColor
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(item.materialColor.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke((selectedCustomColor == item) ? Color.black : Color.primary.opacity(0.2), lineWidth: (selectedCustomColor == item) ? 3 : 1)
                                        )
                                    Text(item.materialColor.name)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .frame(width: 52)
                                }
                                .padding(.vertical, 4)
                                .frame(height: 64, alignment: .top)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(item.materialColor.name))
                        }
                    }
                    .frame(height: 64)
                }
                .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)

                // 7) 편집 버튼 (추가된 색상 삭제)
                Button {
                    showingEditSheet = true
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.primary)
                        }
                        Text("편집")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingEditSheet) {
                    NavigationView {
                        List {
                            if userColorItems.isEmpty {
                                Text("추가된 색상이 없습니다.")
                                    .foregroundStyle(.secondary)
                            } else {
                                Section(header: Text("추가된 색상")) {
                                    ForEach($userColorItems) { $item in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(item.materialColor.color)
                                                .frame(width: 24, height: 24)
                                            if isDeleteMode {
                                                // 삭제 모드: 선택 체크박스
                                                Button {
                                                    if selectionForDelete.contains(item.id) {
                                                        selectionForDelete.remove(item.id)
                                                    } else {
                                                        selectionForDelete.insert(item.id)
                                                    }
                                                } label: {
                                                    Image(systemName: selectionForDelete.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                }
                                            }
                                            if isEditNameMode {
                                                TextField(

                                                    "색상 이름",

                                                    text: Binding(

                                                        get: {

                                                            draftColorNames[item.id] ?? item.materialColor.name

                                                        },

                                                        set: { newValue in

                                                            draftColorNames[item.id] = newValue

                                                        }

                                                    )

                                                )

                                                .textFieldStyle(.roundedBorder)

                                                .focused($focusedColorNameID, equals: item.id)

                                                .submitLabel(.done)

                                                .onSubmit {

                                                    focusedColorNameID = nil

                                                }
                                                .textFieldStyle(.roundedBorder)
                                            } else {
                                                Text(item.materialColor.name)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("색상 편집")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(isDeleteMode ? "취소" : "삭제") {
                                    isDeleteMode.toggle()
                                    if isDeleteMode { isEditNameMode = false }
                                    if !isDeleteMode { selectionForDelete.removeAll() }
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                HStack(spacing: 16) {
                                    if isDeleteMode {
                                        Button("전체선택") {
                                            selectionForDelete = Set(userColorItems.map { $0.id })
                                        }
                                        Button("삭제", role: .destructive) {
                                            let ids = selectionForDelete
                                            userColorItems.removeAll { ids.contains($0.id) }
                                            ColorStorageManager.shared.save(userColorItems) // ⭐ 추가
                                            if let selected = selectedCustomColor, ids.contains(selected.id) {
                                                selectedCustomColor = nil
                                            }
                                            selectionForDelete.removeAll()
                                            isDeleteMode = false
                                        }
                                    } else {
                                        Button(isEditNameMode ? "완료" : "수정") {

                                            if isEditNameMode {

                                                focusedColorNameID = nil

                                                commitColorNameEdits()

                                                isEditNameMode = false

                                            } else {

                                                draftColorNames = Dictionary(

                                                    uniqueKeysWithValues: userColorItems.map {

                                                        ($0.id, $0.materialColor.name)

                                                    }

                                                )

                                                isDeleteMode = false

                                                isEditNameMode = true

                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onChange(of: showingEditSheet) { oldValue, newValue in
                    if newValue == false {
                        // 편집 시트가 닫힐 때 편집 상태 초기화
                        isEditNameMode = false
                        isDeleteMode = false
                        selectionForDelete.removeAll()
                    }
                }
            }
        }
        .onAppear {
            userColorItems = ColorStorageManager.shared.load()
        }
    }
    private func commitColorNameEdits() {

        for index in userColorItems.indices {

            let id = userColorItems[index].id

            guard let newName = draftColorNames[id]?.trimmingCharacters(in: .whitespacesAndNewlines),

                  !newName.isEmpty else {

                continue

            }

            let colorID = userColorItems[index].materialColor.id

            userColorItems[index].materialColor.name = newName

            for materialIndex in materials.indices {

                if materials[materialIndex].color.id == colorID {

                    materials[materialIndex].color.name = newName

                    materials[materialIndex].updatedAt = Date()

                }

            }

            if selectedCustomColor?.id == id {

                selectedCustomColor = userColorItems[index]

                selectedColor = userColorItems[index].materialColor

            }

        }

        ColorStorageManager.shared.save(userColorItems)

        MaterialStorageManager.shared.save(materials)

        draftColorNames.removeAll()

    }
}

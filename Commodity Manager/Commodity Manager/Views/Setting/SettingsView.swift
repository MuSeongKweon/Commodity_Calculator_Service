//
//  SettingsView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/28/26.
//

import SwiftUI
import UniformTypeIdentifiers //JSON 백업관련

struct SettingsView: View {
    
    @Environment(\.openURL) private var openURL //피드백 관련 추가
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    //JSON 백업관련
    @State private var backupDocument = JSONBackupDocument()
    @State private var showingJSONExporter = false
    @State private var backupAlertTitle = ""
    @State private var backupAlertMessage = ""
    @State private var showingBackupAlert = false
    
    //JSON 복원관련
    @State private var showingJSONImporter = false
    @State private var pendingImportData: Data?
    @State private var showingImportConfirmAlert = false
    @State private var importAlertTitle = ""
    @State private var importAlertMessage = ""
    @State private var showingImportResultAlert = false
    
    //csv 내보내기 관련
    @State private var csvDocument = CSVExportDocument()
    @State private var showingCSVExporter = false
    @State private var exportAlertTitle = ""
    @State private var exportAlertMessage = ""
    @State private var showingExportAlert = false

    enum AppLanguage: String, CaseIterable, Identifiable {
        case korean = "한국어"
        case english = "English"

        var id: String { rawValue }
    }

    enum AppAppearance: String, CaseIterable, Identifiable {
        case system = "시스템"
        case light = "라이트 모드"
        case dark = "다크 모드"

        var id: String { rawValue }
    }

    @AppStorage("appLanguage") private var appLanguage: String = AppLanguage.korean.rawValue
    @AppStorage("appAppearance") private var appAppearance: String = AppAppearance.system.rawValue

    var body: some View {
        Form {

            // MARK: - 앱 TODO
            /*Section(header: Text("앱")) {

                Picker("앱 언어", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.rawValue)
                            .tag(language.rawValue)
                    }
                }

                Picker("화면 모드", selection: $appAppearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance.rawValue)
                    }
                }
            }*/

            // MARK: - 백업/복원
            Section(header: Text("백업/복원")) {

                Button {
                    do {
                        let data = try AppBackupManager.shared.makeJSONBackupData()
                        backupDocument = JSONBackupDocument(data: data)
                        showingJSONExporter = true
                    } catch {
                        backupAlertTitle = "백업 생성 실패"
                        backupAlertMessage = error.localizedDescription
                        showingBackupAlert = true
                    }
                } label: {
                    Label("JSON 내보내기", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingJSONImporter = true
                } label: {
                    Label("JSON 불러오기", systemImage: "square.and.arrow.down")
                }

                Button {
                    do {
                        let data = try ExcelExportManager.shared.makeCSVExportData()
                        csvDocument = CSVExportDocument(data: data)
                        showingCSVExporter = true
                    } catch {
                        exportAlertTitle = "내보내기 실패"
                        exportAlertMessage = error.localizedDescription
                        showingExportAlert = true
                    }
                } label: {
                    Label("Excel 내보내기", systemImage: "tablecells")
                }
            }

            // MARK: - 정보
            Section(header: Text("정보")) {

                Button {
                    if let url = URL(string: "https://forms.gle/hnaeQJ36FtuGuWdx8") {
                            openURL(url)
                        }
                } label: {
                    Label("피드백 / 버그 접수", systemImage: "ladybug")
                }

                /*Button {
                    /* TODO: 추후 사용 가이드 노션 연결 예정
                    if let url = URL(string: "사용 가이드 노션 링크") {
                            openURL(url)
                        }*/
                } label: {
                    Label("사용 가이드", systemImage: "questionmark.circle")
                }*/

                Button {
                    showingTerms = true
                } label: {
                    Label("이용 약관", systemImage: "doc.text")
                }

                Button {
                    showingPrivacy = true
                } label: {
                    Label("개인정보 처리방침", systemImage: "lock.shield")
                }

                HStack {
                    Label("앱 버전 / 저작권", systemImage: "info.circle")

                    Spacer()

                    Text(appVersionText)
                        .foregroundColor(.secondary)
                }
            }
        }
        //JSON 백업관련
        .fileExporter(
            isPresented: $showingJSONExporter,
            document: backupDocument,
            contentType: .json,
            defaultFilename: "CommodityManagerBackup"
        ) { result in
            switch result {
            case .success:
                backupAlertTitle = "내보내기 완료"
                backupAlertMessage = "JSON 백업 파일이 선택한 위치에 저장되었습니다."
            case .failure(let error):
                backupAlertTitle = "내보내기 실패"
                backupAlertMessage = error.localizedDescription
            }
            showingBackupAlert = true
        }
        .alert(backupAlertTitle, isPresented: $showingBackupAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(backupAlertMessage)
        }
        
        .alert("기존 데이터를 교체할까요?", isPresented: $showingImportConfirmAlert) {
            Button("취소", role: .cancel) {
                pendingImportData = nil
            }
            Button("교체", role: .destructive) {
                guard let data = pendingImportData else { return }
                do {
                    try AppBackupManager.shared.restoreFromJSONBackupData(data)
                    pendingImportData = nil
                    importAlertTitle = "복원 완료"
                    importAlertMessage = "백업 파일의 재료카드와 색상 리스트로 데이터가 교체되었습니다."
                    showingImportResultAlert = true
                } catch {
                    pendingImportData = nil
                    importAlertTitle = "복원 실패"
                    importAlertMessage = error.localizedDescription
                    showingImportResultAlert = true
                }
            }
        } message: {
            Text("현재 앱에 저장된 재료카드와 색상 리스트가 백업 파일의 내용으로 교체됩니다. 이 작업은 되돌릴 수 없습니다.")
        }
        .alert(importAlertTitle, isPresented: $showingImportResultAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(importAlertMessage)
        }
        
        //JSON 복원관련
        .fileImporter(
            isPresented: $showingJSONImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    let data = try Data(contentsOf: url)
                    pendingImportData = data
                    showingImportConfirmAlert = true
                } catch {
                    importAlertTitle = "불러오기 실패"
                    importAlertMessage = error.localizedDescription
                    showingImportResultAlert = true
                }
            case .failure(let error):
                importAlertTitle = "불러오기 실패"
                importAlertMessage = error.localizedDescription
                showingImportResultAlert = true
            }
        }
        
        //csv 내보내기 관련
        .fileExporter(
            isPresented: $showingCSVExporter,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "CommodityManager_Export"
        ) { result in
            switch result {
            case .success:
                exportAlertTitle = "내보내기 완료"
                exportAlertMessage = "Excel에서 열 수 있는 CSV 파일이 저장되었습니다."
            case .failure(let error):
                exportAlertTitle = "내보내기 실패"
                exportAlertMessage = error.localizedDescription
            }

            showingExportAlert = true
        }
        .alert(exportAlertTitle, isPresented: $showingExportAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(exportAlertMessage)
        }
        
        .navigationTitle("설정")
        .sheet(isPresented: $showingTerms) {
            LegalDocumentView(
                title: "이용 약관",
                fileName: "TermsOfService_ko"
            )
        }
        .sheet(isPresented: $showingPrivacy) {
            LegalDocumentView(
                title: "개인정보 처리방침",
                fileName: "PrivacyPolicy"
            )
        }
        .preferredColorScheme(selectedColorScheme)
    }

    private var selectedColorScheme: ColorScheme? {
        switch appAppearance {
        case AppAppearance.light.rawValue:
            return .light
        case AppAppearance.dark.rawValue:
            return .dark
        default:
            return nil
        }
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"

        return "v\(version) (\(build))"
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}

//
//  TermsOfServiceView.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/29/26.
//

import SwiftUI

struct LegalDocumentView: View {

    let title: String
    let fileName: String

    @State private var content: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(content)
                    .font(.body)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTextFile()
        }
    }

    private func loadTextFile() {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            content = "문서를 불러올 수 없습니다."
            return
        }

        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            content = "문서를 불러오는 중 오류가 발생했습니다."
        }
    }
}

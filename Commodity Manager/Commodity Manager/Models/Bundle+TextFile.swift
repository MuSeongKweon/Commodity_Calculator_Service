//
//  Bundle+TextFile.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 4/29/26.
//

import Foundation

extension Bundle {

    func loadTextFile(named fileName: String, extension fileExtension: String = "txt") -> String {

        guard let url = self.url(forResource: fileName, withExtension: fileExtension) else {

            return "문서를 불러올 수 없습니다."

        }

        do {

            return try String(contentsOf: url, encoding: .utf8)

        } catch {

            return "문서를 불러오는 중 오류가 발생했습니다."

        }

    }

}

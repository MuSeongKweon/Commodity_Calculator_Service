//
//  CSVExportDocument.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 5/2/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVExportDocument: FileDocument {

    static var readableContentTypes: [UTType] {
        [.commaSeparatedText]
    }

    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

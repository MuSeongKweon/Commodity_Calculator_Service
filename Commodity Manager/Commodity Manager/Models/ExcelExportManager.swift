//
//  ExcelExportManager.swift
//  Commodity Manager
//
//  Created by MuSeong Kweon on 5/2/26.
//

import Foundation

final class ExcelExportManager {

    static let shared = ExcelExportManager()

    private init() {}

    func makeCSVExportData() throws -> Data {
        let materials = MaterialStorageManager.shared.load()
        let colors = ColorStorageManager.shared.load()

        var rows: [String] = []

        rows.append("Section,ID,Name,Store,Price,Quantity,ColorName,Red,Green,Blue,Opacity,CreatedAt,UpdatedAt,HasImage")

        for material in materials {
            rows.append([
                "Material",
                material.id.uuidString,
                material.name,
                material.store,
                material.price,
                material.quantity,
                material.color.name,
                String(material.color.red),
                String(material.color.green),
                String(material.color.blue),
                String(material.color.opacity),
                formatDate(material.createdAt),
                formatDate(material.updatedAt),
                material.image == nil ? "false" : "true"
            ].map(csvEscape).joined(separator: ","))
        }

        for item in colors {
            let color = item.materialColor

            rows.append([
                "Color",
                item.id.uuidString,
                color.name,
                "",
                "",
                "",
                color.name,
                String(color.red),
                String(color.green),
                String(color.blue),
                String(color.opacity),
                "",
                "",
                ""
            ].map(csvEscape).joined(separator: ","))
        }

        let csvString = rows.joined(separator: "\n")

        guard let data = csvString.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }

        return data
    }

    private func csvEscape(_ value: String?) -> String {
        let value = value ?? ""

        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")

        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            return "\"\(escaped)\""
        } else {
            return escaped
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }

        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }

    enum ExportError: Error {
        case encodingFailed
    }
}

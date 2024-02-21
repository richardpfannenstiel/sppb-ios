//
//  MergePDF+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.11.23.
//

import PDFKit

extension PDFDocument {
    
    convenience init?(mergedFrom pdfs: [PDFDocument]) {
        let document = PDFDocument()
        pdfs.forEach {
            for i in 0..<$0.pageCount {
                let page = $0.page(at: i)!
                let copiedPage = page.copy() as! PDFPage
                document.insert(copiedPage, at: document.pageCount)
            }
        }
        if let documentData = document.dataRepresentation() {
            self.init(data: documentData)
        } else {
            return nil
        }
    }
}

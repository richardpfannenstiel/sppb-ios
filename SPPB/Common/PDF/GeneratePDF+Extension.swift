//
//  GeneratePDF+Extension.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 19.11.23.
//

import PDFKit
import SwiftUI

extension PDFDocument {
    
    @MainActor
    convenience init?(from view: some View) {
        let filename = "temp_\(view).pdf"
        let url = URL.documentsDirectory.appending(path: filename)
        let imageRenderer = ImageRenderer(content: view)
        
        imageRenderer.render { size, context in
            let dinA4: CGFloat = 297 / 210
            var width, height: CGFloat
            var x, y: CGFloat
            if size.height > size.width * dinA4 {
                width = size.height / dinA4
                height = size.height
                x = -(width - size.width) / 2
                y = 0
            } else {
                width = size.width
                height = size.width * dinA4
                x = 0
                y = -(height - size.height) / 2
            }
            
            var box = CGRect(x: x, y: y, width: width, height: height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        self.init(url: url)
    }
}

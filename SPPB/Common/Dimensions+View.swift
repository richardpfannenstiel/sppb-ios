//
//  Dimensions+View.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 03.07.23.
//

import SwiftUI

extension View {
    
    var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    var height: CGFloat {
        UIScreen.main.bounds.height
    }
}

extension UIViewController {
    
    var width: CGFloat {
        UIScreen.main.bounds.size.width
    }
    
    var height: CGFloat {
        UIScreen.main.bounds.size.height
    }
}

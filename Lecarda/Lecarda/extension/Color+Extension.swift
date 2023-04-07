//
//  Color+Extension.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

extension Color {
    
    init(rgba: Int) {
        self.init(
            .sRGB,
            red: Double((rgba & 0xFF000000) >> 24) / 255,
            green: Double((rgba & 0x00FF0000) >> 16) / 255,
            blue: Double((rgba & 0x0000FF00) >> 8) / 255,
            opacity: Double((rgba & 0x000000FF)) / 255
        )
    }
    
    var asRgba: Int {
        let components = cgColor!.components!
        let (r, g, b, a) = (components[0], components[1], components[2], components[3])
        return (Int(a * 255) << 0) + (Int(b * 255) << 8) + (Int(g * 255) << 16) + (Int(r * 255) << 24)
    }
}

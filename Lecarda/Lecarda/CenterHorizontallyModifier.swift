//
//  CenterHorizontallyModifier.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 23.05.23.
//

import Foundation
import SwiftUI

struct CenterHorizontallyModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}

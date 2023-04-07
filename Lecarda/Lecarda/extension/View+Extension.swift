//
//  View+Extension.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 06.04.23.
//

import SwiftUI

extension View {
    
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

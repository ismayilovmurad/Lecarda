//
//  AnswerButtonStyle.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 09.04.23.
//

import Foundation
import SwiftUI

struct AnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .bold()
            .background(Color(red: 0.325, green: 0.498, blue: 0.906))
            .cornerRadius(11.0)
    }
}

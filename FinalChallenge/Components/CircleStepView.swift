//
//  CircleStepView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 30/10/25.
//

import SwiftUI

struct CircleStepView: View {
    var body: some View {
        Circle().fill(Color.yellow).frame(width: 72, height: 72).offset(x: 32)
        Circle().fill(Color.yellow).frame(width: 114, height: 114).offset(x: -32)
        Circle().fill(Color.yellow).frame(width: 72, height: 72).offset(x: 32)
        Circle().fill(Color.yellow).frame(width: 114, height: 114).offset(x: -44)
    }
}

#Preview {
    CircleStepView()
}

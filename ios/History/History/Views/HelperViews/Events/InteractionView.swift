//
//  InteractionView.swift
//  History
//
//  Created by Nathik Azad on 5/13/24.
//

import SwiftUI

struct InteractionView: View {
    let interactionId: Int
    
    init(interaction: Int) {
        self.interactionId = interaction
    }
    
    var body: some View {
        return Text("\(interactionId)")
    }
}

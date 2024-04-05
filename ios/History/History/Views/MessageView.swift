//
//  MessageView.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import SwiftUI

struct MessageView: View
{
    var message: Message
    
    
    var body: some View {
        if message.isFromCurrentUser() {
            HStack {
                HStack {
                    Text (message.text)
                        .padding()
                }
                .frame(maxWidth: 260, alignment: .topLeading)
                .background(.blue)
                .cornerRadius (20)
                Image (systemName: "person")
                    .frame(maxHeight: 32, alignment: .top)
                    .padding(.bottom, 16)
                    .padding(.leading, 4)
            }
            .frame (maxWidth: 360, alignment: .trailing)
        } else {
            HStack {
                Image (systemName: "person")
                    .frame(maxHeight: 32, alignment: .top)
                    .padding (.bottom, 16)
                    .padding(. trailing, 4)
                HStack {
                    Text (message.text)
                        .padding()
                }
                .frame(maxWidth: 260, alignment: .leading)
                .background (.gray)
                .cornerRadius (20)
                .frame (maxWidth:260, alignment: .leading)
                .background(.gray)
                .cornerRadius (20)
            }
            .frame (maxWidth: 360, alignment: .leading)
        }
    }
}

struct MessageView_Preview : PreviewProvider {
    static var previews: some View {
        MessageView(message: Message(userUid: "12", text: "Testing", photoURL: "url", createdAt: Date()))
    }
}

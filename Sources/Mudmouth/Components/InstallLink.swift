//
//  InstallLink.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import BetterSafariView
import SwiftUI

public struct InstallLink: View {
    @StateObject private var manager: CertificateManager = .init()
    @State private var isPresented = false
    @State private var isLongPressed = false
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            Text("Install")
        })
        .safariView(isPresented: $isPresented, content: {
            SafariView(url: .init(unsafeString: "http://127.0.0.1:8888"), configuration: .init(entersReaderIfAvailable: false, barCollapsingEnabled: true))
        })
        .onAppear(perform: {
            manager.launch()
        })
        .onLongPressGesture(minimumDuration: 3,
                            perform: {
            isLongPressed.toggle()
        }, onPressingChanged: { _ in
        })
        .alert("Warning!",
               isPresented: $isLongPressed,
               actions: {
            Button(role: .cancel, action: {}, label: {
                Text("Cancel")
            })
            Button(role: .destructive,
                   action: {
                manager.generate()
            }, label: {
                Text("OK")
            })
        }, message: {
            Text("Current certificate will become invalid, do you really want to generate a new certificate?")
        })
    }
}

#Preview {
    InstallLink()
}

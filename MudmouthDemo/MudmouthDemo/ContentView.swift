//
//  ContentView.swift
//  MudmouthDemo
//
//  Created by devonly on 2024/05/07.
//

import SwiftUI
import Mudmouth

struct ContentView: View {
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection, content: {
            InstallLink()
                .tag(0)
                .tabItem({
                    Image(systemName: "safari")
                    Text("Install")
                })
            Connect()
                .tag(1)
                .tabItem({
                    Image(systemName: "bolt.shield")
                    Text("Connect")
                })
        })
    }
}

#Preview {
    ContentView()
}

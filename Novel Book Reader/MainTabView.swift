//
//  MainTabView.swift
//  Novel Book Reader
//
//  Main tab view combining manual input and Firebase URL management
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Manual Input", systemImage: "keyboard")
                }

            FirebaseURLManagerView()
                .tabItem {
                    Label("Firebase URLs", systemImage: "cloud")
                }
        }
    }
}

#Preview {
    MainTabView()
}

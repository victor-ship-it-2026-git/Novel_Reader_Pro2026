//
//  Novel_Book_ReaderApp.swift
//  Novel Book Reader
//
//  Created by Win on 12/11/2568 BE.
//

import SwiftUI
import FirebaseCore

@main
struct Novel_Book_ReaderApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

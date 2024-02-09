//
//  VocalistApp.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI

@main
struct VocalistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, .init(identifier: "en"))
                .onDisappear {
                    terminateApp()
                }
                .navigationTitle("vocalist.ui.appName")
                .frame(idealWidth: 1000, idealHeight: 600)
        }
        .windowResizability(.contentSize)
    }
    
    private func terminateApp() {
        NSApplication.shared.terminate(self)
    }
}

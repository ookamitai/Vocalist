//
//  VocalistApp.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI

@main
struct VocalistApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, .init(identifier: "en"))
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
                .onDisappear {
                    terminateApp()
                }
                .navigationTitle("vocalist.ui.appName")
            
                .frame(idealWidth: 900, idealHeight: 550)
                .fixedSize(horizontal: false, vertical: false)
            
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text(String(localized: "vocalist.ui.aboutThisApp"))
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }
    }
    
    private func terminateApp() {
        NSApplication.shared.terminate(self)
    }
}

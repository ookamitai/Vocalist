//
//  ContentView.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var filePathURL: URL = URL(filePath: "./")
    @State private var folderPathURL: URL = URL(filePath: "./")
    @State private var useUnicode: Bool = false
    @State private var selected: String = ""
    @State private var files: [String] = []
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $selected) {
                    Section("vocalist.ui.config.title") {
                        NavigationLink {
                            ReclistLoader(filePathURL: $filePathURL, folderPathURL: $folderPathURL, useUnicode:$useUnicode, filenameArray: $files)
                        } label: {
                            Label("vocalist.ui.config.title", systemImage: "gear")
                                .symbolRenderingMode(.multicolor)
                        }
                        .navigationTitle(selected)
                    }
                    
                    Section("vocalist.ui.audio.title") {
                        ForEach(files, id: \.self) { item in
                            NavigationLink() {
                                AudioView(folderPath: folderPathURL.path(), fileName: item)
                            } label: {
                                Label(item, systemImage: "waveform")
                            }
                        }
                        .disabled(filePathURL == URL(filePath: "./") || folderPathURL == URL(filePath: "./"))
                    }
                }
                    
            } detail: {
                Text("vocalist.ui.author")
                    .foregroundStyle(.secondary)
            }
                
        }
    }
}

#Preview {
    ContentView()
}

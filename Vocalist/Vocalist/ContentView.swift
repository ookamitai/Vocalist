//
//  ContentView.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var filePathURL: URL? = UserDefaults.standard.url(forKey: "FilePathURL")
    @State private var folderPathURL: URL? = UserDefaults.standard.url(forKey: "FolderPathURL")
    @State private var showRecorded: Bool = UserDefaults.standard.bool(forKey: "ShowRecordedFiles")
    @State private var useUnicode: Bool = UserDefaults.standard.bool(forKey: "UseUnicode")
    @State private var autoCreateFile: Bool = UserDefaults.standard.bool(forKey: "AutoCreateFile")
    @State private var selected: String = ""
    @State private var files: [String] = []
    
    var filteredFiles: [String] {
        files.filter { item in
            !(FileManager.default.fileExists(atPath: (folderPathURL?.path() ?? "./") + item + ".wav") && !isEmptyFile((folderPathURL?.path() ?? "./") + item + ".wav") && !showRecorded)
        }
    }
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $selected) {
                    Section("vocalist.ui.config.title") {
                        NavigationLink {
                            ReclistLoader(filePathURL: $filePathURL, folderPathURL: $folderPathURL, useUnicode: $useUnicode, showRec: $showRecorded, autoCreateFile: $autoCreateFile, filenameArray: $files)
                        } label: {
                            Label("vocalist.ui.config.title", systemImage: "gear")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    Section("vocalist.ui.audio.title") {
                        ForEach(filteredFiles, id: \.self) { item in
                                NavigationLink() {
                                    AudioView(folderPath: folderPathURL?.path() ?? "./", fileName: item)
                                } label: {
                                    if (FileManager.default.fileExists(atPath: (folderPathURL?.path() ?? "./") + item + ".wav") && !isEmptyFile((folderPathURL?.path() ?? "./") + item + ".wav")) {
                                            Label(item, systemImage: "waveform")
                                                .opacity(0.5)
                                    } else {
                                        Label(item, systemImage: "waveform")
                                    }
                                }
                        }
                        .disabled(filePathURL == URL(filePath: "./") || folderPathURL == URL(filePath: "./"))
                    }
                }
                .animation(.smooth, value: filteredFiles)
                    
            } detail: {
                Text("vocalist.ui.author")
                    .foregroundStyle(.secondary)
                Text("vocalist.ui.hint")
                    .foregroundStyle(.secondary)
            }
            .navigationSplitViewStyle(.prominentDetail)
                
        }
    }
    
    func isEmptyFile(_ x: String) -> Bool {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: x)
            let fileSize = attr[FileAttributeKey.size] as! UInt64
            if fileSize == 0 {
                return true
            } else {
                return false
            }
        } catch {
            return true
        }
    }
}

#Preview {
    ContentView()
}

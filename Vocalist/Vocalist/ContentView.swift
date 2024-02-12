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
    @State private var hideRecorded: Bool = UserDefaults.standard.bool(forKey: "ShowRecordedFiles")
    @State private var useUTF8: Bool = UserDefaults.standard.bool(forKey: "UseUTF8")
    @State private var fastMode: Bool = UserDefaults.standard.bool(forKey: "FastMode")
    @State private var selected: String = ""
    @State private var files: [String] = []
    
    var filteredFiles: [String] {
        files.filter { item in
            !(isFileExist((folderPathURL?.path() ?? "./") + item + ".wav") && hideRecorded)
        }
    }
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $selected) {
                    Section("vocalist.ui.config.title") {
                        NavigationLink {
                            ReclistLoader(filePathURL: $filePathURL, folderPathURL: $folderPathURL, useUTF8: $useUTF8, hideRec: $hideRecorded, fastMode: $fastMode, filenameArray: $files)
                        } label: {
                            Label("vocalist.ui.config.title", systemImage: "gear")
                                .symbolRenderingMode(.hierarchical)

                        }
                    }
                    Section("vocalist.ui.audit.title") {
                        NavigationLink {
                            AuditView(folderURL: (folderPathURL ?? URL(filePath: "./")), files: files)
                        } label: {
                            Label("vocalist.auditView.auditMode", systemImage: "filemenu.and.cursorarrow")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    Section("vocalist.ui.splitter.title") {
                        NavigationLink {
                            SplitterView(files: files, filePath: (filePathURL ?? URL(filePath: "./123.txt")).getParentDir())
                        } label: {
                            Label("vocalist.splitterView.splitter", systemImage: "doc.on.doc")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    
                    Section("vocalist.ui.audio.title") {
                        ForEach(filteredFiles, id: \.self) { item in
                            NavigationLink() {
                                    AudioView(folderPath: folderPathURL?.path() ?? "./", fileName: item, fastMode: fastMode)
                                } label: {
                                    if isFileExist(buildPath(item)) {
                                        if !(getFileSize(buildPath(item)) == 0) {
                                            Label(item, systemImage: "waveform")
                                                .opacity(0.5)
                                        }
                                    } else {
                                        Label(item, systemImage: "waveform")
                                    }
                                }
                        }
                        .disabled(filePathURL == URL(filePath: "./") || folderPathURL == URL(filePath: "./"))
                    }
                }
                .defaultScrollAnchor(.center)
                .animation(.default, value: filteredFiles)
                    
            } detail: {
                Text("vocalist.ui.author")
                    .foregroundStyle(.secondary)
                Text("vocalist.ui.hint")
                    .foregroundStyle(.secondary)
            }
            .navigationSplitViewStyle(.balanced)
                
        }
    }
    
    func buildPath(_ x: String) -> String {
        let base = folderPathURL?.path() ?? "./"
        let y = x + ".wav"
        return base + y
    }

}

func isFileExist(_ x: String) -> Bool {
    return FileManager.default.fileExists(atPath: x)
}

func getFileSize(_ x: String) -> UInt64 {
    do {
        let attr = try FileManager.default.attributesOfItem(atPath: x)
        let fileSize = attr[FileAttributeKey.size] as! UInt64
        return fileSize
    } catch {
        return 0
    }
}

extension URL {
    func getParentDir() -> String {
        let s = self.path()
        let sArray = s.components(separatedBy: "/")
        var result = ""
        for (index, data) in sArray.enumerated() {
            if (index + 1 == sArray.count) {
                break
            } else {
                result += data + "/"
            }
        }
        return result
    }
}

#Preview {
    ContentView()
}

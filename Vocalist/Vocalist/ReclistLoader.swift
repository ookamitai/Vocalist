//
//  ReclistLoader.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI

struct ReclistLoader: View {
    @Binding var filePathURL: URL?
    @Binding var folderPathURL: URL?
    @Binding var useUnicode: Bool
    @Binding var showRec: Bool
    @Binding var autoCreateFile: Bool
    @Binding var filenameArray: [String]
    @State private var log: String = ""
    @State private var importFile: Bool = false
    @State private var importFolder: Bool = false
    
    
    var body: some View {
        VStack {
            HStack() {
                Text("vocalist.ui.appName")
                    .font(.title)
                    .bold()
                Text("vocalist.ui.version")
                    .font(.title3)
                    .fontDesign(.monospaced)
                    .italic()
                    .padding(.top, 5)
                Spacer()
            }
            Divider()
            HStack {
                Label("vocalist.ui.config.title", systemImage: "gear")
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                Spacer()
            }
            .padding(5)
            .padding(.bottom, 5)
            
            // loadFile
            VStack {
                HStack {
                    Label("vocalist.ui.config.reclist", systemImage: "doc.plaintext.fill")
                        .font(.title3)
                        .symbolRenderingMode(.multicolor)
                    Spacer()
                }
                HStack {
                    Button("vocalist.loadFile.loadButton") {
                        importFile = true
                    }
                    .fileImporter(isPresented: $importFile, allowedContentTypes: [.text]) { result in
                        switch result {
                        case .success(let file):
                            filePathURL = file
                            UserDefaults.standard.set(filePathURL, forKey: "FilePathURL")
                            if let rawFile = try? String(contentsOf: filePathURL!, encoding: (useUnicode ? .unicode : .shiftJIS)) {
                                UserDefaults.standard.set(useUnicode, forKey: "UseUnicode")
                                filenameArray = []
                                for item in rawFile.split(whereSeparator: \.isNewline) {
                                    if !item.isEmpty {
                                        filenameArray.append(String(item))
                                    }
                                }
                                log = String(localized: "vocalist.loadFile.loadSuccess \(filePathURL!.path()) \(filenameArray.count)")
                                // log = filenameArray[0]
                            } else {
                                log = String(localized: "vocalist.loadFile.loadError \(filePathURL!.absoluteString)")
                            }
                        case .failure:
                            log = String(localized: "vocalist.loadFile.fileImporterError")
                        }
                    }
                    Text(filePathURL?.path() ?? "None")
                    Spacer()
                    Toggle("vocalist.loadFile.useUnicodeToggle", isOn: $useUnicode)
                }
                .padding(.bottom, 10)
            }
            
            //loadFolder
            VStack {
                HStack {
                    Label("vocalist.ui.config.folder", systemImage: "folder.fill.badge.plus")
                        .font(.title3)
                    Spacer()
                }
                HStack {
                    Button("vocalist.loadFolder.loadButton") {
                        importFolder = true
                    }
                    .fileImporter(isPresented: $importFolder, allowedContentTypes: [.folder]) { result in
                        switch result {
                        case .success(let file):
                            folderPathURL = file
                            UserDefaults.standard.set(folderPathURL, forKey: "FolderPathURL")
                            log = "vocalist.loadFolder.success \(folderPathURL!.path())"
                        case .failure:
                            log = String(localized: "vocalist.loadFolder.fileImporterError")
                        }
                    }
                    
                    Text(folderPathURL?.path() ?? "None")
                    
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            
            //autoCreateFile
            VStack {
                HStack {
                    Label("vocalist.ui.config.autoCreateFile", systemImage: "plus.app.fill")
                        .font(.title3)
                    Spacer()
                }
                HStack {
                    Toggle("vocalist.auutoCreateFile.autoToggle", isOn: $autoCreateFile)
                        .onChange(of: autoCreateFile) {
                            UserDefaults.standard.set(autoCreateFile, forKey: "AutoCreateFile")
                        }
                        .padding(.leading, 2)
                    Text("vocalist.auutoCreateFile.desc")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
            }
            .padding(.bottom, 10)
            
            // showRec
            VStack {
                HStack {
                    Label("vocalist.ui.config.showItem", systemImage: "eye.fill")
                        .font(.title3)
                    Spacer()
                }
                HStack {
                    Toggle("vocalist.showRec.showRecToggle", isOn: $showRec)
                        .onChange(of: showRec) {
                            UserDefaults.standard.set(showRec, forKey: "ShowRecordedFiles")
                        }
                        .padding(.leading, 2)
                    Spacer()
                }
                .padding(.bottom, 5)
                .padding(.leading, 1)
                HStack {
                    Spacer()
                    
                    VStack {
                        List {
                            NavigationLink {} label: {
                                Label("vocalist.showRec.recorded", systemImage: "waveform")
                                    .opacity(0.5)
                            }
                            NavigationLink {} label: {
                                Label("vocalist.showRec.notRecorded", systemImage: "waveform")
                            }
                        }
                        .disabled(true)
                        .frame(width: 150, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.blue, lineWidth: showRec ? 2 : 0)
                        }
                        Text("vocalist.showRec.enabled")
                    }
                    
                    Spacer()
                    
                    VStack {
                        List {
                            NavigationLink {} label: {
                                ZStack {
                                    HStack {
                                        Label("vocalist.showRec.recorded", systemImage: "waveform")
                                            .opacity(0.5)
                                        Spacer()
                                    }
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(height: 2)
                                        .foregroundStyle(.red)
                                }
                            }
                            NavigationLink {} label: {
                                Label("vocalist.showRec.notRecorded", systemImage: "waveform")
                            }
                            .disabled(true)
                        }
                        .disabled(true)
                        .frame(width: 150, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.blue, lineWidth: !showRec ? 2 : 0)
                        }
                        Text("vocalist.showRec.disabled")
                    }
                    
                    Spacer()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .brightness(-0.9)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                }
            }
            .padding(.bottom, 10)
            
            // userDefaults
            VStack {
                HStack {
                    Label("vocalist.ui.config.removeUserDefaults", systemImage: "trash.fill")
                        .font(.title3)
                    Spacer()
                }
                HStack {
                    Button("vocalist.userDefaults.remove") {
                        UserDefaults.resetDefaults()
                    }
                    Text("vocalist.userDefaults.removeWarning")
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
            .padding(.bottom, 10)
            
            Divider()
            // log
            HStack {
                Text(log)
                    .fontDesign(.monospaced)
                    .font(.footnote)
                Spacer()
            }
            .padding(.top, 5)
            
            
        }
        .padding()
        .onAppear {
            if filePathURL != nil {
                if let rawFile = try? String(contentsOf: filePathURL!, encoding: (useUnicode ? .unicode : .shiftJIS)) {
                    filenameArray = []
                    for item in rawFile.split(whereSeparator: \.isNewline) {
                        if !item.isEmpty {
                            filenameArray.append(String(item))
                        }
                    }
                    log = String(localized: "vocalist.loadFile.loadSuccess \(filePathURL!.path()) \(filenameArray.count)")
                    // log = filenameArray[0]
                } else {
                    log = String(localized: "vocalist.loadFile.loadError \(filePathURL!.absoluteString)")
                }
            }
        }
        
        Spacer()
    }
}

extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var filePathURL: URL? = URL(filePath: "./")
        @State private var folderPathURL: URL? = URL(filePath: "./")
        @State private var useUnicode: Bool = false
        @State private var showRec: Bool = true
        @State private var autoCreate: Bool = true
        @State var filenameArray: [String] = ["1", "2"]
        
        var body: some View {
            ReclistLoader(filePathURL: $filePathURL, folderPathURL: $folderPathURL, useUnicode:$useUnicode, showRec: $showRec, autoCreateFile: $autoCreate, filenameArray: $filenameArray)
                .frame(width: 500, height: 400)
        }
    }
    
    return Preview()
}

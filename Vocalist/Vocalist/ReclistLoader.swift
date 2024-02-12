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
    @Binding var useUTF8: Bool
    @Binding var hideRec: Bool
    @Binding var fastMode: Bool
    @Binding var filenameArray: [String]
    // @Binding var itemPerPage: UInt32
    // @Binding var pageIndex: UInt32
    // @Binding var pageNumber: UInt32
    @State private var log: String = ""
    @State private var tmp: String = ""
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
            
            /*
            HStack {
                Label("vocalist.ui.config.title", systemImage: "gear")
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                Spacer()
            }
            .padding(5)
            .padding(.bottom, 5)
             */
            ScrollView {
                // loadFile
                VStack {
                    HStack {
                        Label("vocalist.ui.config.reclist", systemImage: "doc.plaintext.fill")
                            .font(.title2)
                            .bold()
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
                                if let rawFile = try? String(contentsOf: filePathURL!, encoding: (useUTF8 ? .utf8 : .shiftJIS)) {
                                    UserDefaults.standard.set(useUTF8, forKey: "UseUTF8")
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
                        Toggle("vocalist.loadFile.useUTF8Toggle", isOn: $useUTF8)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
                
                
                Divider()
                
                //loadFolder
                VStack {
                    HStack {
                        Label("vocalist.ui.config.folder", systemImage: "folder.fill.badge.plus")
                            .font(.title2)
                            .bold()
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
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
                
                Divider()
                
                // fastMode
                VStack {
                    HStack {
                        Label("vocalist.ui.config.fastMode", systemImage: "hare.fill")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    
                    HStack {
                        Toggle("vocalist.fastMode.fastModeToggle", isOn: $fastMode)
                            .onChange(of: fastMode) {
                                UserDefaults.standard.set(hideRec, forKey: "FastMode")
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
                                HStack {
                                    Label("vocalist.fastMode.record", systemImage: "record.circle")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                HStack {
                                    Label("vocalist.fastMode.delete", systemImage: "trash")
                                    Spacer()
                                    Image(systemName: "arrow.left")
                                }
                            }
                            .disabled(true)
                            .frame(width: 150, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: fastMode ? 2 : 0)
                            }
                            Text("vocalist.fastMode.enabled")
                        }
                        .onTapGesture {
                            fastMode = true
                        }
                        
                        Spacer()
                        
                        VStack {
                            List {
                                HStack {
                                    Label("vocalist.fastMode.record", systemImage: "record.circle")
                                    Spacer()
                                    Image(systemName: "return")
                                }
                                HStack {
                                    Label("vocalist.fastMode.delete", systemImage: "trash")
                                    Spacer()
                                    Image(systemName: "delete.left")
                                }
                            }
                            .disabled(true)
                            .frame(width: 150, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: !fastMode ? 2 : 0)
                            }
                            Text("vocalist.fastMode.disabled")
                        }
                        .onTapGesture {
                            fastMode = false
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    }
                    
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
                
                Divider()
                // hideRec
                VStack {
                    HStack {
                        Label("vocalist.ui.config.hideItem", systemImage: "eye.slash.fill")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Toggle("vocalist.hideRec.hideRecToggle", isOn: $hideRec)
                            .onChange(of: hideRec) {
                                UserDefaults.standard.set(hideRec, forKey: "ShowRecordedFiles")
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
                                Label("vocalist.hideRec.notRecorded", systemImage: "waveform")
                                Spacer()
                            }
                            .disabled(true)
                            .frame(width: 150, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: hideRec ? 2 : 0)
                            }
                            Text("vocalist.hideRec.enabled")
                        }
                        .onTapGesture {
                            hideRec = true
                        }
                        
                        Spacer()
                        
                        VStack {
                            List {
                                Label("vocalist.hideRec.recorded", systemImage: "waveform")
                                    .opacity(0.5)
                                
                                Label("vocalist.hideRec.notRecorded", systemImage: "waveform")
                                
                            }
                            .disabled(true)
                            .frame(width: 150, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: !hideRec ? 2 : 0)
                            }
                            Text("vocalist.hideRec.disabled")
                        }
                        .onTapGesture {
                            hideRec = false
                        }
                        Spacer()
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
                
                Divider()
                
                // userDefaults
                VStack {
                    HStack {
                        Label("vocalist.ui.config.removeUserDefaults", systemImage: "trash.fill")
                            .font(.title2)
                            .bold()
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
                .padding(.top, 5)
                .padding(.bottom, 5)
                
                Divider()
                // log
                HStack {
                    Text(log)
                        .fontDesign(.monospaced)
                        .font(.footnote)
                    Spacer()
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
            }
            // Spacer()
        }
        .padding()
        .onAppear {
            if filePathURL != nil {
                var rawFile = ""
                do {
                    rawFile = try String(contentsOf: filePathURL!, encoding: (useUTF8 ? .utf8 : .shiftJIS))
                    filenameArray = []
                    for item in rawFile.split(whereSeparator: \.isNewline) {
                        if !item.isEmpty {
                            filenameArray.append(String(item))
                        }
                    }
                    log = String(localized: "vocalist.loadFile.loadSuccess \(filePathURL!.path()) \(filenameArray.count)")
                    // log = filenameArray[0]
                    
                } catch {
                    log = String(localized: "vocalist.loadFile.loadError \(filePathURL!.path())")
                }
            }
        }
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
        @State private var useUTF8: Bool = false
        @State private var showRec: Bool = true
        @State private var fastMode: Bool = true
        @State var filenameArray: [String] = ["1", "2"]
        
        var body: some View {
            ReclistLoader(filePathURL: $filePathURL, folderPathURL: $folderPathURL, useUTF8: $useUTF8, hideRec: $showRec, fastMode: $fastMode, filenameArray: $filenameArray)
                .frame(width: 500, height: 600)
        }
    }
    
    return Preview()
}

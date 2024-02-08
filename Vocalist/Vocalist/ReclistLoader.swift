//
//  ReclistLoader.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI

struct ReclistLoader: View {
    @State private var filePathURL: URL = URL(filePath: "./")
    @State private var folderPathURL: URL = URL(filePath: "./")
    @State private var log: String = ""
    @State private var useUnicode: Bool = false
    @State private var importFile: Bool = false
    @State private var importFolder: Bool = false
    @Binding var filenameArray: [String]
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
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
            
            // loadFile
            HStack {
                Text("vocalist.ui.config.reclist")
                    .font(.title3)
                Button("vocalist.loadFile.loadButton") {
                    importFile = true
                }
                .fileImporter(isPresented: $importFile, allowedContentTypes: [.text]) { result in
                    switch result {
                    case .success(let file):
                        filePathURL = file
                        if let rawFile = try? String(contentsOf: filePathURL, encoding: (useUnicode ? .unicode : .shiftJIS)) {
                            filenameArray = []
                            for item in rawFile.split(whereSeparator: \.isNewline) {
                                if !item.isEmpty {
                                    filenameArray.append(String(item))
                                }
                            }
                            log = String(localized: "vocalist.loadFile.loadSuccess \(filePathURL.absoluteString) \(filenameArray.count)")
                            // log = filenameArray[0]
                        } else {
                            log = String(localized: "vocalist.loadFile.loadError \(filePathURL.absoluteString)")
                        }
                    case .failure:
                        log = String(localized: "vocalist.loadFile.fileImporterError")
                    }
                }
                
                Text(filePathURL.absoluteString == URL(filePath: "./").absoluteString ? "None" : filePathURL.absoluteString)
                
                Spacer()
                Toggle("vocalist.loadFile.useUnicodeToggle", isOn: $useUnicode)
            }
            
            //loadFolder
            HStack {
                Text("vocalist.ui.config.folder")
                    .font(.title3)
                Button("vocalist.loadFolder.loadButton") {
                    importFolder = true
                }
                .fileImporter(isPresented: $importFolder, allowedContentTypes: [.folder]) { result in
                    switch result {
                    case .success(let file):
                        folderPathURL = file
                        log = "vocalist.loadFolder.success \(folderPathURL)"
                    case .failure:
                        log = String(localized: "vocalist.loadFolder.fileImporterError")
                    }
                }
                
                Text(folderPathURL.absoluteString == URL(filePath: "./").absoluteString ? "None" : folderPathURL.absoluteString)
                
                Spacer()
            }
            
            Divider()
            HStack {
                Text(log)
                    .fontDesign(.monospaced)
                    .font(.footnote)
                Spacer()
            }
            .padding(.top, 5)
            
            
        }
        .padding()
    }
}

#Preview {
    struct Preview: View {
        @State var filenameArray: [String] = ["1", "2"]
        var body: some View {
            ReclistLoader(filenameArray: $filenameArray)
        }
    }
    
    return Preview()
}

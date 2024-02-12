//
//  SplitterView.swift
//  Vocalist
//
//  Created by ookamitai on 2/11/24.
//

import SwiftUI

struct SplitterView: View {
    let cols = [GridItem(.flexible())]
    @State var files: [String]
    @State var filePath: String
    @State private var tmp: String = ""
    @State private var itemPerFile: Int = 1
    @State private var fileCount: Int = 1
    @State private var split: [[String]] = []
    var body: some View {
        VStack {
            HStack {
                Label("vocalist.splitterView.splitter", systemImage: "doc.on.doc")
                    .font(.title)
                    .bold()
                Spacer()
            }
            Divider()
            HStack {
                Text("vocalist.splitterView.hint")
                    .font(.title3)
                Spacer()
            }
            .padding(5)
            Divider()
            HStack {
                Text("vocalist.splitterView.loadedItems")
                Text("\(files.count)")
                    .padding(.leading, -5)
                    .fontDesign(.monospaced)
                Spacer()
            }
            .padding(5)
            HStack {
                Text("vocalist.splitterView.itemsPerFile")
                TextField("vocalist.splitterView.textField", text: $tmp)
                    .onSubmit {
                        itemPerFile = Int(tmp) ?? 1
                        itemPerFile = itemPerFile > files.count ? files.count : itemPerFile
                        itemPerFile = itemPerFile == 0 ? 1 : itemPerFile
                        fileCount = Int(ceil(Double(files.count) / Double(itemPerFile)))
                        split = files.chunked(into: itemPerFile)
                    }
                    .frame(width: 150)
                    .disabled(files.count == 0)
                Label("\(itemPerFile)", systemImage: "arrow.right")
                Text("vocalist.splitterView.fileCount \(fileCount)")
                    .padding(.leading, -5)
                Spacer()
                Button("vocalist.splitterView.split") {
                    for (index, item) in split.enumerated() {
                        var buildString = ""
                        for i in item {
                            buildString += i + "\n"
                        }
                        do {
                            try Data(buildString.utf8).write(to: URL(filePath: "\(filePath)_splitter_\(Date().currentTimeMillis())_part\(index + 1).txt"))
                        } catch {}
                    }
                }
                .disabled(files.count == 0)
            }
            .padding(5)
            .padding(.top, -5)
            Divider()
            ScrollView {
                VStack {
                    ForEach(split.indices, id: \.self) { index in
                        VStack {
                            HStack {
                                Text("vocalist.splitterView.section \(index + 1)")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                            }
                            ForEach(split[index], id: \.self) { item in
                                HStack {
                                    Text("\(item).wav")
                                        .font(.title3)
                                        .padding(.leading, 20)
                                        .bold(false)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                            Divider()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 1)
            }
            .opacity(files.count == 0 ? 0 : 1)
        }
        .padding()
        .onAppear {
            split = [files]
            itemPerFile = files.count
            fileCount = files.count
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

#Preview {
    struct Preview: View {
        @State var files: [String] = ["1", "2", "3", "4", "5", "6"]
        @State var p: String = "/Users/ookamitai/Desktop/reclist.txt"
        var body: some View {
            SplitterView(files: files, filePath: p)
                // .frame(width: 500, height: 600)
        }
    }
    
    return Preview()
}

//
//  AuditView.swift
//  Vocalist
//
//  Created by ookamitai on 2/9/24.
//

import SwiftUI
import AVFoundation

struct AuditView: View {
    let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State private var isLoading: Bool = false
    @State private var total: Int = 1
    @State private var current: Int = 0
    @State private var avgDuration: Double = 0
    @State private var avgSize: Double = 0
    @State var folderURL: URL
    @State var files: [String]
    @State var gridData: [(String, Bool, Double, UInt64)] = []
    var body: some View {
        VStack {
            HStack {
                Label("vocalist.auditView.auditMode", systemImage: "filemenu.and.cursorarrow")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding(.top, 3)
            .padding(.bottom, 3)
            Divider()
            HStack {
                Text("vocalist.auditView.currentProgress")
                    .font(.title3)
                Text("vocalist.auditView.progress \(current) \(total) \(total - current)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 5)
            HStack {
                ProgressView(value: Float(current), total: Float(total))
                    .animation(.default, value: current)
                if (total != 0) {
                    Text(String(format: "%.1f%%", (Float(current) * 100 / Float(total)) ))
                } else {
                    Text("vocalist.auditView.nofile")
                }
                
                Spacer()
            }
            Divider()
            
            VStack {
                LazyVGrid(columns: cols){
                    Text("vocalist.auditView.name")
                        .bold()
                    Text("vocalist.auditView.presence")
                        .bold()
                    Text("vocalist.auditView.duration")
                        .bold()
                    Text("vocalist.auditView.size")
                        .bold()
                }
                .padding(.top, 10)
                Divider()
                ScrollView {
                    if (isLoading) {
                        Text("vocalist.auditView.loading")
                    } else {
                        LazyVGrid(columns: cols) {
                            ForEach(gridData, id: \.0) { data in
                                Text("\(data.0).wav")
                                    .foregroundStyle(data.1 ? .white : .red)
                                Text(data.1 ? "vocalist.auditView.present" : "vocalist.auditView.absent")
                                Text(data.1 ? "\(data.2)s" : "-")
                                Text(data.1 ? "\(data.3 / 1024) KiB" : "-")
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 1)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .task {
                    isLoading = true
                    gridData = await generateGrid()
                    isLoading = false
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 1)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .brightness(-0.885)
            }
            .padding(.bottom, 5)
            
            List {
                HStack {
                    Text("vocalist.auditView.avgSize")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(avgSize) KiB")
                        .fontDesign(.monospaced)
                }
                HStack {
                    Text("vocalist.auditView.avgDuration")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(avgDuration)s")
                        .fontDesign(.monospaced)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 1)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .brightness(-0.885)
            }
        }
        .padding()
        .onAppear {
            total = files.count
        }
    }
    
    func generateGrid() async -> [(String, Bool, Double, UInt64)] {
        var result: [(String, Bool, Double, UInt64)] = []
        for file in files {
            let filePath: String = folderURL.path() + file + ".wav"
            let audioHere = FileManager.default.fileExists(atPath: filePath)
            if (audioHere) {
                current += 1
            }
            var fileSize: UInt64 = 0
            var fileDuration: Double = 0
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                avgSize += Double(fileSize) / 1024.0
            } catch {}
            let audioAsset = AVAsset(url: URL(filePath: filePath))
            let audioPlayer = AVPlayer(playerItem: AVPlayerItem(asset: audioAsset))
            
            do {
                fileDuration = try await audioPlayer.currentItem!.asset.load(.duration).seconds
                avgDuration += fileDuration
            } catch {}
            result.append((file, audioHere, fileDuration, fileSize))
        }
        avgSize /= Double(current)
        avgDuration /= Double(current)
        return result
    }
}

#Preview {
    struct Preview: View {
        @State var folder: URL = URL(filePath: "/Users/ookamitai/Desktop/")
        @State var files: [String] = ["macaron2", "RE", "macaron 2"]
        var body: some View {
            AuditView(folderURL: folder, files: files)
                // .frame(width: 500, height: 600)
        }
    }
    
    return Preview()
}

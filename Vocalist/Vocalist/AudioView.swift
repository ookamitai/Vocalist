//
//  AudioView.swift
//  Vocalist
//
//  Created by ookamitai on 2/8/24.
//

import SwiftUI
import AVKit
import DSWaveformImage
import DSWaveformImageViews

struct AudioView: View {
    @State var folderPath: String
    @State var fileName: String
    @State private var configuration: Waveform.Configuration = Waveform.Configuration(
            style: .gradient([.gray, .white])
        )
    @State private var filePresent: Bool = false
    @State private var fileDuration: Double = 0
    @State var audioPlayer: AVPlayer!
    
    var body: some View {
        VStack {
            HStack {
                Text(folderPath)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .italic()
                    .padding(.top,3)
                    .padding(.trailing, -4)
                Text(fileName + ".wav")
                    .font(.title)
                    .bold()
                    .fontDesign(.monospaced)
                Spacer()
            }
            Divider()
            HStack {
                if filePresent {
                    WaveformView(audioURL: URL(filePath: folderPath + fileName + ".wav"), configuration: configuration, renderer: LinearWaveformRenderer())
                        .padding(25)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.gray)
                                
                        }
                } else {
                    Text("vocalist.audioView.fileNotExist")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 100)
            .padding(5)
            Divider()
            HStack {
                Button("vocalist.audioView.button.record") {}
                Spacer()
                Button("vocalist.audioView.button.play") {
                    audioPlayer.play()
                }
                Button("vocalist.audioView.button.pause") {
                    audioPlayer.pause()
                }
                Button("vocalist.audioView.button.stop") {
                    audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                    audioPlayer.pause()
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            VStack {
                HStack {
                    Text("vocalist.audioView.duration")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(fileDuration) + "s")
                }
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding()
        .task {
            if (FileManager.default.fileExists(atPath: folderPath + fileName + ".wav")) {
                filePresent = true
                audioPlayer = AVPlayer(url: URL(filePath: folderPath + fileName + ".wav"))
                do {
                    fileDuration = try await audioPlayer.currentItem!.asset.load(.duration).seconds
                } catch {
                    fileDuration = 0
                }
            }
            
        }
    }
    
}


#Preview {
    struct Preview: View {
        @State private var folderPathURL: URL = URL(filePath: "/Users/ookamitai/Desktop/")
        @State private var fileName: String = "macaron"
        
        var body: some View {
            AudioView(folderPath: folderPathURL.path(), fileName: fileName)
        }
    }
    
    return Preview()
}

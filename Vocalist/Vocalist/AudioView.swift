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
    enum FileState: Int {
        case notPresent = 0
        case isPresent = 1
    }
    
    @State var folderPath: String
    @State var fileName: String
    @State var fastMode: Bool
    @State private var fileURL: URL = URL(filePath: "")
    @State private var configuration: Waveform.Configuration = Waveform.Configuration(
            style: .gradient([.gray, .white])
        )
    @State private var filePresent: FileState = .notPresent
    @State private var fileDuration: Double = 0
    @State private var fileSampleRate: Double = 0
    @State private var fileChannel: UInt32 = 0
    @State private var fileSize: UInt64 = 0
    // @State private var recordInitOK: Bool = false
    @State private var isRecording: Bool = false
    @State private var isPaused: Bool = false
    @State private var audioAsset: AVAsset!
    @State private var audioPlayer: AVPlayer!
    @State private var audioRecorder: AVAudioRecorder!
    @State private var offset: CGFloat = 0
    
    let timer = Timer.publish(
        every: 0.05,       // Second
        tolerance: 0.1, // Gives tolerance so that SwiftUI makes optimization
        on: .main,      // Main Thread
        in: .common     // Common Loop
    ).autoconnect()

    
    let recordSettings: [String : Any] = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                          AVSampleRateKey: 44100.0,
                                          AVNumberOfChannelsKey: 1,
                                          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    
    var body: some View {
        VStack {
            HStack {
                Text("vocalist.audioView.nowRecording")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 3)
                Spacer()
            }
            HStack {
                Text(fileName)
                    .font(.title3)
                    .bold()
                    .italic()
                    .fontDesign(.monospaced)
                Spacer()
            }
            Divider()
            HStack {
                Text("vocalist.audioView.saveTo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 3)
                    .padding(.top, 3)
                Spacer()
            }
            HStack {
                Text(folderPath)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .italic()
                    .padding(.trailing, -8)
                Text(fileName + ".wav")
                    .font(.title3)
                    .bold()
                    .italic()
                    .fontDesign(.monospaced)
                Spacer()
            }
            Divider()
            HStack {
                if filePresent == .isPresent {
                    GeometryReader { geometry in
                        ZStack {
                            WaveformView(audioURL: fileURL, configuration: configuration, renderer: LinearWaveformRenderer())
                                .padding(.top, 35)
                                .padding(.bottom, 35)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .brightness(-0.9)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 1)
                                }
                            
                            
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 2, height: 150)
                                .overlay {
                                    Image(systemName: "triangle.fill")
                                        .resizable()
                                        .rotationEffect(.degrees(180))
                                        .offset(x: -0.25, y: -82)
                                        .opacity(1)
                                        .frame(width: 10, height: 7)
                                }
                                .foregroundStyle(.yellow)
                                .offset(x: -geometry.size.width / 2 + offset)
                                .onReceive(timer) { (_) in
                                    if (audioPlayer.isPlaying || isPaused) {
                                        let time = audioPlayer.currentTime().seconds
                                        withAnimation(.linear(duration: 0.1)) {
                                            offset = geometry.size.width * (time / fileDuration)
                                        }
                                    } else {
                                        audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                                        offset = 0
                                    }
                                }
                            
                        }
                        .padding(.top, 5)
                    }
                } else {
                    if (isRecording) {
                        Text("vocalist.audioView.recording")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("vocalist.audioView.fileNotExist")
                            .foregroundStyle(.secondary)
                    }
                    
                }
            }
            .frame(height: 150)
            .padding(5)
            Divider()
            HStack {
                Button(isRecording ? "\(String(localized: "vocalist.audioView.button.stopRecord")) \(Image(systemName: fastMode ? "arrow.right" : "return"))" : "\(String(localized: "vocalist.audioView.button.record")) \(Image(systemName: fastMode ? "arrow.right" : "return"))", systemImage: "record.circle") {
                    isRecording.toggle()
                    if isRecording {
                        filePresent = .notPresent
                        // audioRecorder.deleteRecording()
                        audioPlayer.pause()
                        audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                        isPaused = true
                        audioRecorder.prepareToRecord()
                        audioRecorder.record()
                    } else {
                        audioRecorder.stop()
                        filePresent = .isPresent
                        Task {
                            await refreshData()
                        }
                    }
                }
                .keyboardShortcut(fastMode ? .rightArrow : .return, modifiers: [])
                
                Spacer()
                Button("\(String(localized: "vocalist.audioView.button.play")) \(Image(systemName: "space"))", systemImage: "play") {
                    audioPlayer.play()
                    isPaused = false
                }
                .keyboardShortcut(.space, modifiers: [])
                .disabled(filePresent == .notPresent || isRecording)
                Button("\(String(localized: "vocalist.audioView.button.pause")) \(Image(systemName: "command"))P", systemImage: "pause") {
                    audioPlayer.pause()
                    isPaused = true
                    
                }
                .keyboardShortcut("P", modifiers: .command)
                .disabled(filePresent == .notPresent || isRecording)
                Button("\(String(localized: "vocalist.audioView.button.stop")) \(Image(systemName: "command"))O", systemImage: "stop") {
                    audioPlayer.pause()
                    audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                    isPaused = true
                }
                .keyboardShortcut("O", modifiers: .command)
                .disabled(filePresent == .notPresent || isRecording)
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            HStack {
                Button("\(String(localized: "vocalist.audioView.button.delete")) \(Image(systemName: fastMode ? "arrow.left" : "delete.left"))", systemImage: "trash") {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {}
                    
                    Task {
                        await refreshData()
                        filePresent = .notPresent
                    }
                }
                .keyboardShortcut(fastMode ? .leftArrow : .delete, modifiers: [])
                .disabled(filePresent == .notPresent || isRecording)
                Spacer()
                Button("\(String(localized: "vocalist.audioView.button.refresh")) \(Image(systemName: "command"))F", systemImage: "arrow.clockwise") {
                    Task {
                        filePresent = .notPresent
                        await refreshData()
                    }
                }
                .keyboardShortcut("F", modifiers: .command)
                .disabled(isRecording)
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            VStack {
                List {
                    if (filePresent == .isPresent) {
                        HStack {
                            Text("vocalist.audioView.duration")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(String(fileDuration))s")
                        }
                        HStack {
                            Text("vocalist.audioView.sampleRate")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(String(fileSampleRate))Hz")
                        }
                        HStack {
                            Text("vocalist.audioView.channel")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(fileChannel))
                        }
                        HStack {
                            Text("vocalist.audioView.fileSize")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(String(Int(fileSize / 1024).formatted())) KiB (\(String(Int(fileSize / 1000).formatted())) KB)")
                        }
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
            }
            
            // Spacer()
        }
        .padding()
        .task {
            fileURL = URL(filePath: folderPath + fileName + ".wav")
            await refreshData()
        }
        .onDisappear {
            if audioPlayer != nil {
                audioPlayer.pause()
                audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            }
            if audioRecorder != nil {
                audioRecorder.stop()
            }
        }
    }
    
    func refreshData() async -> Void {
        let audioHere = FileManager.default.fileExists(atPath: fileURL.path())
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path())
            fileSize = attr[FileAttributeKey.size] as! UInt64
        } catch {}
        if (audioHere) {
            filePresent = .isPresent
        } else {
            filePresent = .notPresent
        }
        audioAsset = AVAsset(url: fileURL)
        audioPlayer = AVPlayer(playerItem: AVPlayerItem(asset: audioAsset))
        fileURL = URL(filePath: fileURL.path())
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSettings)
        } catch {}
        do {
            fileDuration = try await audioPlayer.currentItem!.asset.load(.duration).seconds
        } catch {}
        
        do {
            fileSampleRate = try AVAudioFile(forReading: fileURL).fileFormat.sampleRate
        } catch {}
        
        do {
            fileChannel = try AVAudioFile(forReading: fileURL).fileFormat.channelCount
        } catch {}
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

#Preview {
    struct Preview: View {
        @State private var folderPathURL: String = "/Users/ookamitai/Desktop/"
        @State private var fileName: String = "Recorded"
        @State private var fastMode: Bool = true
        
        var body: some View {
            AudioView(folderPath: folderPathURL, fileName: fileName, fastMode: fastMode)
                .frame(minHeight: 600)
        }
    }
    
    return Preview()
}

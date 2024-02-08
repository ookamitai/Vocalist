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
    @State private var fileSampleRate: Double = 0
    @State private var fileChannel: UInt32 = 0
    @State private var recordInitOK: Bool = false
    @State private var isRecording: Bool = false
    @State private var isPlaying: Bool = false
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
                Text(folderPath)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .italic()
                    .padding(.trailing, -5)
                Text(fileName + ".wav")
                    .font(.title3)
                    .bold()
                    .fontDesign(.monospaced)
                Spacer()
            }
            Divider()
            HStack {
                if filePresent {
                    GeometryReader { geometry in
                        WaveformView(audioURL: URL(filePath: folderPath + fileName + ".wav"), configuration: configuration, renderer: LinearWaveformRenderer())
                            .padding(.top, 30)
                            .padding(.bottom, 30)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.black)
                            }
                            .overlay {
                                    Rectangle()
                                        .frame(width: 1, height: 150)
                                        .foregroundStyle(.yellow)
                                        .offset(x: -geometry.size.width / 2 + offset)
                            }
                            .onReceive(timer) { (_) in
                                let time = audioPlayer.currentTime().seconds
                                withAnimation(.linear(duration: 0.05)) {
                                    offset = geometry.size.width * (time / fileDuration)
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.gray)
    
                            }
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
                Button(isRecording ? "vocalist.audioView.button.stopRecord" : "vocalist.audioView.button.record", systemImage: "record.circle") {
                    isRecording.toggle()
                    if isRecording {
                        filePresent = false
                        // audioRecorder.deleteRecording()
                        audioRecorder.prepareToRecord()
                        audioRecorder.record()
                    } else {
                        audioRecorder.stop()
                        filePresent = true
                        Task {
                            await refreshData()
                        }
                    }
                }
                .disabled(!recordInitOK || audioPlayer.isPlaying)
                if (!recordInitOK) {
                    Text("vocalist.audioView.recordInitFailed")
                }
                Spacer()
                Button("vocalist.audioView.button.play", systemImage: "play") {
                    audioPlayer.play()
                }
                .disabled(!filePresent || isRecording)
                Button("vocalist.audioView.button.pause", systemImage: "pause") {
                    audioPlayer.pause()
                }
                .disabled(!filePresent || isRecording)
                Button("vocalist.audioView.button.stop", systemImage: "stop") {
                    audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                    audioPlayer.pause()
                }
                .disabled(!filePresent || isRecording)
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            VStack {
                List {
                    if (filePresent) {
                        HStack {
                            Text("vocalist.audioView.duration")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(fileDuration) + "s")
                        }
                        HStack {
                            Text("vocalist.audioView.sampleRate")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(fileSampleRate) + "Hz")
                        }
                        HStack {
                            Text("vocalist.audioView.channel")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(fileChannel))
                        }
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding()
        .task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        if (FileManager.default.fileExists(atPath: folderPath + fileName + ".wav")) {
            filePresent = true
            audioAsset = AVAsset(url: URL(filePath: folderPath + fileName + ".wav"))
            audioPlayer = AVPlayer(playerItem: AVPlayerItem(asset: audioAsset))
            let fileURL: URL = URL(filePath: folderPath + fileName + ".wav")
            do {
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSettings)
                recordInitOK = true
            } catch {
                recordInitOK = false
            }
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
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
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

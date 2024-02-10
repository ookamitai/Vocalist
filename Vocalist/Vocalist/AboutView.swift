//
//  AboutView.swift
//  Vocalist
//
//  Created by ookamitai on 2/10/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            HStack {
                Image("icon")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100, height: 100)
                VStack {
                    HStack(alignment: .bottom) {
                        Text("vocalist.ui.appName")
                            .font(.title)
                            .bold()
                        Text("vocalist.ui.version")
                            .font(.title3)
                            .fontDesign(.monospaced)
                            .padding(.bottom, 1)
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("vocalist.ui.author")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.leading, 30)
                }
            }
            
            VStack {
                List {
                    HStack {
                        Text("Visit project page:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Link("Github", destination: URL(string: "https://github.com/ookamitai/Vocalist")!)
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    HStack {
                        Text("vocalist.aboutView.followMe")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Link("X (formerly Twitter)", destination: URL(string: "https://twitter.com/ookamitai/")!)
                            .foregroundStyle(.blue)
                            .underline()
                    }
                }
                
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .brightness(-0.9)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 1)
            }
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            AboutView()
                .frame(width: 500, height: 300)
        }
    }
    
    return Preview()
}

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
            VStack {
                HStack {
                    Label("vocalist.ui.appName", systemImage: "")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text("vocalist.ui.author")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.leading, 30)
            }
            .padding()
            
            VStack {
                List {
                    HStack {
                        Text("Visit:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Github") {}
                            .foregroundStyle(.blue)
                            .underline()
                            .buttonStyle(.plain)
                    }
                    HStack {
                        Text("Visit:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Twitter (X)") {}
                            .foregroundStyle(.blue)
                            .underline()
                            .buttonStyle(.plain)
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
        .frame(minWidth: 300, minHeight: 300)
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            AboutView()
                .frame(width: 300, height: 300)
        }
    }
    
    return Preview()
}

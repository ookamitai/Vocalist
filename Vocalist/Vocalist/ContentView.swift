//
//  ContentView.swift
//  Vocalist
//
//  Created by ookamitai on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var files: [String] = []
    
    var body: some View {
        VStack {
            ReclistLoader(filenameArray: $files)
        }
    }
}

#Preview {
    ContentView()
}

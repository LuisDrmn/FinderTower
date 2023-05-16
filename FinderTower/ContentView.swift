//
//  ContentView.swift
//  FinderTower
//
//  Created by Jean-Louis Darmon on 16/05/2023.
//

import SwiftUI

struct ContentView: View {
    var fileMonitor: FileMonitor = FileMonitor()
    @State var path: String = "/Volumes"
    
    var body: some View {
        VStack {
            Text("Add a path")
            TextField("Path to watch", text: $path).onSubmit {
                fileMonitor.addDirectory(path: path)
                path = ""
                fileMonitor.startMonitoring()
            }
            Button("Stop Monitoring") {
                fileMonitor.stopMonitoring()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

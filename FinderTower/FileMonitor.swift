//
//  FileMonitor.swift
//  FinderTower
//
//  Created by Jean-Louis Darmon on 16/05/2023.
//

import CoreServices
import Foundation

class FileMonitor {
    private var directoryPaths: [String] = []
    private var streamRef: FSEventStreamRef?
    private let queue: DispatchQueue

    init() {
        self.queue = DispatchQueue(label: "FileMonitorQueue")
    }

    func addDirectory(path: String) {
        print("Added path: \(path)")
        self.directoryPaths.append(path)
    }

    func startMonitoring() {
        guard streamRef == nil else {
            return
        }

        print("Start Monitoring")
        setup()

        guard let streamRef = streamRef else {
            return
        }
        FSEventStreamSetDispatchQueue(streamRef, queue)
        FSEventStreamStart(streamRef)
    }

    func stopMonitoring() {
        guard let streamRef = streamRef else {
            return
        }

        print("Stop Monitoring")
        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
        FSEventStreamRelease(streamRef)

        self.streamRef = nil
    }

    private func setup() {
        let pathsToWatch = directoryPaths

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        streamRef = FSEventStreamCreate(nil, FileMonitor.fileSystemEventCallback, &context, pathsToWatch as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 0, FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents))
    }

    private static let fileSystemEventCallback: FSEventStreamCallback = { streamRef, clientCallbackInfo, numEvents, eventPaths, eventFlags, eventIds in
        print("NumEvents: \(numEvents)")

        let pathsPointer = eventPaths.assumingMemoryBound(to: UnsafeMutablePointer<Int8>.self)
        for i in 0..<numEvents {
            let flags = eventFlags.pointee
            let path = String(cString: pathsPointer[i])
            print("Event flags: \(flags), Path: \(path)")

            if Int(flags) & kFSEventStreamEventFlagMount != 0 {
                print("Volume mounted at path: \(path)")
            }

            if Int(flags) & kFSEventStreamEventFlagUnmount != 0 {
                print("Volume unmounted from path: \(path)")
            }

        }
    }
}

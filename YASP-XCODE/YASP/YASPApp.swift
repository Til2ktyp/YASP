//
//  YASPApp.swift
//  YASP
//
//  Created by Til Freitag on 02.09.25.
//

import SwiftUI

@main
struct YASPApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    #if os(macOS)
                    if let window = NSApplication.shared.windows.first {
                        window.tabbingMode = .disallowed
                    }
                    #endif
                }
        }
    }
}

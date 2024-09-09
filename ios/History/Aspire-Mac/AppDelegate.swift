//
//  AppDelegate.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/7/24.
//

import SwiftUI
import AppKit
import SwiftData

extension NSApplication {
    static func hideFromDock() {
        NSApp.setActivationPolicy(.accessory)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    var popover = NSPopover()
    var mainWindow: NSWindow?
    
    @ObservedObject var appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.hideFromDock()
        setupStatusBar()
        setupMainWindow()
    }
    
    func setupStatusBar() {
        let statusBarView = StatusBarView(
            appState: appState,
            quitAction: { NSApplication.shared.terminate(nil) },
            showMainWindowAction: { self.showMainWindow() }
        )
        
        popover.contentSize = NSSize(width: 250, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: statusBarView)
        
        statusBar = StatusBarController(popover)
    }
    
    func setupMainWindow() {
        let mainAppView = MainAppView(
            appState: appState
        )
        
        mainWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow?.title = "Aspire Desktop"
        mainWindow?.contentView = NSHostingView(rootView: mainAppView)
    }
    
    func showMainWindow() {
        print("Show main window")
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "camera", accessibilityDescription: "Screenshot")
            statusBarButton.action = #selector(togglePopover)
            statusBarButton.target = self
        }
    }
    
    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    func showPopover() {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover() {
        popover.performClose(nil)
    }
}



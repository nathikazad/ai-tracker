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

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Instead of closing the window, we'll just hide it
        if let window = notification.object as? NSWindow {
            window.orderOut(nil)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    var popover = NSPopover()
    var mainWindowController: MainWindowController?
    
    @ObservedObject var appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.hideFromDock()
        setupStatusBar()
        setupMainWindowController()
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
    
    func setupMainWindowController() {
        mainWindowController = MainWindowController(appState: appState)
    }
    
    func showMainWindow() {
        if mainWindowController == nil {
            setupMainWindowController()
        }
        
        mainWindowController?.showWindow(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showMainWindow()
        }
        return true
    }
}

class MainWindowController: NSWindowController, NSWindowDelegate {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
        
        let mainAppView = MainAppView(appState: appState)
        let hostingController = NSHostingController(rootView: mainAppView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Aspire Desktop"
        window.contentViewController = hostingController
        
        super.init(window: window)
        
        window.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        // Instead of closing the window, we'll just hide it
        window?.orderOut(nil)
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



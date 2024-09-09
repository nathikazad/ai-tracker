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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.hideFromDock()
        
        let contentView = ScreenshotView()
            .environment(\.modelContext, (NSApplication.shared.delegate as? Aspire_DesktopApp)?.sharedModelContainer.mainContext ?? ModelContext(try! ModelContainer(for: ScreenshotSettings.self)))
        
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusBar = StatusBarController(popover)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Perform any cleanup here if needed
        // For example, stop any ongoing screenshot processes
        if let screenshotView = popover.contentViewController?.view as? NSHostingView<ScreenshotView> {
            screenshotView.rootView.stopScreenshots()
        }
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

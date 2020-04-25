//
//  AppDelegate.swift
//  Study
//
//  Created by GP on 4/23/20.
//  Copyright © 2020 GP. All rights reserved.
//
// https://medium.com/@acwrightdesign/creating-a-macos-menu-bar-application-using-swiftui-54572a5d5f87
// https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
// https://stackoverflow.com/questions/49054485/file-couldn-t-be-opened-because-you-don-t-have-permission-to-view-it-error
// https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxQuickStart/AppSandboxQuickStart.html


import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var timer: Timer!
    
    var studyMI: NSMenuItem!
    var resetMI: NSMenuItem!
    var quitMI: NSMenuItem!
    var displayMI: NSMenuItem!
    var stopMI: NSMenuItem!
    var p1MI: NSMenuItem!
    var p2MI: NSMenuItem!
    var p3MI: NSMenuItem!
    
    /**********************************************************/
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        
        constructMenu()
        
        // Create the popover
        let popover = NSPopover()
        // Create the SwiftUI view that provides the window contents.
        popover.contentSize = NSSize(width: 340, height: 400)
        popover.behavior = .transient
        //popover.contentViewController = NSHostingController(rootView: Text(readFile()))
        self.popover = popover
        
    }
    
    /**********************************************************/
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /**********************************************************/
    func constructMenu() {
        let menu = NSMenu()
        
        self.studyMI = NSMenuItem(title: "Study", action: #selector(AppDelegate.study(_:)), keyEquivalent: "")
        self.resetMI = NSMenuItem(title: "Reset", action: #selector(AppDelegate.resetStudy(_:)), keyEquivalent: "")
        self.quitMI = NSMenuItem(title: "Quit Study", action: #selector(AppDelegate.quitStudy(_:)), keyEquivalent: "")
        self.displayMI = NSMenuItem(title: "Display", action: #selector(AppDelegate.display(_:)), keyEquivalent: "")
        self.stopMI = NSMenuItem(title: "Stop", action: #selector(AppDelegate.stopStudy(_:)), keyEquivalent: "")
        self.p1MI = NSMenuItem(title: "", action: #selector(AppDelegate.record(_:)), keyEquivalent: "")
        self.p2MI = NSMenuItem(title: "", action: #selector(AppDelegate.record(_:)), keyEquivalent: "")
        self.p3MI = NSMenuItem(title: "", action: #selector(AppDelegate.record(_:)), keyEquivalent: "")
        
        self.p1MI.isHidden = true
        self.p2MI.isHidden = true
        self.p3MI.isHidden = true
        self.resetMI.isHidden = true
        self.stopMI.isHidden = true
        
        menu.addItem(self.studyMI)
        menu.addItem(self.displayMI)
        menu.addItem(self.p1MI)
        menu.addItem(self.p2MI)
        menu.addItem(self.p3MI)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.stopMI)
        menu.addItem(self.resetMI)
        menu.addItem(self.quitMI)
        statusBarItem.menu = menu
    }
    
    /**********************************************************/
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                let contentView = ContentView()
                self.popover.contentViewController = NSHostingController(rootView: contentView)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    /**********************************************************/
    @objc func study(_ sender: NSMenuItem) {
        let current = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        self.p1MI.title = formatter.string(from: current)
        let nextP = extractInterval(self.p1MI)
        
        var nextDate = current.addingTimeInterval(TimeInterval(nextP * 60))
        self.p2MI.title = formatter.string(from: nextDate)
        nextDate = current.addingTimeInterval(TimeInterval((nextP + 30) * 60))
        self.p3MI.title = formatter.string(from: nextDate)
        
        self.p1MI.isHidden = false
        self.p2MI.isHidden = false
        self.p3MI.isHidden = false
        self.resetMI.isHidden = false
        self.stopMI.isHidden = false
        self.studyMI.isHidden = true
        self.displayMI.isHidden = true
        self.quitMI.isHidden = true
        self.p1MI.action = #selector(AppDelegate.record(_:))
        self.p2MI.action = #selector(AppDelegate.record(_:))
        self.p3MI.action = #selector(AppDelegate.record(_:))
        
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(nextP * 60), target: self, selector: #selector(fireTimer), userInfo: self.p1MI, repeats: false)
        
    }
    
    /**********************************************************/
    @objc func resetStudy(_ sender: Any?) {
        if (self.timer != nil) {
            self.timer.invalidate()
        }
        self.timer = nil
        self.p1MI.isHidden = true
        self.p2MI.isHidden = true
        self.p3MI.isHidden = true
        self.resetMI.isHidden = true
        self.stopMI.isHidden = true
        self.studyMI.isHidden = false
        self.displayMI.isHidden = false
        self.quitMI.isHidden = false
    }
    
    /**********************************************************/
    @objc func display(_ sender: AnyObject?) {
        togglePopover(sender)
    }
    
    /**********************************************************/
    @objc func record(_ sender: NSMenuItem) {
        let nextP = extractInterval(sender)
        ContentView().appendToFile(minutes: nextP)
        resetStudy(sender)
    }
    
    /**********************************************************/
    @objc func stopStudy(_ sender: NSMenuItem) {
        // Find the current active time period
        var mi = ""
        if (p1MI.action != nil) {
            mi = p1MI.title
        } else if (p2MI.action != nil) {
            mi = p2MI.title
        } else {
            mi = p3MI.title
        }
        
        let (hr1, min1) = getHrMin(getDateObj(mi))
        let (hr2, min2) = getHrMin(Date())
        let interval = min2 - min1
        if (hr1 == hr2 && interval > 0 && interval <= 30) {
            ContentView().appendToFile(minutes: interval)
        } else {
            _ = AppDelegate.dialogOKCancel(question: "Error", text: "Time interval is invalid (\(interval) min), not recorded.", cancelButton: false)
        }
        resetStudy(sender)
    }
    
    /**********************************************************/
    @objc func quitStudy(_ sender: Any?) {
        if (self.timer != nil) {
            self.timer.invalidate()
        }
        NSApplication.shared.terminate(sender)
    }
    
    /**********************************************************/
    func getDateObj(_ fromStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        //formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: fromStr)!
    }
    
    /**********************************************************/
    func getHrMin(_ fromD: Date) -> (Int, Int) {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: fromD)
        let hour = calendar.component(.hour, from: fromD)
        return (hour, minutes)
    }
    
    /**********************************************************/
    func extractInterval(_ sender: NSMenuItem) -> Int {
        let beginTime = self.getDateObj(sender.title)
        let (_, minutes) = getHrMin(beginTime)
        var nextP = 0
        if (minutes < 30) {
            nextP = 30 - minutes
        } else {
            nextP = 60 - minutes
        }
        return nextP
    }
    
    /**********************************************************/
    static func dialogOKCancel(question: String, text: String,
                               cancelButton: Bool = true) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        if (cancelButton) {
            alert.addButton(withTitle: "Cancel")
        }
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    /**********************************************************/
    @objc func fireTimer(timer: Timer) {
        let menuItem = timer.userInfo as! NSMenuItem
        let interval = extractInterval(menuItem)
        //print("Timer fired! \(interval)")
        self.timer = nil
        let answer = AppDelegate.dialogOKCancel(question: "Study", text: "Record \(interval) minutes?")
        if (answer) {
            menuItem.action = nil
            // append to file
            ContentView().appendToFile(minutes: interval)
            
            if (self.p3MI.action == nil) {
                resetStudy(self.p3MI)
                return
            }
            var period = self.p2MI
            if (self.p2MI.action == nil) {
                period = self.p3MI
            }
            let newInterval = 30 * 60
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(newInterval), target: self, selector: #selector(fireTimer), userInfo: period, repeats: false)
            
        } else {
            resetStudy(menuItem)
        }
    }
    
    
}

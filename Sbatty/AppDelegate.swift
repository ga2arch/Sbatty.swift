//
//  AppDelegate.swift
//  Sbatty2
//
//  Created by Gabriele Carrettoni on 03/11/14.
//  Copyright (c) 2014 Gabriele Carrettoni. All rights reserved.
//

import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var notcenter: NSUserNotificationCenter!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        notcenter = NSUserNotificationCenter.defaultUserNotificationCenter()

        var args = NSProcessInfo.processInfo().arguments as [String]
        if args.count == 3 && args[1] == "in" {
            let pls = makePls(&args[2])
            startSbatty(pls)
            
        } else if args.count == 2 {
            
            displayNotification("Sbatty",
                message: "A man's gotta do what a man's gotta do")
            
            var sound = NSSound(named: "Ping")
            
            for _ in 1...5 {
                sound?.play()
                usleep(300000)
                sound?.stop()
            }
        } else {
            println("Help: sbatty in <time><unit>")
            println("Example: sbatty in 10s")
        }
        
        NSApplication.sharedApplication().terminate(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func displayNotification(title: String, message: String) {
        var notification = NSUserNotification()
        notification.title = title
        notification.subtitle = message
        
        notcenter.deliverNotification(notification)
    }
    
    func startSbatty(pls: String) {
        var shell: NSTask = NSTask()
        shell.launchPath = "/bin/launchctl"
        shell.arguments  = ["load", pls]
        shell.launch()
    }
    
    func makePls(inout arg: String) -> String {
        let unit = arg.removeAtIndex(advance(arg.endIndex, -1))
        let time = arg.toInt()! * seconds(unit)
        
        let exec = NSProcessInfo.processInfo().arguments[0] as String
        
        let path = NSHomeDirectory()
        let pls = path.stringByAppendingPathComponent(".reminder.plist")
        var dict: NSMutableDictionary = [
            "Label": "com.gabriele.sbatty",
            "ProgramArguments": [exec, "n"],
            "KeepAlive": false,
            "LaunchOnlyOnce": true,
            "RunAtLoad": false,
            "StartInterval": time
        ]
        
        dict.writeToFile(pls, atomically: true)
        
        return pls
    }

    func seconds(unit: Character) -> Int {
        switch unit {
        case "s": return 1
        case "m": return 60
        case "h": return 60 * 60
            
        default:
            return 1
        }
    }

}


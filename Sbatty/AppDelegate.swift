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
        
        if args.count == 4 && (args[1] == "in" || args[1] == "every") {
            let pls = makePls(args[1], when: &args[2], message: args[3])
            startSbatty(pls)
        }
        else if args.count == 2 && args[1] == "help" {
            println("Help: sbatty in <time><unit>")
            println("Example: sbatty in 10s")
        }
        else  if args.count == 4 {
            displayNotification("Sbatty", message: args[3])
            
            var sound = NSSound(named: "Ping")
            
            for _ in 1...5 {
                sound?.play()
                usleep(300000)
                sound?.stop()
            }
            
            let delete = args[2] == "in" ? true : false
            if delete {
                let fm = NSFileManager.defaultManager()
                
                let path = NSHomeDirectory()
                let alarms = path.stringByAppendingPathComponent(".alarms/")
                let plsName = args[1]
                
                let pls = alarms.stringByAppendingPathComponent(plsName)
                fm.removeItemAtPath(pls, error: nil)
            }
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
    
    func makePls(how: String, inout when: String, message: String) -> String {
        let repetition = how == "every" ? false : true

        let unit = when.removeAtIndex(advance(when.endIndex, -1))
        let time = when.toInt()! * seconds(unit)
        
        let exec = NSProcessInfo.processInfo().arguments[0] as String
        
        let path = NSHomeDirectory()
        let alarms = path.stringByAppendingPathComponent(".alarms/")
        
        let random = randomStringWithLength(10)
        let plsName = ".reminder-\(random).plist"
        
        let pls = alarms.stringByAppendingPathComponent(plsName)
        
        var dict: NSMutableDictionary = [
            "Label": "com.gabriele.sbatty-\(random)",
            "ProgramArguments": [exec, plsName, how, message],
            "LaunchOnlyOnce": repetition,
            "RunAtLoad": false,
            "StartInterval": time,
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
    
    func randomStringWithLength(len: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var randomString: String = ""
        
        for i in 0...len {
            let r = arc4random_uniform(UInt32(countElements(letters)))
            let c = letters[Int(r)]
            randomString.append(c)
        }
        
        return randomString
    }

}


//
//  main.swift
//  Sbatty
//
//  Created by Gabriele Carrettoni on 03/11/14.
//  Copyright (c) 2014 Gabriele Carrettoni. All rights reserved.
//

import Foundation
import Cocoa

infix operator ** {}

func ** (num: Int, power: Int) -> Int {
    return Int(pow(Double(num), Double(power)))
}

func microseconds(unit: Character) -> Int {
    switch unit {
    case "s":
        return 1  * 10 ** 6
    case "m":
        return 6  * 10 ** 7
    case "h":
        return 36 * 10 ** 8
        
    default:
        return 1
    }
}

func makePls(inout arg: String) -> () {
    let unit = arg.removeAtIndex(advance(arg.endIndex, -1))
    let time = arg.toInt()! * microseconds(unit)
    
    let exec = NSProcessInfo.processInfo().arguments[0] as String
    
    let path = NSHomeDirectory()
    let doc = path.stringByAppendingPathComponent(".reminder.plist")
    var dict: NSMutableDictionary = [
        "Label": "com.gabriele.sbatty",
        "ProgramArguments": [exec, String(time)],
        "KeepAlive": false,
        "LaunchOnlyOnce": true,
        "RunAtLoad": true
    ]

    dict.writeToFile(doc, atomically: true)
    
    var shell: NSTask = NSTask()
    shell.launchPath = "/bin/launchctl"
    shell.arguments  = ["load", doc]
    shell.launch()
}

func main(inout args: [String]) -> () {
    if args.count == 3 && args[1] == "in" {
        makePls(&args[2])
        
    } else if args.count == 2 {
        
        let delay = args[1]
        usleep(UInt32(delay.toInt()!))
        
        var shell: NSTask = NSTask()
        shell.launchPath = "/usr/local/bin/terminal-notifier"
        shell.arguments  = ["-title", "Sbatty",
            "-message", "A man's gotta do what a man's gotta do"]
        shell.launch()
        
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
}

var args = NSProcessInfo.processInfo().arguments as [String]
main(&args)

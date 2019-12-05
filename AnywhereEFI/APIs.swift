//
//  APIs.swift
//  AnywhereEFI
//
//  Created by PHBZ on 2019/12/2.
//  Copyright © 2019年 PHBZ. All rights reserved.
//

/* This file contains all the functions I used in this program. Since these functions are very useful, I have wroted them as APIs for references in other programs's programming. */

import Foundation

let fileman = FileManager.default

public enum myoperation:NSInteger{
    case copy = 1
    case move = 2
    case delete = 3
    case delall = 4
}

public enum mytype:NSInteger{
    case file = 1
    case dict = 2
}

//Run shell command that allow to get root
public func runscript(command:String, requireroot: Bool)-> String {
    var error:NSDictionary? = nil
    let temproot:String = "do shell script \"" + command + "\" with administrator privileges"
    let temp:String = "do shell script \"" + command + "\""
    let script:NSAppleScript?
    
    if requireroot{
        script = NSAppleScript(source: temproot)!
    }
    else{
        script = NSAppleScript(source: temp)!
    }
    let tmp = script!.executeAndReturnError(&error)
    let ret = String(data: tmp.data, encoding: String.Encoding.utf8)
    return ret!
}

//Run commands in the shell
public func shell(_ args: [String]) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    
    return output;
}

public func getkeyboard()->String{
    let userInput = readLine(strippingNewline: true)
    return userInput!
}

//Keep the keyboard be an integer and return it
public func mustberightnum(Lbound:Int, Ubound:Int)->Int{
    var val:Int?
    while true {
        guard let ret = Int(getkeyboard()) else{
            print("Your input was incorrect, please try again:")
            continue
        }
        //Determine whether it is out of the range
        val = ret
        if val! > Ubound || val! < Lbound{
            print("Your input was out of the range, please try again:")
            continue
        }
        else{
            break
        }
    }
    return val!
}

//Return the substring from a range in one line of a file
public func loadfromfile(filepath: String, atIndex: Int, from: Int, to: Int) -> String {
    var final = String(describing: String.Encoding.utf8)
    var file = NSString.init()
    try! file = NSString(contentsOfFile: filepath, encoding: String.Encoding.utf8.rawValue)
    let linefile:NSArray = file.components(separatedBy: "\n")as NSArray
    var tmp:NSString = linefile.object(at: atIndex)as! NSString
    tmp = tmp.substring(from: from) as NSString
    final = tmp.substring(to: to)
    return final
}

//Simplify the file/dictionary management using FileManager
public func easyfile(type: mytype, operation: myoperation, frompath: String, topath: String = "")-> Bool{
    switch operation {
    case myoperation.copy:
        do{
            if fileman.fileExists(atPath: topath){
                try fileManager.removeItem(atPath: topath)
            }
            try fileman.copyItem(atPath: frompath, toPath: topath)
        }catch{}
        
        if fileman.fileExists(atPath: topath){
            return true
        }
        else{
            return false
        }
        
    case myoperation.move:
        do{
            try fileManager.moveItem(atPath: frompath, toPath: topath)
        }catch{}
        
        if fileman.fileExists(atPath: topath) || !fileman.fileExists(atPath: frompath){
            return true
        }
        else{
            return false
        }
        
    case myoperation.delete:
        do{
            try fileman.removeItem(atPath: frompath)
        }
        catch{}
        
        if !fileman.fileExists(atPath: frompath){
            return true
        }
        else{
            return false
        }
        
    case myoperation.delall:
        let files:[AnyObject]? = fileman.subpaths(atPath: frompath)! as [AnyObject]
        var notdone:Int = 0
        
        for file in files!{
            do{
                try fileman.removeItem(atPath: frompath + "/\(file)")
            }catch{}
            
            if fileman.fileExists(atPath: frompath + "/\(file)"){
                notdone += 1
            }
        }
        
        if notdone == 0{
            return true
        }
        else{
            debugPrint("easyfile: \(notdone) files haven't been deleted yet.")
            return false
        }
        
    default:
        return false
    }
}

//Append all EFI partitions and find which is the hackintosh bootloader partition
public func EFIArray()-> [String]{
    var realEFIpath:[String] = [""]
    print(runscript(command: "ls /Volumes > /tmp/allmount.txt", requireroot: false))
    var file = NSString.init()
    try! file = NSString(contentsOfFile: "/tmp/allmount.txt", encoding: String.Encoding.utf8.rawValue)
    let allitem:NSArray? = file.components(separatedBy: "\n")as NSArray
    for i in allitem! {
        let path:String = i as! String
        let epath = "/Volumes/" + path + bootloader.efifile
        if fileman.fileExists(atPath: epath){
            if realEFIpath[0] == ""{
                realEFIpath[0] = "/Volumes/" + path
            }
            else{
                realEFIpath.append("/Volumes/" + path)
            }
        }
    }
    return realEFIpath
}

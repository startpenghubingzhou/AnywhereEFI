//
//  efimounter.swift
//  AnywhereEFI
//
//  Created by penghubingzhou on 2019/11/27.
//  Copyright © 2019 penghubingzhou. All rights reserved.
//

import Foundation

let fileManager = FileManager.default
let path:String = "/tmp/efitemp.txt"
var ismounted:[Bool] = [true]

//Get EFI information
private func getdiskutil()->String{
    let result = shell(["diskutil", "list"])
    return result
}

//Get full locations of all EFI partitions
private func getlocations()->[String]{
    let temp = getdiskutil()
    let efiList:[String]? = temp.components(separatedBy: "\n") //Load information in line one by one
    var partitions:[String]? = []
    var locations:[String]? = []
    
    //Determine to add EFI partition to append list
    for i in efiList!{
        if i.contains("EFI"){
            let cut = String(i[i.index(i.startIndex,offsetBy: 29)..<i.index(i.startIndex,offsetBy: 32)])
            if cut == "EFI"{
                partitions?.append(i)
            }
        }
    }
    
    //Add full location of EFI partition
    for i in partitions!{
        let identifier = String(i[i.index(i.startIndex,offsetBy: 68)..<i.index(i.startIndex,offsetBy: 75)])
        locations?.append("/dev/" + identifier)
    }
    
    //Detect if there's any EFI partition in computer,return EFI list if exist.
    if (locations != nil){
        return locations!
    }
    else{
        print("EFIMounter:can't find any EFI partition!")
        return nil!
    }
}

//EFI mounter main function
func efimountermain(){
    let info:[String] = getlocations()
    let num = info.count
    var ret:[String] = [""]
    
    //Initial display in terminal
    print("You have \(num) EFI partition(s) in your computer.\n")
    print("====================================================")
    print("number        location        diskname ")
    
    //Append all EFI partitons and then display it
    for i in 0..<num {
        let detailInfo = getDiskInfo(path: info[i])
        print("\(i+1)             \(info[i])    \(detailInfo["Device / Media Name"] ?? "unknown")")
    }
    
    //Ready to mount EFI partiton
    print("Please input the number you want to mount, or input 0 to mount all:")
    let userInput = mustberightnum(Lbound: 0, Ubound: num)
    if userInput > num || userInput < 0{
        print("Incorrect input! Please try again:")
        efimountermain()
    }
    else if userInput != 0{
        let tmp = runscript(command: "/usr/sbin/diskutil mount \(info[userInput-1])", requireroot: true)
        ret[0] = tmp
    }
    else{
        for i in 0..<num{
            let tmp = runscript(command: "/usr/sbin/diskutil mount \(info[i])", requireroot: true)
            if i == 0{
                ret[0] = tmp
            }
            else{
                ret.append(tmp)
            }
        }
    }
    
    //Test if it mounted EFI successfully, then write the state
    for i in 0..<ret.count {
        let l = ret[i]
        let temp = String(l[l.index(l.endIndex, offsetBy: -15)..<l.index(l.endIndex, offsetBy: -1)])
        
    /*The test String must be inserted with "\0". By setting a breakpoint in the variable of "temp" , I noticed that it seems Swift made an mistake when recognizing the word "mounted". To avoid that, I have to put "\0" into this code. Can't figure out whether this is a bug of Swift 4. --by penghubingzhou */
        
        if temp != "\0m\0o\0u\0n\0t\0e\0d"{
            print("EFI in \(info[i]) was mounted failed, which the reason is \(temp)")
            if i == 0{
                ismounted[i] = false
            }
            else{
                ismounted.append(false)
            }
        }
        else{
            if i != 0{
                ismounted.append(true)
            }
        }
    }
    
    for i in 0...ismounted.endIndex{
        if ismounted[i] == false{
            print("One or more EFI partitions was mounted failed!")
            break
        }
        else{
            print("EFI partition(s) you selected were mounted successfully.")
            break
        }
    }
    print("Press any key to continue.")
    let _ = getkeyboard()
    forinit()
}

// Get disk info
// path: dev/disk0
func getDiskInfo(path: String) -> [String:String] {
    // dev/disk0s11 ---> dev/disk0
    func findDiskPath() -> String { //Temporary solution
        let reg = "^/dev/disk[0-9]+"
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: reg, options: [])
        let matches = regex.matches(in: path, options: [], range: NSMakeRange(0, path.count))
        guard matches.count > 0 else { return "" }
        
        let p = (path as NSString).substring(with: matches.first!.range)
        return p
    }

    let result = shell(["diskutil", "info", findDiskPath()])
    
    // "*** \n ** \n **" ----> [["**"], ["*"], .....]
    let resRows = result.split(separator: "\n")
    var info: [String: String] = [String:String]()
    for row in resRows {
        let res = row.split(separator: ":")
        let key = String(res.first ?? "").trimmingCharacters(in: CharacterSet.whitespaces)
        let value = String(res.last ?? "").trimmingCharacters(in: CharacterSet.whitespaces)
        info[key] = value
    }
    return info
}

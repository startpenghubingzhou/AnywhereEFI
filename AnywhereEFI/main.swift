//
//  main.swift
//  AnywhereEFI
//
//  Created by penghubingzhou on 2019/11/25.
//  Copyright © 2019 penghubingzhou. All rights reserved.
//
import Foundation

let cr:String = "Clover"
let oc:String = "OpenCore"
var bootloader = (name: "", path: "", efifile: "")
var proxyprotocol:String = ""
var proxyURL:String = ""
var args = CommandLine.arguments

//Main function, for initialization in terminal
func forinit() {
    print("AnywhereEFI written by penghubingzhou\n")
    print("====================================================\n")
    //Press a key to choose which to use
    print("1.Mount EFI Partition")
    print("2.Backup EFI")
    print("3.Update EFI")
    print("4.Exit")
    print("Please input the number you want to do:")
    
    //Jump to the function with number choice
    let val1:Int = mustberightnum(Lbound: 1, Ubound: 4)
    switch val1 {
    case 1:
        efimountermain()
    case 2:
        efibackupmain()
    case 3:
        efiupdatermain()
    case 4:
        print("Thanks for using, good bye!")
        forexit()
    default:
        break
    }
}

//Some work to clean temp files
func forexit(){
    if fileman.fileExists(atPath: tempdir){
        let _ = easyfile(type: mytype.dict, operation: myoperation.delete, frompath: tempdir)
    }
    
    if fileman.fileExists(atPath: "/tmp/\(bootloader.name).txt"){
        let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: "/tmp/\(bootloader.name).txt")
    }
    
    if fileman.fileExists(atPath: bootloader.path){
        let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: bootloader.path)
    }
    
    if fileman.fileExists(atPath: "tmp/allmount.txt"){
        let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: "tmp/allmount.txt")
    }
    
    exit(0)
}

//Show usage
func usage(){
    print("Usage: AnywhereEFI <-protocol [proxy]> <-url [proxyURL]>")
    print("<-protocol [proxy]>: Your proxy protocol for curl(Using in EFI Update). [proxy] is your protocol(socks, socks5...)")
    print("<-url [proxyURL]>: Your proxy URL. [proxyURL] is your URL for proxy(including ports).")
    forexit()
}

//Main function, get proxy protocol and URL for curl
func main(){
    switch args.count {
    case 5:
        if args[1] != "-protocol" || args[3] != "-url"{
            print("AnywhereEFI: bad arguments!")
            usage()
        }
        else{
            proxyprotocol = "--" + args[2]
            proxyURL = args[4]
            forinit()
        }
        
    case 1:
        forinit()
        
    default:
        print("AnywhereEFI: bad arguments!")
        usage()
    }
}

main()

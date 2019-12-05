//
//  efiupdater.swift
//  AnywhereEFI
//
//  Created by penghubingzhou on 2019/11/27.
//  Copyright © 2019 penghubigzhou. All rights reserved.
//

import Foundation

let tempdir:String = "/tmp/efithistemp"
let bootfile = "/EFI/BOOT/BOOTX64.efi"
var efioperate:String = ""
var bootloader = (name: "", path: "", efifile: "")

//Get bootloader type
private func getboottype()->(name:String, path:String, efifile: String){
    var bloadername:String = ""
    var bloaderpath:String = ""
    var befifile:String = ""
    
    print("Please choose your bootloader")
    print("1.\(cr)")
    print("2.\(oc)")
    print("Enter your choice to continue:")
    let val0:Int = mustberightnum(Lbound: 1, Ubound: 2)
    switch val0 {
    case 1:
        bloadername = cr
        bloaderpath = "/tmp/Clover.pkg"
        befifile = "/EFI/CLOVER/CLOVERX64.efi"
    default:
        bloadername = oc
        bloaderpath = "/tmp/OpenCore.zip"
        befifile = "/EFI/OC/OpenCore.efi"
    }
    return (bloadername, bloaderpath, befifile)
}

//Get the latest version of Clover and download URL
private func getlatest ()->(URL:String,verison:String){
    var url = String(describing: String.Encoding.utf8)
    var ver:String = ""
    //Judge bootloader
    url = ""
    if bootloader.name == cr{
        url = "https://api.github.com/repos/Dids/clover-builder/releases"
    }
    else if bootloader.name == oc{
        url = "https://api.github.com/repos/williambj1/OpenCore-Factory/releases"
    }
    
    print("Getting the latest version of \(bootloader.name)……")
    
   print(shell(["/usr/bin/curl", "-s", "-o", "/tmp/\(bootloader.name).txt", url]))
    
    if bootloader.name == cr {
        url = loadfromfile(filepath: "/tmp/\(bootloader.name).txt", atIndex: 136, from: 33, to: 91)
        ver = String(url[url.index(url.startIndex,offsetBy: 64)..<url.index(url.startIndex,offsetBy: 68)])
    }
    else if bootloader.name == oc{
        url = loadfromfile(filepath: "/tmp/\(bootloader.name).txt", atIndex: 68, from: 33, to: 100)
        ver = String(url[url.index(url.startIndex,offsetBy: 85)..<url.index(url.startIndex,offsetBy: 90)])
    }
    print(url,ver)
    return (url, ver)
}

//Download the latest bootloader and then update the native bootloader
private func downloadandupdate(url:String)-> Bool{
    print("\nDownloading the latest version of \(bootloader.name)……")
   // let ret = runscript(command:"/usr/bin/curl -L --socks5 127.0.0.1:1081 -# -o \(bootloader.path) \(url)", requireroot: false)
    let ret = shell(["/usr/bin/curl", "-L", "-o", "\(bootloader.path)", "--socks5", "127.0.0.1:1081", "-#", url])
    if ret != ""{
        print("Download failed, please try later. Press any key to continue")
        let _ = getkeyboard()
        forinit()
    }
    else{
        if bootloader.name == cr{
            
            let _ = shell(["mkdir", "\(tempdir)"])
            let _ = shell(["/usr/bin/xar", "-xf", "\(bootloader.path)", "-C", tempdir])
            print(runscript(command:"/usr/bin/tar xf \(tempdir)/EFIFolder.pkg/Payload -C \(tempdir)", requireroot: false))
        }
        else if bootloader.name == oc{
            let _ = shell(["/usr/bin/unzip","-q", "\(bootloader.path)", "-d", tempdir])
        }
    }
    
    /* Everything for prepareration has been done, now we will start updating. First, we should get the EFI location that we want to update, then we will call "easyfile" API to operate it. */
    let bootloaderEFIlocation:[String] = EFIArray()
    if bootloaderEFIlocation == [""]{
        print("Can't get any one EFI partiton which has \(bootloader.name) bootloader! Please try to remount EFI partiton.")
        print("Press any key to return...")
        let _ = getkeyboard()
        forinit()
    }
    else if bootloaderEFIlocation.count != 1{
        print("You have \(bootloaderEFIlocation.count) EFI partions with bootloader \(bootloader.name). Please select the one you want to update:" )
        for i in bootloaderEFIlocation{
            print(i)
        }
        let key = mustberightnum(Lbound: bootloaderEFIlocation.startIndex, Ubound: bootloaderEFIlocation.endIndex)
        for i in bootloaderEFIlocation.endIndex...bootloaderEFIlocation.endIndex{
            if i == key{
                efioperate = bootloaderEFIlocation[i]
            }
        }
    }
    else{
        efioperate = bootloaderEFIlocation[0]
    }
    
    //Now it's the time we should update EFI.
    var myresult:[Bool] = Array(repeating: false, count: 4)
    print("Deleting old \(bootloader.name) files...")
    
    myresult[0] = easyfile(type: mytype.file, operation: myoperation.delete, frompath: efioperate + bootloader.efifile)
    myresult[1] = easyfile(type: mytype.dict, operation: myoperation.delete, frompath: efioperate + bootfile)
    
    print("Copying new \(bootloader.name) files...")
    
    myresult[2] = easyfile(type: mytype.file, operation: myoperation.copy, frompath: tempdir + bootloader.efifile, topath: efioperate + bootloader.efifile)
    myresult[3] = easyfile(type: mytype.dict, operation: myoperation.copy, frompath: tempdir + bootfile, topath: efioperate + bootfile)
    
    
    
    if myresult[1] == false || myresult[0] == false{
        print("Deleting old \(bootloader.name) files failed!")
        return false
    }
    else if myresult[1] == false || myresult[0] == false{
        print("Copying new \(bootloader.name) files failed!")
        return false
    }
    else{
        return true
    }
}

//Main function
func efiupdatermain(){
    bootloader = getboottype()
    let array = getlatest()
    print("The latest version of \(bootloader.name) is \(array.verison), would you like to update?(Y/N)")
    let get:String = getkeyboard()
    if get == "Y" || get == "y"{
        if downloadandupdate(url: array.URL) == false{
            print("Update failed, press any key to go back.")
        }
        else{
            print("Your \(bootloader.name) bootloader has been updated successfully, press any key to go back.")
        }
        let _ = getkeyboard()
        forinit()
    }
    else if get == "N" || get == "n"{
        forinit()
    }
    else{
        print("Incorrect input! Please try again.")
        efiupdatermain()
    }
}



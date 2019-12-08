//
//  efibackup.swift
//  AnywhereEFI
//
//  Created by penghubingzhou on 2019/12/4.
//  Copyright © 2019 penghubingzhou. All rights reserved.
//

import Foundation

let targetdir:String = ProcessInfo.processInfo.environment["HOME"]! + "/Desktop/EFI-backup"

func efibackup(path:String)-> Bool{
    var funcret:Bool = false
    
    //Set a closure to handle rename and delete exist dictionary in desktop
    var myget:Int{
        let get:String = getkeyboard()
        let ret:Int?
        if get == "R" || get == "r"{
            let thisret = easyfile(type: mytype.dict, operation: myoperation.delete, frompath: targetdir)
            if thisret == true{
                ret = 0
            }
            else{
                ret = 1
            }
        }
        else if get == "D" || get == "d"{
            print("please write new name of exist dir(can't be EFI-backup), then press enter:")
            let newpath:String = ProcessInfo.processInfo.environment["HOME"]! + "/Desktop/" + getkeyboard()
            let thisret = easyfile(type: mytype.dict, operation: myoperation.move, frompath: targetdir, topath: newpath)
            if thisret == true{
                ret = 0
            }
            else{
                ret = 2
            }
        }
        else{
            print("Incorrect input! Please try again.")
            return 9
        }
        return ret!
    }
    
    if fileman.fileExists(atPath: targetdir){
        print("Destination folder already exists, would you like to rename to other or delete it?[R/D]")
        
        //Set a endless cycle to test if get correct input
        while true {
            if myget == 9{
                continue
            }
            else{
                break
            }
        }
    
        switch myget{
        case 0:
            funcret = easyfile(type: mytype.dict, operation: myoperation.copy, frompath: path, topath: targetdir)
        case 1:
            print("Deleting exist dir failed!")
            funcret = false
        case 2:
            print("Renaming exist dir failed!")
            funcret = false
        default:
            break
        }
    }
    else{
        funcret = easyfile(type: mytype.dict, operation: myoperation.copy, frompath: path, topath: targetdir)
    }
    
    return funcret
}

func efibackupmain(){
    if bootloader == ("", "", ""){
        bootloader = getboottype()
    }
    
    efioperate = chooseefi()
    
    print("Your EFI is located in:\(efioperate)")
    print("Your EFI will backup in Desktop/EFI, would you like to continue?[Y/N]")
    let get1:String = getkeyboard()
    
    if get1 == "Y" || get1 == "y"{
        
        let ret = efibackup(path: efioperate)
        
        if ret == true{
            let _ = shell(["open", targetdir])
            print("Your \(bootloader.name) EFI has been backed up. Now please check it.")
        }
        else{
            print("Your \(bootloader.name) EFI was backed up failed.")
        }
        
        print("Press any key to continue...")
        let _ = getkeyboard()
        forinit()
        
    }
    else if get1 == "N" || get1 == "n"{
        forinit()
    }
    else{
        print("Incorrect input! Please try again.")
        efibackupmain()
    }
}

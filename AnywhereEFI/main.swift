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

//Initialization in terminal
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
        print("For testing, coming soon! Press any key to return.")
        let _ = getkeyboard()
        forinit()
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
    let _ = easyfile(type: mytype.dict, operation: myoperation.delete, frompath: tempdir)
    let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: "/tmp/\(bootloader.name).txt")
    let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: bootloader.path)
    let _ = easyfile(type: mytype.file, operation: myoperation.delete, frompath: "tmp/allmount.txt")
    exit(0)
}

//Main function
func main(){
    
    forinit()
}

main()

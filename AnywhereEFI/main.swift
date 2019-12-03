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
        exit(0)
    default:
        break
    }
}

//Main function
func main(){
    bootloader = getboottype()
    forinit()
}

main()

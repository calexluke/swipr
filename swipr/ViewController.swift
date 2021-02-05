//
//  ViewController.swift
//  swipr
//
//  Created by Alex Luke on 2/5/21.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var leftSwitch: UISwitch!
    @IBOutlet var rightSwitch: UISwitch!
    
    var switches = [Int: String]()
    
    var device1State = 0 {
        didSet {
            reportState()
        }
    }
    var device2State = 0 {
        didSet {
            reportState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO: load device states from user defaults
        
        switches = [0: "Left Switch", 1: "Right Switch"]
        
        leftSwitch.tintColor = UIColor.lightGray
        leftSwitch.backgroundColor = UIColor.lightGray
        leftSwitch.layer.cornerRadius = 16

        rightSwitch.tintColor = UIColor.lightGray
        rightSwitch.backgroundColor = UIColor.lightGray
        rightSwitch.layer.cornerRadius = 16

    }

    @IBAction func flippedSwitch(_ sender: UISwitch) {
        if sender.tag == 0 {
            device1State = sender.isOn ? 1 : 0
        } else {
            device2State = sender.isOn ? 1 : 0
        }
        
        // TO DO: Save device states from user defaults
    }
    
    func reportState() {
        print("System State: \(device1State)\(device2State)")
    }
    
    
}


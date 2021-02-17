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
    
    var isConnectedToDevice = true
    
    var firstDeviceState = 0 {
        didSet { reportState() }
    }
    var secondDeviceState = 0 {
        didSet { reportState() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO: load device states from user defaults
        
        configureUI()

    }

    @IBAction func flippedSwitch(_ sender: UISwitch) {
        
        if isConnectedToDevice {
            
            // TO DO: Save device states to user defaults
            if sender.tag == 0 {
                // switch 1
                firstDeviceState = sender.isOn ? 1 : 0
            } else {
                // switch 2
                secondDeviceState = sender.isOn ? 1 : 0
            }
            
        } else {
            leftSwitch.isOn = false
            rightSwitch.isOn = false
            showAlert(title: "Not connected to device!", message: nil)
        }
    }
    
    func reportState() {
        // eventually will send state instruction over bluetooth
        print("System State: \(firstDeviceState)\(secondDeviceState)")
    }
    
    @objc func scanForDevices() {
        
        // to do: scan for bluetooth devices
        
        // show user alert
        showAlert(title: "Connected to bluetooth device", message: nil)
        isConnectedToDevice = true
    }
    
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scanForDevices))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            
        leftSwitch.tintColor = UIColor.lightGray
        leftSwitch.backgroundColor = UIColor.lightGray
        leftSwitch.layer.cornerRadius = 16
        view.bringSubviewToFront(leftSwitch)

        rightSwitch.tintColor = UIColor.lightGray
        rightSwitch.backgroundColor = UIColor.lightGray
        rightSwitch.layer.cornerRadius = 16
        view.bringSubviewToFront(rightSwitch)
    }
    
    
}


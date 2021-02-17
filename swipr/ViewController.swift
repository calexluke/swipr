//
//  ViewController.swift
//  swipr
//
//  Created by Alex Luke on 2/5/21.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var leftSwitch: UISwitch!
    @IBOutlet var rightSwitch: UISwitch!
    
    // constants from HM-10 datasheet
    let swiprServiceID = "FFE0"
    let swiprCharacteristicID = "FFE1"
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    // 0: OFF, 1: ON. Coded as binary integers to simplify commands to HM-10
    var firstDeviceState = 0
    var secondDeviceState = 0
    
    let defaults = UserDefaults.standard
    
    enum barButtonMode {
        case scan;
        case disconnect;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load device states from user defaults
        firstDeviceState = defaults.integer(forKey: "firstDeviceState")
        secondDeviceState = defaults.integer(forKey: "secondDeviceState")
        
        configureUI()
        configureSwipeRecognizers()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // attempt to make bluetooth connection
        if centralManager.state == .poweredOn {
            scanForDevices()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func configureUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scanForDevices))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            
        leftSwitch.tintColor = UIColor.lightGray
        leftSwitch.backgroundColor = UIColor.lightGray
        leftSwitch.layer.cornerRadius = 16
        view.bringSubviewToFront(leftSwitch)
        // set switch position based on stored device state
        leftSwitch.isOn = firstDeviceState == 1 ? true : false

        rightSwitch.tintColor = UIColor.lightGray
        rightSwitch.backgroundColor = UIColor.lightGray
        rightSwitch.layer.cornerRadius = 16
        view.bringSubviewToFront(rightSwitch)
        rightSwitch.isOn = secondDeviceState == 1 ? true : false
    }
    
    func configureBarButton(mode: barButtonMode) {
        switch mode {
        case .scan:
            navigationItem.rightBarButtonItem?.title = "Scan"
            navigationItem.rightBarButtonItem?.action = #selector(scanForDevices)
        case .disconnect:
            navigationItem.rightBarButtonItem?.title = "Disconnect"
            navigationItem.rightBarButtonItem?.action = #selector(disconnectFromDevice)
        }
    }
    
    func configureSwipeRecognizers() {
        // add swipe gesture recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
        
    @IBAction func flippedSwitch(_ sender: UISwitch?) {
        
        guard connectedPeripheral != nil else {
            // not connected to bluetooth device
            // change switch back to its prior value and don't update device state
            leftSwitch.isOn = firstDeviceState == 1 ? true : false
            rightSwitch.isOn = secondDeviceState == 1 ? true : false
            showAlert(title: "Not connected to device!", message: "Tap 'scan' and try again.")
            return
        }
        
        // update device states based on switch positions and save to user defaults
        firstDeviceState = leftSwitch.isOn ? 1 : 0
        defaults.setValue(firstDeviceState, forKey: "firstDeviceState")
        
        secondDeviceState = rightSwitch.isOn ? 1 : 0
        defaults.setValue(secondDeviceState, forKey: "secondDeviceState")
        
        writeStateToBluetoothDevice()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        // respond to swipe
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            print("Swipe location: \(swipeGesture.location(in: view))")
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                leftSwitch.setOn(true, animated: true)
                rightSwitch.setOn(true, animated: true)
                flippedSwitch(nil)
            case .left:
                print("Swiped left")
                leftSwitch.setOn(false, animated: true)
                rightSwitch.setOn(false, animated: true)
                flippedSwitch(nil)
            default:
                break
            }
        }
    }
        
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    
    
    //MARK: - CoreBluetooth methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("centralManagerDidUpdateState:")
        
        switch central.state {
        case .poweredOff:
            print("power is off")
        case .poweredOn:
            print("power is on")
            scanForDevices()
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .unsupported:
            print("unsupported")
        default:
            print("unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // found peripheral with UUID matching serviceID constant
        connectedPeripheral = peripheral
        
        if let name = peripheral.name {
            if peripheral.name == "swipr" {
                print("found peripheral named \(name)")
                askUserToConnect(peripheral: peripheral)
                centralManager.stopScan()
            } else {
                print("found peripheral named \(name)")
            }
        } else {
            print("found peripheral with unknown name")
            showAlert(title: "Could not locate device", message: "Tap 'scan' and try again.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        guard let connectedPeripheral = connectedPeripheral else {return}
        
        print("connected to \(peripheral.name!)")
        connectedPeripheral.delegate = self
        configureBarButton(mode: .disconnect)
        showAlert(title: "Connected!", message: "Swipe to turn both devices on or off together, or tap the switches to control them separately.")
        
        // goal: find the correct peripheral service using its ID, then find the service's write characteristic
        // call peripheral didDiscoverServices
        connectedPeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            print("Service count: \(services.count)")
            for service in services {
                print("Service: \(service)")
                let swiprService = service as CBService
                if swiprService.uuid == CBUUID(string: swiprServiceID) {
                    // matches service ID from HM-10 datasheet
                    // call peripheral didDiscoverCharacteristics
                    peripheral.discoverCharacteristics(nil, for: swiprService)
                }
            }
        } else {
            print("no services available")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic)
                let swiprCharacteristic = characteristic as CBCharacteristic
                if swiprCharacteristic.uuid == CBUUID(string: swiprCharacteristicID) {
                    // matches characteristic ID from HM-10 datasheet
                    writeCharacteristic = swiprCharacteristic
                }
            }
        } else {
            print("No characteristics available")
        }
    }
        
    
    func writeStateToBluetoothDevice() {
        // convert device state to data object and send over bluetooth
        let stateString = "\(firstDeviceState)\(secondDeviceState)"
        print(stateString)
       
        guard let peripheral = connectedPeripheral else {
            showAlert(title: "Error", message: "Error writing data: not connected to device")
            return
        }
        guard let characteristic = writeCharacteristic else {
            showAlert(title: "Error", message: "Error writing data: could not write to the device")
            return
        }
        
        if let stateData = stateString.data(using: String.Encoding.utf8) {
            peripheral.writeValue(stateData, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("Error converting string to data object")
        }
    }
    
    func askUserToConnect(peripheral: CBPeripheral) {
        
        let ac = UIAlertController(title: "\(peripheral.name!) Device Recognized!", message: "Do you wish to connect?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let ok = UIAlertAction(title: "OK", style: .default) {
            [weak self] _ in
            // connect to device
            self?.centralManager.connect(peripheral, options: nil)
        }
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    @objc func scanForDevices() {
        // calls centalManager didDiscover peripheral
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: swiprServiceID)], options: nil)
        print("scanning for devices")
    }
    
    @objc func disconnectFromDevice() {
        guard let peripheral = connectedPeripheral else {return}
        centralManager.cancelPeripheralConnection(peripheral)
        connectedPeripheral = nil
        showAlert(title: "Disconnected", message: "You are no longer connected to swipr. Tap 'scan' to re-connect.")
        configureBarButton(mode: .scan)
    }
    
}


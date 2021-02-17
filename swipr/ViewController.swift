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
    let serviceID = "FFE0"
    let characteristicID = "FFE1"
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    var firstDeviceState = 0 {didSet { writeStateToDevice() }}
    var secondDeviceState = 0 {didSet { writeStateToDevice() }}
    var isConnectedToDevice = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO: load device states from user defaults
        configureUI()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // attempt to make bluetooth connection
        if centralManager.state == .poweredOn {
            scanForDevices()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // close bluetooth connection
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
            // not connected to bluetooth device
            leftSwitch.isOn = false
            rightSwitch.isOn = false
            showAlert(title: "Not connected to device!", message: "Tap 'scan' and try again.")
        }
    }
    
    
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    
    func writeStateToDevice() {
        // eventually will send state instruction over bluetooth
        let stateString = "\(firstDeviceState)\(secondDeviceState)"
        print(stateString)
        let data = stateString  .data(using: String.Encoding.utf8)
        
        if let peripheral = connectedPeripheral {
            if let characteristic = writeCharacteristic {
                peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("Error writing data: wrote characteristic is nil")
            }
        } else {
            print("Error writing data: not connected to device")
        }
    }
    
    @objc func scanForDevices() {
        // calls centalManager didDiscover peripheral
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: serviceID)], options: nil)
        print("scanning for devices")
    }
    
    func hasConnected() {
        
    }
    
    //MARK: - CoreBluetooth methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("centralManagerDidUpdateState started")
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
        
        // To do: update nav bar for disconnect option
        
        print("connected to \(peripheral.name!)")
        isConnectedToDevice = true
        connectedPeripheral.delegate = self
        
        // calls peripheral didDiscoverServices
        connectedPeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            print("Service count: \(services.count)")
            for service in services {
                print("Service: \(service)")
                let swiprService = service as CBService
                if swiprService.uuid == CBUUID(string: serviceID) {
                    // calls peripheral didDiscoverCharacteristics
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
                if swiprCharacteristic.uuid == CBUUID(string: characteristicID) {
                    writeCharacteristic = swiprCharacteristic
                }
            }
        } else {
            print("No characteristics available")
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
    
    
}


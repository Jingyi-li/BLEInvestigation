//
//  ViewController.swift
//  DevAppBeta
//  Initial view: for selecting and connecting to dsvSensor
//  Created by Weihang Liu on 21/7/17.
//  Copyright © 2017 Weihang Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var connectBtn: UIButton!
    @IBOutlet var DeviceListTableView: UITableView!
    var targetDeviceIndices: [Int] = [Int]()
    private var isInitialised = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.isInitialised{
            self.DeviceListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            globalVariables.BLEHandler.passMainView(view: self)
            globalVariables.appStatus = "initialised"
            self.updateStatus(value: globalVariables.appStatus)
            self.connectBtn.isEnabled = false
            self.isInitialised = true
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //scan button click event
    @IBAction func scanBtnClk(_ sender: Any) {
        //scan for all peripherals that has prefix MDM-
        globalVariables.allSensorList.removeAll()
        _ = globalVariables.BLEHandler.startScanning(timeout: 5)
    }
    
    //connect button click event
    @IBAction func connectBtnClk(_ sender: Any) {
        if self.targetDeviceIndices.count > 0 {
            globalVariables.BLEHandler.stopScanning()
            var success = true
            for i in 0...self.targetDeviceIndices.count-1{
                success = success && globalVariables.BLEHandler.connectToPeripheral(peripheral: globalVariables.BLEHandler.peripherals[self.targetDeviceIndices[i]])
            }
            if success {
                globalVariables.appStatus = "connection successful"
                
            }
            else {
                globalVariables.appStatus = "connection unsuccessful"
            }
        }
    }

    //update status label
    func updateStatus(value: String){
        print("[DEBUG] updating Status: \(value)")
        statusLabel.text = value
    }
    
    //update sensor list table
    func reloadTable(){
        print("[DEBUG] reloading table view data")
        self.DeviceListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalVariables.allSensorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.DeviceListTableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell.textLabel?.text = globalVariables.allSensorList[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.targetDeviceIndices.contains(indexPath.row){
            print("[DEBUG] remove from selected: \(self.targetDeviceIndices[(self.targetDeviceIndices as AnyObject).index(of: indexPath.row)])")
            self.targetDeviceIndices.remove(at: (self.targetDeviceIndices as AnyObject).index(of: indexPath.row))
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.white
            
        }
        else if(self.targetDeviceIndices.count < globalVariables.MaxNumOfDevice){
            print("[DEBUG] add to selected: \(globalVariables.allSensorList[indexPath.row])")
            self.targetDeviceIndices.append(indexPath.row)
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
        }
        if self.targetDeviceIndices.count > 0 {
            var statusString = "selected: "
            for i in 0...self.targetDeviceIndices.count-1{
                let sensorNameWithRssi = globalVariables.allSensorList[self.targetDeviceIndices[i]]
                let sensorName = String(sensorNameWithRssi[..<sensorNameWithRssi.index(sensorNameWithRssi.startIndex, offsetBy: 8)])
                statusString += sensorName
                statusString += " "
                if i == 1 {
                    statusString += "\n                "
                }
            }
            self.updateStatus(value: statusString)
            self.connectBtn.isEnabled = true
        }
        else {
            self.connectBtn.isEnabled = false
            self.updateStatus(value: "selected: ")
        }
    }
}


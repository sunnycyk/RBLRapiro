//
//  ViewController.swift
//  RBLRapiro
//
//  Created by Sunny Cheung on 5/11/14.
//  Copyright (c) 2014 khl. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, BLEDelegate{
    
    var str:Array<String>!
    var bleShield:BLE!
    @IBOutlet var myTable:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        str = ["Initial Position", "Move Forward", "Move Backward",
                                    "Turn Left", "Turn Right", "Give Me a Hug", "Wave Right Hand",
                                    "Move Both Arms", "Wave Left Hand", "Catch Action"]
        
        
        bleShield = BLE()
        bleShield.controlSetup()
        bleShield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectionTimer(timer:NSTimer) {
        if (bleShield.peripherals?.count > 0) {
            bleShield.connectPeripheral(bleShield.peripherals.objectAtIndex(0) as CBPeripheral)
        }
        else {
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }
    
    @IBAction func BLEShieldScan(sender:AnyObject) {
        if (bleShield.activePeripheral != nil) {
            if (bleShield.activePeripheral.state == CBPeripheralState.Connected) {
                bleShield.CM.cancelPeripheralConnection(bleShield.activePeripheral)
                return
            }
        }
        
        if (bleShield.peripherals != nil) {
            bleShield.peripherals = nil
        }
        
        bleShield.findBLEPeripherals(3)
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("connectionTimer:"), userInfo: nil, repeats: false)
        self.navigationItem.leftBarButtonItem?.enabled = false
    }
    
    // BLEDelegate
    func bleDidConnect() {
        self.navigationItem.leftBarButtonItem?.enabled=false
        self.navigationItem.leftBarButtonItem?.title = "Disonnect"
        
        NSLog("bleDidConnect")
    }
    
    func bleDidDisconnect() {
        self.navigationItem.leftBarButtonItem?.title = "Connect"
        self.navigationItem.leftBarButtonItem?.enabled = true
        
        NSLog("bleDidDisconnect")
    }
    
    func bleDidReceiveData(data: UnsafePointer<Void>, length: Int32) {
    
        
        
  //     NSData(bytesNoCopy: UInt8(data/, length: length, freeWhenDone: true)
    }

    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return str.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
        cell.textLabel.textColor = UIColor.blackColor()
        cell.textLabel.text = str[indexPath.row]
        
        return cell
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 41.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if (bleShield.activePeripheral?.state == CBPeripheralState.Connected) {
            bleShield.write(NSString(format: "%d", indexPath.row).dataUsingEncoding(NSUTF8StringEncoding))
        }
    }
}


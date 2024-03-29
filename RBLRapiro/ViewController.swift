//
//  ViewController.swift
//  RBLRapiro
//
//  Created by Sunny Cheung on 5/11/14.
//  Copyright (c) 2014 khl. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, BLEDelegate, UIAlertViewDelegate{
    
    var bundle:NSBundle!
    var str:Array<String>!
    var bleShield:BLE!
    var connectStatus:Bool = false
    @IBOutlet var myTable:UITableView!
    @IBOutlet var navItems:UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // String Keys for actions
        str = ["Initial_Position", "Move_Forward", "Move_Backward",
                                    "Turn_Left", "Turn_Right", "Give_Me_a_Hug", "Wave_Right_Hand",
                                    "Move_Both_Arms", "Wave_Left_Hand", "Catch_Action"]
        self.bundle = NSBundle.mainBundle() // base language
        // Create BLE Connection
        bleShield = BLE()
        bleShield.controlSetup()
        bleShield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // A function that will be scheduled after BLE Nano scanning for periphral
    func connectionTimer(timer:NSTimer) {
        
        if (bleShield.peripherals?.count > 0) { // we found BLE
            bleShield.connectPeripheral(bleShield.peripherals.objectAtIndex(0) as CBPeripheral)
        }
        else {  // NO BLE device found
          
            let alert:UIAlertView = UIAlertView(title: NSLocalizedString("ERROR", bundle: self.bundle, comment: "Error"), message: NSLocalizedString("DEVICE_NOT_FOUND", bundle: self.bundle, comment: "Device not found"), delegate: nil, cancelButtonTitle: "OK")

            alert.show()
            self.navItems.leftBarButtonItem?.enabled = true
        }
    }
    
    @IBAction func BLEShieldScan(sender:AnyObject) {
        
        // If there is a active periphral, cancel the connection first
        if (bleShield.activePeripheral != nil) {
            if (bleShield.activePeripheral.state == CBPeripheralState.Connected) {
                bleShield.CM.cancelPeripheralConnection(bleShield.activePeripheral)
                return
            }
        }
        
        // empty the BLE peripherals list that found in the past
        if (bleShield.peripherals != nil) {
            bleShield.peripherals = nil
        }
        
        // Start Scanning for BLE Peripheral for 3 seconds
        bleShield.findBLEPeripherals(3)
        
        // Schedule timer for 3 second later and call connectionTimer: to check if any peripheral is found
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("connectionTimer:"), userInfo: nil, repeats: false)
        
        self.navItems.leftBarButtonItem?.enabled = false
    }
    
    @IBAction func config() {
        var message:UIAlertView = UIAlertView(title: NSLocalizedString("Language", bundle: self.bundle, comment: "Language"), message: NSLocalizedString("Choose_Language", bundle: self.bundle, comment: "Choose Language"), delegate: self, cancelButtonTitle: nil, otherButtonTitles: "English", "中文", "日本語")
        message.show()
    }
    
    // Change locale for UI
    func changeLang(lang:String) {
        self.bundle = NSBundle(path: NSBundle.mainBundle().pathForResource(lang, ofType: "lproj")!)
        self.myTable.reloadData()
       
        if (!self.connectStatus) {
            self.navItems.leftBarButtonItem!.title = NSLocalizedString("CONNECT", bundle: self.bundle, comment: "Connect")
        }
        else {
            self.navItems.leftBarButtonItem!.title = NSLocalizedString("DISCONNECT", bundle: self.bundle, comment: "Disconnect")
        }
       // self.navItems.rightBarButtonItem!.title = NSLocalizedString("Language", bundle: self.bundle, comment: "Language")
        
    }
    
    // BLEDelegate
    func bleDidConnect() {
        self.navItems.leftBarButtonItem!.enabled=true
        self.navItems.leftBarButtonItem!.title = NSLocalizedString("DISCONNECT", bundle: self.bundle, comment: "Disconnect")
        self.connectStatus = true
        NSLog("bleDidConnect")
    }
    
    func bleDidDisconnect() {
        self.navItems.leftBarButtonItem?.enabled = true
        self.navItems.leftBarButtonItem?.title = NSLocalizedString("CONNECT", bundle: self.bundle, comment: "Connect")
        self.connectStatus = false
        NSLog("bleDidDisconnect")
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
        var s:NSString! = NSString(bytes: data, length: Int(length), encoding: NSUTF8StringEncoding)
        data.destroy()
        NSLog(s!)
    }

    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return str.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
      
        cell.textLabel.textColor = UIColor.blackColor()
        cell.textLabel.text = NSLocalizedString(  str[indexPath.row], bundle: self.bundle, comment:  str[indexPath.row])
        return cell
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 41.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if (bleShield.activePeripheral?.state == CBPeripheralState.Connected) {
            bleShield.write(NSString(format: "#M%d", indexPath.row).dataUsingEncoding(NSUTF8StringEncoding))
        }
    }
    
    // UIAlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch(buttonIndex) {
        case 0: self.changeLang("en")
        case 1: self.changeLang("zh-Hant")
        case 2: self.changeLang("ja")
        default: self.changeLang("en")
        }
        
        
    }

}


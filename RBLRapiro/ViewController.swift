//
//  ViewController.swift
//  RBLRapiro
//
//  Created by Sunny Cheung on 5/11/14.
//  Copyright (c) 2014 khl. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, BLEDelegate{
    
    var lang:String = "en"
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
            let alert:UIAlertView = UIAlertView(title: "Error", message: "No BLE Device(s) found.", delegate: nil, cancelButtonTitle: "OK")
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
    
    // Change locale for UI
    func changeLang(lang:String) {
        self.lang = lang
        var bundle:NSBundle! = NSBundle(path: NSBundle.mainBundle().pathForResource(self.lang, ofType: "lproj")!)
        self.myTable.reloadData()
       
        if (!self.connectStatus) {
            self.navItems.leftBarButtonItem!.title = NSLocalizedString("CONNECT", bundle: bundle, comment: "Connect")
        }
        else {
            self.navItems.leftBarButtonItem!.title = NSLocalizedString("DISCONNECT", bundle: bundle, comment: "Disconnect")
        }
        self.navItems.rightBarButtonItem!.title = NSLocalizedString("Language", bundle: bundle, comment: "Language")
        
    }
    
    // BLEDelegate
    func bleDidConnect() {
        var bundle:NSBundle! = NSBundle(path: NSBundle.mainBundle().pathForResource(self.lang, ofType: "lproj")!)
        self.navItems.leftBarButtonItem!.enabled=true
        self.navItems.leftBarButtonItem!.title = NSLocalizedString("DISCONNECT", bundle: bundle, comment: "Disconnect")
        self.connectStatus = true
        NSLog("bleDidConnect")
    }
    
    func bleDidDisconnect() {
        var bundle:NSBundle! = NSBundle(path: NSBundle.mainBundle().pathForResource(self.lang, ofType: "lproj")!)
        self.navItems.leftBarButtonItem?.enabled = true
        self.navItems.leftBarButtonItem?.title = NSLocalizedString("CONNECT", bundle: bundle, comment: "Connect")
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
        
        var bundle:NSBundle! = NSBundle(path: NSBundle.mainBundle().pathForResource(self.lang, ofType: "lproj")!)
        cell.textLabel.textColor = UIColor.blackColor()
        cell.textLabel.text = NSLocalizedString(  str[indexPath.row], bundle: bundle, comment:  str[indexPath.row])
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


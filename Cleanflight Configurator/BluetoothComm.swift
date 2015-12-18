//
//  BluetoothComm.swift
//  Cleanflight Configurator
//
//  Created by Raphael Jean-Leconte on 09/12/15.
//  Copyright © 2015 Raphael Jean-Leconte. All rights reserved.
//

import UIKit
import SVProgressHUD

class BluetoothComm : NSObject, CommChannel, BluetoothDelegate {
    let btManager : BluetoothManager
    var peripheral: BluetoothPeripheral
    let msp: MSPParser
    let btQueue: dispatch_queue_t
    
    private var _closed = false
    
    init(withBluetoothManager btManager: BluetoothManager, andPeripheral peripheral: BluetoothPeripheral, andMSP msp: MSPParser) {
        self.btManager = btManager
        self.peripheral = peripheral
        self.msp = msp
        self.btQueue = btManager.btQueue
        super.init()
        msp.commChannel = self
    }
    
    func flushOut() {
        objc_sync_enter(self.msp)
        let data = [UInt8](msp.outputQueue)
        msp.outputQueue.removeAll()
        objc_sync_exit(self.msp)
        
        dispatch_async(btQueue, {
            //NSLog("BluetoothComm.flushOut %d", data[4])
            self.btManager.writeData(self.peripheral, data: data)
        })
    }
    
    func close() {
        _closed = true
        btManager.disconnect(peripheral)
        msp.cancelRetries()
    }
    
    // MARK: BluetoothDelegate
    func foundPeripheral(peripheral: BluetoothPeripheral) {
    }
    
    func stoppedScanning() {
    }
    
    func connectedPeripheral(peripheral: BluetoothPeripheral) {
        self.peripheral = peripheral
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: SVProgressHUDDidTouchDownInsideNotification, object: nil)
            SVProgressHUD.dismiss()
        })
    }
    func failedToConnectToPeripheral(peripheral: BluetoothPeripheral, error: NSError?) {
        // Same process
        disconnectedPeripheral(peripheral)
    }
    
    func disconnectedPeripheral(peripheral: BluetoothPeripheral) {
        if !_closed {
            dispatch_async(dispatch_get_main_queue(), {
                if !SVProgressHUD.isVisible() {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userCancelledReconnection", name: SVProgressHUDDidTouchDownInsideNotification, object: nil)
                    SVProgressHUD.showWithStatus("Connection lost. Reconnecting...", maskType: .Black)
                }
            })
            btManager.connect(peripheral)
        }
    }
    
    func userCancelledReconnection() {
        close()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SVProgressHUDDidTouchDownInsideNotification, object: nil)
        SVProgressHUD.dismiss()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func receivedData(peripheral: BluetoothPeripheral, data: [UInt8]) {
        msp.read(data)
    }
    
}
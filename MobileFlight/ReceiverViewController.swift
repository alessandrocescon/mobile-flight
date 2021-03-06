//
//  ReceiverViewController.swift
//  Mobile Flight
//
//  Created by Raphael Jean-Leconte on 04/12/15.
//  Copyright © 2015 Raphael Jean-Leconte. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit

class ReceiverViewController: UITableViewController {
    
    let colors = [UIColor(hex6: 0xf1453d), UIColor(hex6: 0x673fb4), UIColor(hex6: 0x2b98f0), UIColor(hex6: 0x1fbcd2),
        UIColor(hex6: 0x159588), UIColor(hex6: 0x50ae55), UIColor(hex6: 0xcdda49), UIColor(hex6: 0xfdc02f),
        UIColor(hex6: 0xfc5830), UIColor(hex6: 0x785549), UIColor(hex6: 0x9e9e9e), UIColor(hex6: 0x617d8a),
        UIColor(hex6: 0xcf267d), UIColor(hex6: 0x7a1464), UIColor(hex6: 0x3a7a14), UIColor(hex6: 0x14407a)]
    var receiverEventHandler: Disposable?

    func receivedReceiverData() {
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        receiverEventHandler = msp.receiverEvent.addHandler(self, handler: ReceiverViewController.receivedReceiverData)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        receiverEventHandler?.dispose()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Receiver.theReceiver.activeChannels
        } else {
            return 1
        }
    }
    
    class func channelLabel(_ i: Int) -> String {
        switch i {
        case 0:
            return "Roll"
        case 1:
            return "Pitch"
        case 2:
            return "Yaw"
        case 3:
            return "Throttle"
        default:
            return String(format: "AUX %d", i - 3)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "ConfigCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        let channelNum = indexPath.row
        cell.channelView.label = ReceiverViewController.channelLabel(channelNum)
        cell.channelView.color = channelNum >= colors.count ? colors[colors.count - 1] : colors[channelNum]
        cell.channelView.setValue(Receiver.theReceiver.channels[channelNum])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
}

class ChannelCell : UITableViewCell {
    @IBOutlet weak var channelView: ReceiverChannel!
    
}

extension UIColor {
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

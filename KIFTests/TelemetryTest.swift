//
//  FirstTest.swift
//  Cleanflight Configurator
//
//  Created by Raphael Jean-Leconte on 24/02/16.
//  Copyright © 2016 Raphael Jean-Leconte. All rights reserved.
//

import XCTest
import KIF
@testable import Cleanflight_Configurator

class TelemetryTest : XCTestCase {
    static var simulatorStarted = false
    
    override func setUp() {
        super.setUp()
        
        if !TelemetryTest.simulatorStarted {
            XCTAssert(CleanflightSimulator.instance.start(), "Cannot start CleanflightSimulator")
            TelemetryTest.simulatorStarted = true
        }
    }
    
    override func tearDown() {
        CleanflightSimulator.instance.resetValues()
        disconnect()
        
        super.tearDown()
    }
    
    private func connect() {
        tester().tapViewWithAccessibilityLabel("Wi-Fi")
        tester().clearTextFromAndThenEnterText("127.0.0.1", intoViewWithAccessibilityIdentifier: "ipAddress")
        tester().clearTextFromAndThenEnterText("8777", intoViewWithAccessibilityIdentifier: "ipPort")
        tester().tapViewWithAccessibilityIdentifier("connect")
        
        tester().waitForViewWithAccessibilityLabel("menuw 1")
    }
    
    private func disconnect() {
        // Disconnect from simulator
        if UIApplication.sharedApplication().keyWindow!.accessibilityElementWithLabel("Wi-Fi") == nil {
            tester().tapViewWithAccessibilityLabel("menuw 1")
            tester().tapViewWithAccessibilityLabel("Disconnect")
            tester().waitForTappableViewWithAccessibilityLabel("Wi-Fi")
        }
    }
    
    func testConnectDisconnect() {
        connect()
        tester().tapViewWithAccessibilityLabel("menuw 1")
        tester().tapViewWithAccessibilityLabel("Disconnect")
        tester().waitForTappableViewWithAccessibilityLabel("Wi-Fi")
    }
    
    func testRssi() {
        connect()
        
        CleanflightSimulator.instance.rssi = 676    // 676 / 1023 = 66%
        
        tester().waitForViewWithAccessibilityLabel("66%")
    }

    func testBatteryIndicators() {
        connect()
        
        CleanflightSimulator.instance.voltage = 12.3
        tester().waitForViewWithAccessibilityLabel("12.3")
        
        CleanflightSimulator.instance.amps = 21.0
        tester().waitForViewWithAccessibilityLabel("21")
        
        CleanflightSimulator.instance.mAh = 982
        tester().waitForViewWithAccessibilityLabel("982")
    }

    func testFlightModes() {
        connect()

        tester().waitForViewWithAccessibilityLabel("DISARMED")

        tester().waitForAbsenceOfViewWithAccessibilityIdentifier("acroMode")
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier("altMode")
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier("posMode")
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier("headingMode")
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier("failsafeMode")
        
        // Arm
        CleanflightSimulator.instance.setMode(.ARM)
        
        tester().waitForAbsenceOfViewWithAccessibilityLabel("DISARMED")
        tester().waitForViewWithAccessibilityLabel("ARMED")
        tester().waitForAbsenceOfViewWithAccessibilityLabel("ARMED")
        
        // Check that timer started by waiting for 2sec mark
        tester().waitForViewWithAccessibilityLabel("00:02")
        
        // Horizon / Angle
        CleanflightSimulator.instance.setMode(.HORIZON)
        tester().waitForViewWithAccessibilityLabel("HOZN")
        
        CleanflightSimulator.instance.setMode(.ANGLE)
        tester().waitForAbsenceOfViewWithAccessibilityLabel("HOZN")
        tester().waitForViewWithAccessibilityLabel("ANGL")
        
        // Pos
        CleanflightSimulator.instance.setMode(.GPSHOLD)
        tester().waitForViewWithAccessibilityLabel("POS")
        CleanflightSimulator.instance.setMode(.GPSHOME)
        tester().waitForAbsenceOfViewWithAccessibilityLabel("POS")
        tester().waitForViewWithAccessibilityLabel("RTH")
        
        // Alt
        let sonarButton = tester().waitForViewWithAccessibilityIdentifier("sonarMode")
        XCTAssertEqual(sonarButton.tintColor, UIColor.blackColor())
        
        CleanflightSimulator.instance.setMode(.BARO)
        tester().waitForViewWithAccessibilityLabel("ALT")
        XCTAssertEqual(sonarButton.tintColor, UIColor.blackColor())
        CleanflightSimulator.instance.unsetMode(.BARO)
        tester().waitForAbsenceOfViewWithAccessibilityLabel("ALT")
        CleanflightSimulator.instance.setMode(.SONAR)
        tester().waitForViewWithAccessibilityLabel("ALT")
        XCTAssertEqual(sonarButton.tintColor, UIColor.greenColor())
        
        // Heading
        CleanflightSimulator.instance.setMode(.MAG)
        tester().waitForViewWithAccessibilityLabel("HDG")
        
        // Failsafe
        CleanflightSimulator.instance.setMode(.FAILSAFE)
        tester().waitForViewWithAccessibilityLabel("RX FAIL")
    }
    
    func testSecondaryFlightModes() {
        connect()
        doTestSecondaryFlightMode(.TELEMETRY, viewId: "telemetryMode")
        doTestSecondaryFlightMode(.CAMSTAB, viewId: "camstabMode")
        doTestSecondaryFlightMode(.CALIB, viewId: "calibrateMode")
        doTestSecondaryFlightMode(.BLACKBOX, viewId: "blackboxMode")
        doTestSecondaryFlightMode(.AUTOTUNE, viewId: "autotuneMode")
        
    }
    private func doTestSecondaryFlightMode(mode: Mode, viewId: String) {
        let view = tester().waitForViewWithAccessibilityIdentifier(viewId)
        XCTAssertEqual(view.tintColor, UIColor.blackColor())
        CleanflightSimulator.instance.setMode(mode)
        tester().waitForTimeInterval(0.3)
        XCTAssertEqual(view.tintColor, UIColor.greenColor())
        CleanflightSimulator.instance.unsetMode(mode)
        tester().waitForTimeInterval(0.3)
        XCTAssertEqual(view.tintColor, UIColor.blackColor())
    }
    
    func testIndicators() {
        connect()
        let attitude = tester().waitForViewWithAccessibilityIdentifier("attitudeIndicator") as! AttitudeIndicator2
        let heading = tester().waitForViewWithAccessibilityIdentifier("headingIndicator") as! HeadingStrip
        let altitude = tester().waitForViewWithAccessibilityIdentifier("altitudeIndicator") as! VerticalScale
        let variometer = tester().waitForViewWithAccessibilityIdentifier("variometerIndicator") as! SimpleVerticalScale
        let speed = tester().waitForViewWithAccessibilityIdentifier("speedIndicator") as! VerticalScale
        
        CleanflightSimulator.instance.roll = 15.0
        CleanflightSimulator.instance.pitch = -22.0
        CleanflightSimulator.instance.heading = 172
        
        CleanflightSimulator.instance.altitude = 32.7
        CleanflightSimulator.instance.variometer = 4.5
        
        CleanflightSimulator.instance.numSats = 5
        CleanflightSimulator.instance.speed = 8.7
        
        tester().waitForTimeInterval(0.3)
        XCTAssertEqual(attitude.roll, 15.0)
        XCTAssertEqual(attitude.pitch, -22.0)
        XCTAssertEqual(heading.heading, 172.0)
        XCTAssertEqual(altitude.currentValue, 32.7)
        XCTAssertEqual(variometer.currentValue, 4.5)
        XCTAssertEqualWithAccuracy(speed.currentValue, 8.7, accuracy: 0.1)
    }
    
    func testGPSSatsAndDTH() {
        connect()
        
        CleanflightSimulator.instance.numSats = 17
        CleanflightSimulator.instance.distanceToHome = 88
        
        tester().waitForViewWithAccessibilityLabel("17")
        tester().waitForViewWithAccessibilityLabel("289ft") // = 88m
    }
}
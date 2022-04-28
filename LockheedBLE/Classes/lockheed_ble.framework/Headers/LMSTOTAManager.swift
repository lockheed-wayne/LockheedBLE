//
//  LMSTOTAManager.swift
//  Leopard
//
//  Created by xwlsly on 2021/6/10.
//

import UIKit
import BlueSTSDK

@objc
public protocol LMSTOTAManagerDelegate {
    @objc optional func onLoadComplite(file: URL)
    @objc optional func onLoadError(file: URL)
    @objc optional func onLoadProgres(file: URL, remainingBytes: UInt)
}

@objc public class LMSTOTAManager: NSObject, BlueSTSDKFwUpgradeConsoleCallback {
    public func onLoadComplite(file: URL) {
        print("onLoadComplite")
        self.delegate?.onLoadComplite?(file: file)
    }
    
    public func onLoadError(file: URL, error: BlueSTSDKFwUpgradeError) {
        print("onLoadError")
        self.delegate?.onLoadError?(file: file)
    }
    
    public func onLoadProgres(file: URL, remainingBytes: UInt) {
        print("onLoadProgres, remainingBytes: \(remainingBytes)")
        self.delegate?.onLoadProgres?(file: file, remainingBytes: remainingBytes)
    }
    
    private var mFwUpgradeConsole:BlueSTSDKFwUpgradeConsole? = nil
    public var node:BlueSTSDKNode?
    @objc public weak var delegate: LMSTOTAManagerDelegate?
    
    @objc public static let shared = LMSTOTAManager()
    
    override init() {
    
    }
    
    @objc func updateDevice(peripheral: CBPeripheral, advertisementData: [String : Any], filePath: NSURL) {
        let mAdvertiseFilters = [BlueNRGOtaAdvertiseParser()]
        
        let firstMatch = mAdvertiseFilters.lazy.compactMap{ $0.filter(advertisementData)}.first
        
        if let info = firstMatch{
            self.node = BlueSTSDKNode(peripheral, rssi: 0, advertiseInfo:info)
            self.node?.completeConnection()
            
            self.node!.addExternalCharacteristics(BlueNRGOtaUtils.getOtaCharacteristics())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.mFwUpgradeConsole = BlueSTSDKFwConsoleUtil.getFwUploadConsoleForNode(node: self.node)

            _ = self.mFwUpgradeConsole?.loadFwFile(type:BlueSTSDKFwUpgradeType.applicationFirmware,
                                                   file:filePath as URL,
                                                   delegate: self,
                                                   address: nil)
        }
    }
}

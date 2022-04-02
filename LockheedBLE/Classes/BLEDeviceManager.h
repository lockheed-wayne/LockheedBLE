//
//  BLEDeviceManager.h
//  Pods-GTBLEDevice_Example
//
//  Created by xwlsly on 2021/1/19.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDeviceBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class BLEDevice;

@protocol BLEDeviceManagerDelegate <NSObject>

//发现设备时回调
//-(void) discoverBLEDevices:(NSArray <BLEDevice *> *) devices;

////已连接设备时回调
//-(void) didConnectBLEDevice:(BLEDevice *) device;

//连接失败回调
//-(void) didFailedConnectBLEDevice:(BLEDevice *) device error:(NSError *) error;

//已成功断开连接
-(void) didDisconnectBLEDevice:(BLEDevice *) device;

@end

@class BLEDevice;
@interface BLEDeviceManager : NSObject<CBCentralManagerDelegate>

//已连接的BLE设备数组
@property (strong, nonatomic, readonly) NSMutableArray <BLEDevice *>* connectedBLEDevices;
@property (strong, nonatomic, readonly) NSMutableArray <BLEDevice *>* discoverdBLEDevices;
@property (strong, nonatomic, readonly) dispatch_queue_t queue;
@property (assign, nonatomic, nullable) id<BLEDeviceManagerDelegate> delegate;
@property (assign, nonatomic) BOOL isRetry;
//获取单例
+(instancetype) shareInstance;

//获取已连接的外设
-(nullable CBPeripheral *) retrievePeripheralWithIdentifier:(NSString *) identify;

//搜索BLE设备
-(void) scanBLEDevices:(BLEManagerFindDevice) block;

////搜索指定BLE设备
//-(void) scanBLEDevices:(BLEDevice *) device;

//停止搜索
-(void) stopScanBLEDevice;

//连接设备
-(void) connectBLEDevice:(BLEDevice *) device
                 success:(BLEManagerConnectedDevice) connectedBlock
      failedConnectBlock:(BLEManagerFailedConnectedDevice) failedConnectBlock;

//断开设备
-(void) disconnectBLEDevice:(BLEDevice *) device;

//设置当前设备
-(void) setupCurrentBLEDevice:(BLEDevice *) device;

@end

NS_ASSUME_NONNULL_END

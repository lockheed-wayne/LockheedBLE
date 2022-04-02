//
//  BLEDeviceManager.m
//  Pods-GTBLEDevice_Example
//
//  Created by xwlsly on 2021/1/19.
//

#import "BLEDeviceManager.h"
#import "BLEDevice.h"
#import "LBCocoaSecurity.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEDeviceManager (){
    CBCentralManager *_centralManager;
}

@property (nonatomic, copy) BLEManagerFindDevice scanBLEDevicesBlock;
@property (nonatomic, copy) BLEManagerConnectedDevice connectedBLEDeviceBlock;
@property (nonatomic, copy) BLEManagerFailedConnectedDevice failedConnectBLEDeviceBlock;

@end

@implementation BLEDeviceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue() options:@{
            CBCentralManagerOptionRestoreIdentifierKey:@"com.leopard"
        }];
        
        _connectedBLEDevices = [NSMutableArray arrayWithCapacity:0];
        _discoverdBLEDevices = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

+(instancetype) shareInstance{
    static BLEDeviceManager *bleDeviceManager_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleDeviceManager_ = [[BLEDeviceManager alloc]init];
    });
    
    return bleDeviceManager_;
}

//搜索BLE设备
-(void) scanBLEDevices:(BLEManagerFindDevice) block{
    _scanBLEDevicesBlock = block;
    
    [_discoverdBLEDevices removeAllObjects];

    NSLog(@"start scan device");
    
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    
//    //重连已知的设备
//    if(_connectedBLEDevices.count > 0){
//        NSMutableArray *arryDeviceUUIDs = [NSMutableArray arrayWithCapacity:_connectedBLEDevices.count];
//        
//        for(BLEDevice *d in _connectedBLEDevices){
//            [arryDeviceUUIDs addObject:d.peripheral.identifier];
//        }
//
//        NSArray *ps = [_centralManager retrievePeripheralsWithIdentifiers:arryDeviceUUIDs];
//        NSLog(@"ps: %@", ps);
//        for(CBPeripheral *p in ps){
//            if(p.state == CBPeripheralStateConnected){
//                NSLog(@"scanBLEDevices - cancelPeripheralConnection");
//
//                [_centralManager cancelPeripheralConnection:p];
//            }
//        }
//    }
}

-(nullable CBPeripheral *) retrievePeripheralWithIdentifier:(NSString *) identify{
    if(identify.length == 0){
        return nil;
    }
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:identify];
    if(!uuid)
        return nil;
    
    NSArray *mIdentifies = @[uuid];
    NSArray *ps = [_centralManager retrievePeripheralsWithIdentifiers:mIdentifies];
    
    return ps.lastObject;
}

//停止搜索
-(void) stopScanBLEDevice{
    NSLog(@"stopScanBLEDevice");
    [_centralManager stopScan];
}

//连接设备
-(void) connectBLEDevice:(BLEDevice *) device
                 success:(BLEManagerConnectedDevice) connectedBlock
      failedConnectBlock:(BLEManagerFailedConnectedDevice) failedConnectBlock;{
    _connectedBLEDeviceBlock = connectedBlock;
    _failedConnectBLEDeviceBlock = failedConnectBlock;
    
    if(![_discoverdBLEDevices containsObject:device] && device){
        [_discoverdBLEDevices addObject:device];
    }
    
    if(device.peripheral)
        [_centralManager connectPeripheral:device.peripheral options:nil];
}

//断开设备
-(void) disconnectBLEDevice:(BLEDevice *) device{
    
    NSLog(@"xw disconnectBLEDevice - cancelPeripheralConnection");
 
    [_centralManager cancelPeripheralConnection:device.peripheral];
}

#pragma mark CBCentralManagerDelegate
//CBManagerStateUnknown = 0,
//CBManagerStateResetting,
//CBManagerStateUnsupported,
//CBManagerStateUnauthorized,
//CBManagerStatePoweredOff,
//CBManagerStatePoweredOn,
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"Central Status:%ld", central.state);
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
//    NSLog(@"find  device: %@", peripheral.name);

    if([peripheral.name containsString:@"LP_B910"]){
        NSLog(@"find LP_B910 device: %@", advertisementData);
        
        LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];

        NSData *macData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];

        NSString *macString = [encoder hex:macData useLower:YES];
        
        BLEDevice *containedDevice = nil;
        for(BLEDevice *device in _discoverdBLEDevices){
            if([device.peripheral.identifier isEqual:peripheral.identifier] ||
               [device.mac isEqualToString:macString]){
                containedDevice = device;
            }
        }
        
        //如果未发现的设备，则添加到发现设备列表，并调用代理
        if(containedDevice == nil){
            BLEDevice *newDevice = [[BLEDevice alloc]initWithPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
            [_discoverdBLEDevices addObject:newDevice];
        }else{
            [containedDevice updateAdvertisementData:advertisementData RSSI:RSSI];
        }
        if(_scanBLEDevicesBlock){
            _scanBLEDevicesBlock(_discoverdBLEDevices);
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral: %@", peripheral);
    BLEDevice *connectedDevice = nil;
    NSLog(@"peri: %@", peripheral);
    
    for(BLEDevice *device in _discoverdBLEDevices){
        NSLog(@"device.p : %@", device.peripheral);

        if([device.peripheral isEqual:peripheral]){
            connectedDevice = device;
            [_connectedBLEDevices addObject:device];
            break;
        }
    }
    
    if(connectedDevice != nil){
        _connectedBLEDeviceBlock(connectedDevice);
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    for(BLEDevice *device in _discoverdBLEDevices){
        if([device.peripheral isEqual:peripheral]){
//            [self.delegate didFailedConnectBLEDevice:device error:error];
            if(_failedConnectBLEDeviceBlock){
                _failedConnectBLEDeviceBlock(device, error);
            }
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    BLEDevice *disconnectedDevice = nil;
    for(BLEDevice *device in _discoverdBLEDevices){
        if([device.peripheral isEqual:peripheral]){
            disconnectedDevice = device;
//            [self.delegate didDisconnectBLEDevice:device];
            if (_isRetry == YES) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(![_discoverdBLEDevices containsObject:device] && device){
                        [_discoverdBLEDevices addObject:device];
                    }
                    
                    if(device.peripheral)
                        [_centralManager connectPeripheral:device.peripheral options:nil];
                });
             }
            NSLog(@"device disconnected-----: %@", error);
            break;
        }
    }
    
    if(disconnectedDevice != nil)
        [_connectedBLEDevices removeObject:disconnectedDevice];
}

- (void)centralManager:(CBCentralManager *)central connectionEventDidOccur:(CBConnectionEvent)event forPeripheral:(CBPeripheral *)peripheral NS_AVAILABLE_IOS(13_0){
    
}

- (void)centralManager:(CBCentralManager *)central didUpdateANCSAuthorizationForPeripheral:(CBPeripheral *)peripheral NS_AVAILABLE_IOS(13_0){
    
}




@end

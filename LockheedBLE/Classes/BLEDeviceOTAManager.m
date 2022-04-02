//
//  BLEDeviceOTAManager.m
//  Leopard
//
//  Created by xwlsly on 2021/6/10.
//

#import "BLEDeviceOTAManager.h"
#import "LBCocoaSecurity.h"

@interface BLEDeviceOTAManager ()
@property (copy, nonatomic) BLEOTA_ScanDevice scanDeviceBlock;
@property (copy, nonatomic) BLEOTA_ConnectedDevice connectDeviceBlock;
@end

@implementation BLEDeviceOTAManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

+(instancetype) shareInstance{
    static BLEDeviceOTAManager *otaManager_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        otaManager_ = [[BLEDeviceOTAManager alloc]init];
    });
    
    return otaManager_;
}

-(void) scanOTADevice:(NSString *) mac
               result:(BLEOTA_ScanDevice) block{
    _scanDeviceBlock = block;
    _mac = [mac copy];
    
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakSelf.scanDeviceBlock){
            weakSelf.scanDeviceBlock(nil, nil, [LMError normalFailedError]);
        }
        weakSelf.scanDeviceBlock = nil;
    });
}

-(void) stopScanDevice{
    [_centralManager stopScan];
}

-(void) connectPeripheral:(CBPeripheral *) peripheral
                   result:(BLEOTA_ConnectedDevice) block{
    _connectDeviceBlock = block;
    [_centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"discover device:%@", peripheral.name);
    NSLog(@"adv data: %@", advertisementData);
    
    if([peripheral.name containsString:@"OTAServiceMgr"] ||
       [peripheral.name containsString:@"bluenrg"]
       ){
        LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];
        NSData *macData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        NSString *macString = [encoder hex:macData useLower:YES];
//        NSLog(@"%@",peripheral.identifier);
        //设备切换OTA模式后，不能广播自己的mac地址，所以只要搜索到blue的字样的设备，就对它升级！！！！
        if(1){
//        if([macString isEqualToString:_mac]){
            NSLog(@"find ota device");
            if(_scanDeviceBlock){
                _advertisement = [advertisementData copy];
                _peripheral = peripheral;
                
                _scanDeviceBlock(peripheral, advertisementData, [LMError SuccessError]);
                _scanDeviceBlock = nil;
            }
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if(_connectDeviceBlock){
        _connectDeviceBlock(peripheral, [LMError SuccessError]);
    }
}


@end

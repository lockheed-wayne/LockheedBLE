//
//  BLEDeviceOTAManager.h
//  Leopard
//
//  Created by xwlsly on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LBError.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LBOTA_ScanDevice)(CBPeripheral *peripheral, NSDictionary * advertisement, LBError *error);
typedef void (^LBOTA_ConnectedDevice) (CBPeripheral *peripheral, LBError *error);


@interface LBDeviceOTAManager : NSObject <CBCentralManagerDelegate>

@property (strong, nonatomic, readonly) CBCentralManager *centralManager;
@property (strong, nonatomic, readonly) NSString *mac;
@property (strong, nonatomic, readonly) NSDictionary *advertisement;
@property (strong, nonatomic, readonly) CBPeripheral *peripheral;

+(instancetype) shareInstance;

-(void) scanOTADevice:(NSString *) mac
               result:(LBOTA_ScanDevice) block;

-(void) stopScanDevice;

-(void) connectPeripheral:(CBPeripheral *) peripheral
                   result:(LBOTA_ConnectedDevice) block;

@end

NS_ASSUME_NONNULL_END

//
//  BLEDeviceOTAManager.h
//  Leopard
//
//  Created by xwlsly on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LMError.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BLEOTA_ScanDevice)(CBPeripheral *peripheral, NSDictionary * advertisement, LMError *error);
typedef void (^BLEOTA_ConnectedDevice) (CBPeripheral *peripheral, LMError *error);


@interface BLEDeviceOTAManager : NSObject <CBCentralManagerDelegate>

@property (strong, nonatomic, readonly) CBCentralManager *centralManager;
@property (strong, nonatomic, readonly) NSString *mac;
@property (strong, nonatomic, readonly) NSDictionary *advertisement;
@property (strong, nonatomic, readonly) CBPeripheral *peripheral;

+(instancetype) shareInstance;

-(void) scanOTADevice:(NSString *) mac
               result:(BLEOTA_ScanDevice) block;

-(void) stopScanDevice;

-(void) connectPeripheral:(CBPeripheral *) peripheral
                   result:(BLEOTA_ConnectedDevice) block;

@end

NS_ASSUME_NONNULL_END

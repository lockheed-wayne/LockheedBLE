//
//  BLEDevice.m
//  GTBLEDevice
//
//  Created by xwlsly on 2021/1/19.
//

#import "BLEDevice.h"
#import "BLEDeviceHeader.h"
#import "LBCocoaSecurity.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *serviceUUID = @"02362AF7-CF3A-11E1-EFDE-0002A5D5C51B";

static NSString *writeCharacteristicUUID = @"02362A10-CF3A-11E1-EFDE-0002A5D5C51B";
static NSString *notifyCharacteristicUUID = @"02362A11-CF3A-11E1-EFDE-0002A5D5C51B";

static NSString *changeModeServiceUUID = @"04263CF7-BF3C-22D1-CDEC-0003D5C4B51D";
static NSString *changeModeCharacteristicUUID = @"04263CF7-BF3C-10D1-CDEC-0003D5C4B51D";

static NSString *DeviceInfoServiceUUID = @"180A";
static NSString *DeviceInfoCharacteristicUUID = @"2A28";


@interface BLEDevice ()

@property (strong, nonatomic) CBService *readWriteService;              //读写服务
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;    //写特征值 请求(手机->设备) 回复(设备->手机)
@property (strong, nonatomic) CBCharacteristic *notifyCharacteristic;   //读特征值 通知(设备->手机) 回复(手机->设备）
@property (strong, nonatomic) CBCharacteristic *changeModeCharacteristic;

#pragma mark blocks
@property (nonatomic, copy) BLEInitFinished blockInitFinished;
@property (nonatomic, copy) BLEqueryIMEI blockQueryImei;
@property (nonatomic, copy) BLEqueryICCID blockQueryICCID;
@property (nonatomic, copy) BLEAuthorization blockAuthorization;
@property (nonatomic, copy) BLEQueryState blockQueryState;
@property (nonatomic, copy) BLEFindVehicle blockBLEFindVehicle;
@property (nonatomic, copy) BLEOpenFlyMode blockBLEOpenFlyMode;
@property (nonatomic, copy) BLEActive blockBLEActive;
@property (nonatomic, copy) BLEGoActive blockBLEGoActive;
@property (nonatomic, copy) BLECancelAlarm blockBLECancelAlarm;
@property (nonatomic, copy) BLESettingSavingModeSection blockBLESettingSavingModeSection;
@property (nonatomic, copy) BLESettingVibrationSwitch blockBLESettingVibrationSwitch;
@property (nonatomic, copy) BLESettingGPSSwitch blockBLESettingGPSSwitch;
@property (nonatomic, copy) BLESettingSavingModeSwitch blockBLESettingSavingModeSwitch;
@property (nonatomic, copy) BLESettingBeepMode blockBLESettingBeepMode;
@property (nonatomic, copy) BLESettingFenceInfo blockBLESettingFenceInfo;
@property (nonatomic, copy) BLESettingTheftSwitch blockBLESettingTheftSwitch;
@property (nonatomic, copy) BLESettingFenceSwitch blockBLESettingFenceSwitch;
@property (nonatomic, copy) BLESettingWakeupDuration blockBLESettingWakeupDuration;
@property (nonatomic, copy) BLESettingAutoTheftSwitch blockBLESettingAutoTheftSwitch;
@property (nonatomic, copy) BLESettingRolloverSwitch blockBLESettingRolloverSwitch;
@property (nonatomic, copy) BLESettingRolloverBeepMode blockBLESettingRolloverBeepMode;
@property (nonatomic, copy) BLESettingTheftBeepMode blockBLESettingTheftBeepMode;
@property (nonatomic, copy) BLESettingVibrationBeepMode blockBLESettingVibrationBeepMode;
@property (nonatomic, copy) BLESettingVibrationLevel blockBLESettingVibrationLevel;
@property (nonatomic, copy) BLESettingGPSDuration blockBLESettingGPSDuration;
@property (nonatomic, copy) BLESettingBLEFortify blockBLESettingBLEFortify;
@property (nonatomic, copy) BLEBeginDrive blockBLEBeginDrive;
@property (nonatomic, copy) BLEStopDrive blockBLEStopDrive;
@property (nonatomic, copy) BLEReboot blockBLEReboot;
@property (nonatomic, copy) BLERestoreSetting blockBLERestoreSetting;
@property (nonatomic, copy) BLEWakeupMCU blockBLEWakeupMCUblock;
@property (nonatomic, copy) BLESettingTransportSwitch blockBLETransportMode;
@property (nonatomic, copy) BLEUpdareFirmware blockBLEUpdareFirmware;
@end

@implementation BLEDevice

-(instancetype) initWithUUID:(NSUUID *) uuid{
    self = [super init];
    if(self){
        _peripheral = nil;
        _uuid = [uuid copy];
    }
    return self;
}


-(instancetype) initWithPeripheral:(CBPeripheral *) peripheral
                 advertisementData:(NSDictionary<NSString *, id> *) advertisementData
                              RSSI:(NSNumber *) rssi{
    self = [super init];
    if(self){
        _peripheral = peripheral;
        _advertisementData = [advertisementData copy];
        _rssi = [rssi copy];
        _peripheral.delegate = self;
        _status = kBLEDeviceStatus_preparation;
        self.bAuthorized = NO;
        _uuid = _peripheral.identifier;
        
        LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];
        NSData *macData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        NSString *macString = [encoder hex:macData useLower:YES];
        
        _mac = macString;
        _BLEName = [advertisementData objectForKey:@"kCBAdvDataLocalName"]?[advertisementData objectForKey:@"kCBAdvDataLocalName"]:NSLocalizedString(@"Unkown", nil);
    }
    return self;
}

-(void) updateAdvertisementData:(NSDictionary<NSString *, id> *) advertisementData
                           RSSI:(NSNumber *) rssi{
    _advertisementData = [advertisementData copy];
    _rssi = [rssi copy];
    
    LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];
    NSData *macData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *macString = [encoder hex:macData useLower:YES];
    
    _mac = macString;
    _BLEName = [advertisementData objectForKey:@"kCBAdvDataLocalName"]?[advertisementData objectForKey:@"kCBAdvDataLocalName"]:NSLocalizedString(@"Unkown", nil);
}

-(void) updateWithPeripheral:(CBPeripheral *) peripheral
           advertisementData:(NSDictionary<NSString *, id> *) advertisementData
                        RSSI:(NSNumber *) rssi{
    if(_peripheral){
        _peripheral.delegate = nil;
    }
    _peripheral = peripheral;
    _uuid = _peripheral.identifier?_peripheral.identifier:nil;
    _advertisementData = [advertisementData copy];
    _rssi = [rssi copy];
    _peripheral.delegate = self;
    _status = kBLEDeviceStatus_preparation;
    self.bAuthorized = NO;
}

-(void) setPeripheral:(CBPeripheral *) peripheral{
    _peripheral = peripheral;
    _peripheral.delegate = self;
}

//发现服务
//-(void) discoverServices{
//    [self.peripheral discoverServices:nil];
//}

-(void)BLEFunctionDiscoverService:(BLEInitFinished)block{
    self.blockInitFinished = block;
    
    CBUUID *readWriteUUID = [CBUUID UUIDWithString:serviceUUID];
    CBUUID *changeModeUUID = [CBUUID UUIDWithString:changeModeServiceUUID];
    CBUUID *DeviceInfoUUID = [CBUUID UUIDWithString:DeviceInfoServiceUUID];

    [_peripheral discoverServices:@[readWriteUUID, changeModeUUID,DeviceInfoUUID]];
}

#pragma mark CBPeripheralDelegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(10_9, 6_0){
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(10_9, 7_0){
    
}

//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(10_7, 10_13, 5_0, 8_0){
//
//}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(10_13, 8_0){
    
}

//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    NSLog(@"didDiscoverServices: %@", peripheral.services);

    for(CBService *service in peripheral.services){
        NSLog(@"service's UUID: %@", service.UUID.UUIDString);

        if([service.UUID.UUIDString isEqualToString:serviceUUID]){
            
            CBUUID *writeUUID = [CBUUID UUIDWithString:writeCharacteristicUUID];
            CBUUID *notifyUUID = [CBUUID UUIDWithString:notifyCharacteristicUUID];
            [peripheral discoverCharacteristics:@[writeUUID, notifyUUID] forService:service];
        }else if([service.UUID.UUIDString isEqualToString:changeModeServiceUUID]){
         
            CBUUID *changeModeUUID = [CBUUID UUIDWithString:changeModeCharacteristicUUID];
            [peripheral discoverCharacteristics:@[changeModeUUID] forService:service];
        }else if([service.UUID.UUIDString isEqualToString:DeviceInfoServiceUUID]){
//            CBUUID *DeveInfoUUID = [CBUUID UUIDWithString:@"180A"];
            [peripheral discoverCharacteristics:nil forService:service];

        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error{
    NSLog(@"didDiscoverIncludedServicesForService: %@", service);
}

//发现服务特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    NSLog(@"device: %@", self);
    NSLog(@"didDiscoverCharacteristicsForService: %@", service);
    NSLog(@"didDiscoverCharacteristicsForService characteristics: %@", service.characteristics);
    for(CBCharacteristic *c in service.characteristics){
        NSLog(@"CBCharacteristic *c in service.characteristics  UUID =%@",c.UUID.UUIDString);
        if([c.UUID.UUIDString isEqualToString:writeCharacteristicUUID]){
            _writeCharacteristic = c;
        }else if([c.UUID.UUIDString isEqualToString:notifyCharacteristicUUID]){
            _notifyCharacteristic = c;
            [peripheral setNotifyValue:YES forCharacteristic:_notifyCharacteristic];
        }else if([c.UUID.UUIDString isEqualToString:changeModeCharacteristicUUID]){
            _changeModeCharacteristic = c;
        }else if([c.UUID.UUIDString isEqualToString:DeviceInfoCharacteristicUUID]){
            [peripheral readValueForCharacteristic:c];

        }
    }
}

//接收数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didUpdateValueForCharacteristic: %@",characteristic);
    NSLog(@"_notifyCharacteristic: %@", _notifyCharacteristic);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DeviceInfoCharacteristicUUID]]) {
        //当前版本
        NSString *result = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        self.softwareRevision = result;
    }
    if(characteristic == _notifyCharacteristic){
        NSLog(@"\nreceived: %@", characteristic.value);
        
        NSData *data = characteristic.value;
        NSData *msgID = [data subdataWithRange:NSMakeRange(4, 2)];
        NSLog(@"msgID");
        
        //如果data为空，则直接报错
        if(data == nil){
            return;
        }
        BLECommandType type = [BLECommandManager phraseCommandType:data];
        Byte *bytes = (Byte *)[data bytes];
        
        //打印用
        self.receiveData = characteristic.value;
        
        //如果长度不达到长度位置，直接返回错误
        if(data.length < (BLE_LenghtPosition+BLE_LenghtLength)){
            return;
        }
        
        //如果实际长度与真实数据长度不对应，直接返回错误
        UInt8 dataLen = data.length;
        UInt8 length = bytes[BLE_LenghtPosition];
        if(dataLen != length || dataLen < BLE_NotDataLenth){
            return;
        }
        
        UInt8 contentLen = dataLen - BLE_NotDataLenth;
        
        Byte *content = (Byte *)[[data subdataWithRange:NSMakeRange(BLE_DATAPosition, contentLen)] bytes];
        
        NSData *contentData = [NSData dataWithBytes:content length:contentLen];
        NSLog(@"Received Command: %@, result: %@", [BLECommandManager stringCommandTypeBy:type], contentData);
//        Log(@"手机接收信息: %@, result: ------>%@", [BLECommandManager stringCommandTypeBy:type], contentData);
//        if(type != BLECommandType_LowPower){
        [self uploadCmdData:data phone2Device:NO];
//        }
        
        switch (type) {
            case BLECommandType_IMEI:{
                UInt8 imeiLen = dataLen - BLE_NotDataLenth;
                NSData *imeiData = [data subdataWithRange:NSMakeRange(BLE_DATAPosition, imeiLen)];
                NSString *imei = [[NSString alloc]initWithData:imeiData encoding:NSASCIIStringEncoding];
//                LogV(@"读IMEI后返回：%@",imeiData);
                //如果蓝牙读取成功
                if(imei.length == 15){
                    _imei = imei;
                    if(_blockQueryImei)
                        _blockQueryImei(imei, [LMError SuccessError]);
                    //如果蓝牙读取失败
                }else{
                    if(_blockQueryImei)
                        _blockQueryImei(imei, [LMError normalFailedError]);
                }
            }
                break;
            case BLECommandType_ICCID:{
                UInt8 iccidLen = dataLen - BLE_NotDataLenth;
                NSData *iccidData = [data subdataWithRange:NSMakeRange(BLE_DATAPosition, iccidLen)];
                NSString *iccid = [[NSString alloc]initWithData:iccidData encoding:NSASCIIStringEncoding];
                
                _iccid = iccid;
                if(_blockQueryICCID)
                    _blockQueryICCID(iccid, [LMError SuccessError]);
            }
                break;
            case BLECommandType_BLEAuthorization:{
                if(content[0] == BLEDevice_ControlCommand_Status_Success){
                    self.bAuthorized = YES;
                    if(_blockAuthorization)
                        _blockAuthorization([LMError SuccessError]);
                }else{
                    self.bAuthorized = NO;
                    if(_blockAuthorization)
                        _blockAuthorization([LMError normalFailedError]);
                }
            }
                break;
                
            case BLECommandType_QueryState:{
                UInt8 stateLen = dataLen - BLE_NotDataLenth; //9
                
                if(stateLen < 7){
                    if(_blockQueryState){
                        _blockQueryState(nil, [LMError normalFailedError]);
                        return;
                    }
                }
                NSData *stateDate = [data subdataWithRange:NSMakeRange(BLE_DATAPosition, stateLen)];
                Byte *stateBytes = (Byte *)[stateDate bytes];
                if(_blockQueryState){
                    _blockQueryState(@{
                        LMBLEQueryStateKey_FenceSwitch:[NSNumber numberWithBool:stateBytes[0]==0x00?NO:YES],
                        LMBLEQueryStateKey_ManualAntiTheft:[NSNumber numberWithBool:stateBytes[1]==0x00?NO:YES],
                        LMBLEQueryStateKey_BLEAutoAntiTheft:[NSNumber numberWithBool:stateBytes[2]==0x00?NO:YES],
                        LMBLEQueryStateKey_TransportSwitch:[NSNumber numberWithBool:stateBytes[3]==0x00?NO:YES],
                            LMBLEQueryStateKey_VibrationBeepDuration:[NSNumber numberWithInteger: stateBytes[4]],
                        LMBLEQueryStateKey_TheftBeepDuration:[NSNumber numberWithInteger:stateBytes[5]],
                        LMBLEQueryStateKey_Battery:[NSNumber numberWithInteger:stateBytes[6]],
                        LMBLEQueryStateKey_DeviceChargingStatus:[NSNumber numberWithBool:stateBytes[7]==0x00?NO:YES],
                                },[LMError SuccessError]);
                }
            }
                break;
            case BLECommandType_FindVehicle:{
                if(content[0] == BLEDevice_ControlCommand_Status_Success){
                    if(_blockBLEFindVehicle)
                        _blockBLEFindVehicle([LMError SuccessError]);
                }else{
                    if(_blockBLEFindVehicle)
                        _blockBLEFindVehicle([LMError normalFailedError]);
                }
            }
                break;
            case BLECommandType_FlyMode:{
                if(content[0] == BLEDevice_ControlCommand_Status_Success){
                    if(_blockBLEOpenFlyMode){
                        _blockBLEOpenFlyMode([LMError SuccessError]);
                    }
                }else{
                    if(_blockBLEOpenFlyMode){
                        _blockBLEOpenFlyMode([LMError normalFailedError]);
                    }
                }
            }
                break;
            case BLECommandType_Active:{
                
            }
                break;
            case BLECommandType_GoActive:{
                
            }
                break;
            case BLECommandType_CancelAlarm:{
                if(content[0] == BLEDevice_ControlCommand_Status_Success){
                    if(_blockBLECancelAlarm){
                        _blockBLECancelAlarm([LMError SuccessError]);
                    }
                }else{
                    if(_blockBLECancelAlarm){
                        _blockBLECancelAlarm([LMError normalFailedError]);
                    }
                }
            }
                break;
            case BLECommandType_Setting:{
                [self dealWithSettingData: contentData];
            }
                break;
            case BLECommandType_UpdatFirmware:{
                if(content[0] == BLEDevice_ControlCommand_Status_Success){
                    if(_blockBLECancelAlarm){
                        _blockBLEUpdareFirmware([LMError SuccessError]);
                    }
                }else{
                    if(_blockBLECancelAlarm){
                        _blockBLEUpdareFirmware([LMError normalFailedError]);
                    }
                }
            }
                break;
            case BLECommandType_BeginDrive:{
                
            }
                break;
            case BLECommandType_StopDrive:{
                
            }
                break;
            case BLECommandType_Reboot:{
                
            }
                break;
            case BLECommandType_RestoreSetting:{
                
            }
                break;
            case BLECommandType_WakeupMCU:{
                
            }
                break;
#pragma mark 收到设备主动上报数据
            case BLECommandType_Vibration:{
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)])
                    [self.delegate didReceivedEvent:BLECommandType_Vibration values:nil];
                
                [self writeNormalSuccessCommand:BLECommandType_Vibration msgID:msgID];
                
                //发出震动告警本地通知
                
            }
                break;
            case BLECommandType_Theft:{
                DeviceTheftStatus theftStatus = content[0];
                NSLog(@"theftStatus: %d", theftStatus);
                
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)]){
                    [self.delegate didReceivedEvent:BLECommandType_Theft values:@{
                        kDevice_TheftStatus:[NSNumber numberWithInteger:theftStatus]
                    }];
                }
                [self writeNormalSuccessCommand:BLECommandType_Theft msgID:msgID];
            }
                break;
            case BLECommandType_Fence:{
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)]){
                    [self.delegate didReceivedEvent:BLECommandType_Fence values:nil];
                }
                [self writeNormalSuccessCommand:BLECommandType_Fence msgID:msgID];
            }
                break;
            case BLECommandType_LowPower:{
                BatteryLevel batterylevel = content[0];
                NSLog(@"batterylevel content=>%@",contentData);
                self.batteryLevel = batterylevel;
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)])
                    [self.delegate didReceivedEvent:BLECommandType_LowPower values:@{kDevice_BatteryLevel:[NSNumber numberWithInteger:batterylevel]}];
                    
                [self writeNormalSuccessCommand:BLECommandType_LowPower msgID:msgID];
            }
                break;
            case BLECommandType_GPSLongTimeNotLocaltion:{
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)])
                    [self.delegate didReceivedEvent:BLECommandType_GPSLongTimeNotLocaltion values:nil];
                
                [self writeNormalSuccessCommand:BLECommandType_GPSLongTimeNotLocaltion msgID:msgID];
            }
                break;
            case BLECommandType_GPS:{
                
                
                if([self.delegate respondsToSelector:@selector(didUpdateCoordinate:)]){
                    NSData *latData = [contentData subdataWithRange:NSMakeRange(11, 4)];
                    NSData *lngData = [contentData subdataWithRange:NSMakeRange(15, 4)];
                    
                    NSLog(@"lat: %@", latData);
                    NSLog(@"lng: %@", lngData);
                    
#warning 获取调试数据后再添加解析；
//                    self.delegate didUpdateCoordinate:<#(CLLocationCoordinate2D)#>
                    
                }
                
                [self writeNormalSuccessCommand:BLECommandType_GPS msgID:msgID];
            }
                break;
            case BLECommandType_Rollover:{
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)])
                    [self.delegate didReceivedEvent:BLECommandType_Rollover values:nil];
                
                [self writeNormalSuccessCommand:BLECommandType_Rollover msgID:msgID];
            }
                break;
            case BLECommandType_Battery:{
                BatteryLevel batteryLevel = content[0];
                self.batteryLevel = batteryLevel;
                
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)]){
                    [self.delegate didReceivedEvent:BLECommandType_Battery values:@{
                        kDevice_BatteryLevel:[NSNumber numberWithInteger:batteryLevel]
                    }];
                }
                [self writeNormalSuccessCommand:BLECommandType_Battery msgID:msgID];
            }
                break;
            case BLECommandType_GMSGSignalStrength:{
                GMSGSignalStrengthLevel gmsSignalStrengthLevel = content[0];
                [self.delegate didReceivedEvent:BLECommandType_GMSGSignalStrength values:@{
                    kDevice_GMSGSignalStrengthLevel:[NSNumber numberWithInteger:gmsSignalStrengthLevel]
                }];
                [self writeNormalSuccessCommand:BLECommandType_GMSGSignalStrength msgID:msgID];
            }
                break;
            case BLECommandType_Wakeup:{
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)]){
                    WakeupType wakeupType = content[0];
                    [self.delegate didReceivedEvent:BLECommandType_Wakeup values:@{
                        kDevice_WakeupEvent:[NSNumber numberWithInteger:wakeupType]
                    }];
                }
                [self writeNormalSuccessCommand:BLECommandType_Wakeup msgID:msgID];
            }
                break;
            case BLECommandType_Charging:{
                //充电状态
                ChargingStatus chargingStatus = content[0];
                //电池电量
              NSData *  chargingData = [data subdataWithRange:NSMakeRange(BLE_DATAPosition, contentLen)];
                if (chargingData.length>2) {
                    BatteryLevel batteryLevel = content[1];
                    self.batteryLevel = batteryLevel;
                }

                self.chargingStatus = chargingStatus;   //充电状态;
                if([self.delegate respondsToSelector:@selector(didReceivedEvent:values:)]){
                    [self.delegate didReceivedEvent:BLECommandType_Charging values:@{
                        kDevice_ChargingStatus:[NSNumber numberWithInteger:chargingStatus]
                    }];
                }
                [self writeNormalSuccessCommand:BLECommandType_Charging msgID:msgID];
            }
                break;
            case BLECommandType_NotExist:{
                
            }
                break;
                
            default:
                break;
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //    NSLog(@"didWriteValueForCharacteristic: %@", characteristic.value);
    //    NSLog(@"didWriteValueForCharacteristic error: %@", error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didUpdateNotificationStateForCharacteristic:%@", characteristic);
    if(characteristic == _notifyCharacteristic){
        if(characteristic.isNotifying == NO){
            NSLog(@"notifying closed");
        }else{
            if(_writeCharacteristic != nil && _notifyCharacteristic != nil){
                _status = kBLEDeviceStatus_getReady;
                
                LMError *err = [LMError SuccessError];
                
                if(_blockInitFinished)
                    _blockInitFinished(err);
            }else{
                LMError *err = [LMError normalFailedError];
                if(_blockInitFinished)
                    _blockInitFinished(err);
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didDiscoverDescriptorsForCharacteristic: %@", characteristic);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    NSLog(@"didUpdateValueForDescriptor: %@", descriptor);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    NSLog(@"didWriteValueForDescriptor: %@", descriptor);
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral{
    NSLog(@"peripheralIsReadyToSendWriteWithoutResponse: %@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(nullable CBL2CAPChannel *)channel error:(nullable NSError *)error{
    
}

-(BOOL) checkBeforeSendCmd{
    if(_status == kBLEDeviceStatus_getReady && _peripheral.state == CBPeripheralStateConnected)
        return YES;
    
    return NO;
}

-(nullable NSData *) bleDeviceAuthori:(NSString *) imei{
    //如果未连接，直接返回
    if(_peripheral.state != CBPeripheralStateConnected)
        return nil;
    
    if(imei == nil){
        return nil;
    }
    
    if(imei.length != 15){
        return nil;
    }
    //    NSLog(@"imei before reverse: %@", imei);
    
    NSMutableString *reverseImei = [[NSMutableString alloc]initWithCapacity:15];
    NSInteger imeiLength = imei.length;
    
    for(int i=0; i<imei.length; i++){
        [reverseImei appendString:[imei substringWithRange:NSMakeRange(imeiLength-i-1, 1)]];
    }
    //    NSLog(@"first reverse: %@", reverseImei);
    
    NSString *top2Digit = [reverseImei substringWithRange:NSMakeRange(1, 2)];
    NSString *last2Digit = [reverseImei substringWithRange:NSMakeRange(imeiLength-2, 2)];
    
    NSMutableString *newStr = [NSMutableString stringWithString:[reverseImei stringByReplacingCharactersInRange:NSMakeRange(1, 2) withString:last2Digit]];
    NSMutableString *newStr2 = [NSMutableString stringWithString:[newStr stringByReplacingCharactersInRange:NSMakeRange(imeiLength-2, 2) withString:top2Digit]];
    //    NSLog(@"top2Digit: %@", top2Digit);
    //    NSLog(@"last2Digit: %@", last2Digit);
    
    //    NSLog(@"after reverse: %@", newStr2);
    
    NSData *hashData = [newStr2 sha1];
    NSLog(@"hashData: %@", hashData);
    
    return hashData;
}

-(void) uploadCmdData:(NSData *) cmdData phone2Device:(BOOL) phone2Device{
//    if(!LMUserToken){
//        return;
//    }
//    LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];
//    NSString *dataString = [encoder hex:cmdData useLower:YES];
//    CLLocation *currentLocation = [LMLocationManager shareInstance].location;
//    CLHeading *currentHeading = [LMLocationManager shareInstance].heading;
//    if (phone2Device) {
////        Log(@"手机发设备信息:  data: ------>：%@",dataString);
//    }else{
////        Log(@"设备回手机信息:  data ------>：%@",dataString);
//    }
//    LMMainJsonClient *client = [LMMainJsonClient shareInstance];
//    LMRequestParameter *p = [[LMRequestParameter alloc]
//                             initWithRequestIdentify:kRequestIdentify_UploadBLEMsg
//                             type:(kREQUEST_TYPE_POST)
//                             token:LMUserToken
//                             parameter:@{
//                                 @"imei":_imei?_imei:@"",
//                                 @"data":dataString,
//                                 @"timestamp":[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],
//                                 @"direct":phone2Device?@1:@0,
//                                 @"gps":@{
//                                         @"lat":[NSNumber numberWithDouble: currentLocation.coordinate.latitude],
//                                         @"lng":[NSNumber numberWithDouble: currentLocation.coordinate.longitude],
//                                         @"direction":[NSNumber numberWithDouble:currentHeading.magneticHeading],
//                                         @"altitude":[NSNumber numberWithDouble:currentLocation.altitude],
//                                         @"satellites":@0,
//                                         @"speed":[NSNumber numberWithDouble:currentLocation.speed],
//                                 }
//                             }];
//
////    NSLog(@"p: %@", p.parameter);
//
//    [client requestWithParameters:p sucess:^(id responseData) {
//
////        NSLog(@"upload data success: %@", cmdData);
//
//    } failure:^(LMError *error) {
//        NSLog(@"failed to upload data");
//    }];
}

#pragma mark 蓝牙操作
-(void) BLEFunctionQueryIMEI:(BLEqueryIMEI) block{
//    if([self checkBeforeSendCmd]){
        NSData *queryCmd = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_IMEI data:nil];
        
        [self uploadCmdData:queryCmd phone2Device:YES];
        [self.peripheral writeValue:queryCmd forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        self.blockQueryImei = block;
//    }
}

-(void) BLEFunctionQueryICCID:(BLEqueryICCID) block{
    if([self checkBeforeSendCmd]){
        NSData *queryCmd = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_ICCID data:nil];
        
        [self uploadCmdData:queryCmd phone2Device:YES];
        [_peripheral writeValue:queryCmd forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        _blockQueryICCID = block;
    }
}
-(void) BLEFunctionAuthorizationWithImei:(NSString *) imei result:(BLEAuthorization) block{
//    if([self checkBeforeSendCmd]){
        NSData *imeiAuthoriData = [self bleDeviceAuthori:imei];
        NSData *authorization = [[BLECommandManager shareInstance] buildResponseCommandFor:BLECommandType_BLEAuthorization data:imeiAuthoriData msgID:nil];
        
        [self uploadCmdData:authorization phone2Device:YES];
        [_peripheral writeValue:authorization forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockAuthorization = block;
//    }
}
-(void) BLEFunctionQueryState:(BLEQueryState) block{
    if([self checkBeforeSendCmd]){
        NSData *queryState = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_QueryState data:nil];

        [self uploadCmdData:queryState phone2Device:YES];
        [_peripheral writeValue:queryState forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        _blockQueryState = block;
    }
}

-(void) BLEFunctionFindVehicle:(BLEFindVehicle) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_FindVehicle data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEFindVehicle = block;
    }
}

-(void) BLEFunctionOpenFlyMode:(BLEOpenFlyMode) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_FlyMode data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEOpenFlyMode = block;
    }
}
-(void) BLEFunctionActive:(BLEActive) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Active data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEActive = block;
    }
}
-(void) BLEFunctionGoActive:(BLEGoActive) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_GoActive data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEGoActive = block;
    }
}
-(void) BLEFunctionCancelAlarm:(BLECancelAlarm) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_CancelAlarm data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLECancelAlarm = block;
    }
}
-(void) BLEFunctionSettingSavingModeSectionTime:(NSDate *) startDate lastTime:(NSInteger)lastTime result:(BLESettingSavingModeSection) block{
    if([self checkBeforeSendCmd]){
        
        Byte cmd = BLECommandType_Setting_Type_SavingModeSection;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:&cmd length:1];
        NSData *startData = [BLETools convertDate2Intervalue:startDate];
        NSData *lastTimeData = [BLETools converLastTime2Data:lastTime];
        [cmdData appendData:startData];
        [cmdData appendData:lastTimeData];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingSavingModeSection = block;
    }
}
-(void) BLEFunctionSettingVibrationSwitchStats:(BOOL) locked result:(BLESettingVibrationSwitch) block{
    Byte status;
    if([self checkBeforeSendCmd]){
        if(locked){
            status = BLEDevice_SwitchStatus_Locked_OR_ON;
        }else{
            status = BLEDevice_SwitchStatus_Unlock_OR_OFF;
        }
        
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_VibrationSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingVibrationSwitch = block;
    }
}
-(void) BLEFunctionSettingGPSSwitchStatus:(BLEDevice_SwitchStatus) status  result:(BLESettingGPSSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_GPSSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingGPSSwitch = block;
    }
}
-(void) BLEFunctionSettingSavingModeSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingSavingModeSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_SavingModeSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingSavingModeSwitch = block;
    }
}
-(void) BLEFunctionSettingBeepModePower:(UInt8) power duration:(UInt8) duration result:(BLESettingBeepMode) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[3];
        cmd[0] = BLECommandType_Setting_Type_BeepMode;
        cmd[1] = power;
        cmd[2] = duration;
        
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:3];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingSavingModeSwitch = block;
    }
}
-(void) BLEFunctionSettingFenceInfo:(BLEFence *) fence result:(BLESettingFenceInfo) block{
    if([self checkBeforeSendCmd]){
        NSData *cmdData = [fence getFenceData]; //待实现
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingFenceInfo = block;
    }
}

#pragma mark 手动设防,调用的是 BLECommandType_Setting_Type_BLEFortifySwitch
-(void) BLEFunctionSettingTheftSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingTheftSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_BLEFortifySwitch;  //手动设防使用
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingTheftSwitch = block;
    }
}
-(void) BLEFunctionSettingFenceSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingFenceSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_FenceSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingFenceSwitch = block;
    }
}
-(void) BLEFunctionSettingWakeupDurationHour:(UInt16)hour result:(BLESettingWakeupDuration) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[3];
        cmd[0] = BLECommandType_Setting_Type_WakeupDuration;
        cmd[1] = hour / 0x100;
        cmd[2] = hour % 0x100;
        
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:3];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingWakeupDuration = block;
    }
}
-(void) BLEFunctionSettingAutoTheftSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingAutoTheftSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_AutoTheftSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingAutoTheftSwitch = block;
    }
}
-(void) BLEFunctionSettingRolloverSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingRolloverSwitch) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_RolloverSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingRolloverSwitch = block;
    }
}
-(void) BLEFunctionSettingRolloverBeepModeDuration:(UInt8) duration response:(BLESettingRolloverBeepMode) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_RolloverBeepMode;
        cmd[1] = duration;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingRolloverBeepMode = block;
    }
}
-(void) BLEFunctionSettingTheftBeepModeDUration:(UInt8) duration result:(BLESettingTheftBeepMode) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_TheftBeepMode;
        cmd[1] = duration;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingTheftBeepMode = block;
    }
}
-(void) BLEFunctionSettingVibrationBeepModeDuration:(UInt8) duration result:(BLESettingVibrationBeepMode) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_VibrationBeepMode;
        cmd[1] = duration;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingVibrationBeepMode = block;
    }
}
-(void) BLEFunctionSettingVibrationLevel:(UInt8)level result:(BLESettingVibrationLevel) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_VibrationLevel;
        cmd[1] = level;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingVibrationLevel = block;
    }
}
-(void) BLEFunctionSettingGPSDuration:(UInt8) duration result:(BLESettingGPSDuration) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_GPSDuration;
        cmd[1] = duration;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingGPSDuration = block;
    }
}
-(void) BLEFunctionSettingBLEFortify:(BLEDevice_SwitchStatus)status  result:(BLESettingBLEFortify) block{
    if([self checkBeforeSendCmd]){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_BLEFortifySwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLESettingBLEFortify = block;
    }
}
-(void) BLEFunctionBeginDrive:(BLEBeginDrive) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_BeginDrive data:nil];

        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEBeginDrive = block;
    }
}
-(void) BLEFunctionStopDrive:(BLEStopDrive) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_StopDrive data:nil];

        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEStopDrive = block;
    }
}
-(void) BLEFunctionReboot:(BLEReboot) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Reboot data:nil];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEReboot = block;
    }
}
-(void) BLEFunctionRestoreSetting:(BLERestoreSetting) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_RestoreSetting data:nil];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLERestoreSetting = block;
    }
}
-(void) BLEFunctionWakeupMCU:(BLEWakeupMCU) block{
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_WakeupMCU data:nil];
        
        [self uploadCmdData:data phone2Device:YES];

        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEWakeupMCUblock = block;
    }
}

-(void) BLEFUnctionTransportSwitch:(BLEDevice_SwitchStatus) status result:(BLESettingTransportSwitch) block{
    if(_peripheral.state == CBPeripheralStateConnected){
        Byte cmd[2];
        cmd[0] = BLECommandType_Setting_Type_TransportModeSwitch;
        cmd[1] = status;
        NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:2];
        
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_Setting data:cmdData];
        
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLETransportMode = block;
    }else{
        block([LMError normalFailedError]);
    }
}

- (void)BLEUpdateFirmware:(BLEDevice_SwitchStatus)status result:(BLEUpdareFirmware)block{
    
    if([self checkBeforeSendCmd]){
        NSData *data = [[BLECommandManager shareInstance] buildNewCommandFor:BLECommandType_UpdatFirmware data:nil];
        
        [self uploadCmdData:data phone2Device:YES];
        [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        
        _blockBLEUpdareFirmware = block;
    }
    
}
-(BOOL) BLEFunctionSwithBLEOTAMode{
    if(!_changeModeCharacteristic) return NO;
    if(_status == kBLEDeviceStatus_getReady){
        Byte cmd[6] = {0x34,0x35,0x36,0x31,0x32,0x33};
        NSData *data = [NSData dataWithBytes:cmd length:6];
        [_peripheral writeValue:data forCharacteristic:_changeModeCharacteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"wirte %@ to change mode characteristic: %@", data, _changeModeCharacteristic.UUID.UUIDString);
//        LogV(@"发送OTA命令------------------->bluenrg 发送命令：%@",data);
        return YES;
    }
    return NO;
}

//-(BLECommandType) phraseCommandType:(NSData *) data{
//    if(data.length < 9)
//        return BLECommandType_NotExist;
//
//    Byte *bytes = (Byte *)[data bytes];
//
//    return bytes[3];
//}

-(void) writeNormalSuccessCommand:(BLECommandType) type msgID:(NSData *) msgIDData{
    NSData *cmdData = [[BLECommandManager shareInstance] normalSuccessCommand:type msgID:msgIDData];
    
    [self uploadCmdData:cmdData phone2Device:YES];

    [_peripheral writeValue:cmdData forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void) uploadBLEData:(NSString *) imei
                 data:(NSString *) hexData
            timeStamp:(double) timeStamp
              success:(void(^)(void))success
               failed:(void(^)(LMError *err)) failed{
//    if(!LMUserToken){
//        return;
//    }
//
//    LMMainJsonClient *client = [LMMainJsonClient shareInstance];
//    LMRequestParameter *p = [[LMRequestParameter alloc]
//                             initWithRequestIdentify:kRequestIdentify_UploadBLEMsg
//                             type:(kREQUEST_TYPE_POST)
//                             token:LMUserToken
//                             parameter:@{
//                                 @"imei":imei,
//                                 @"data":hexData,
//                                 @"timestamp":[NSNumber numberWithDouble:timeStamp]
//                             }];
//
//    [client requestWithParameters:p sucess:^(id responseData) {
//        success();
//    } failure:^(LMError *error) {
//        failed(error);
//    }];
}

-(void) dealWithSettingData:(NSData *) content{
    if(content.length < 2){
        return;
    }
    
    Byte *contentBytes = (Byte *)[content bytes];
    BOOL success = contentBytes[1] == 0x00;
    
    NSString *settingName = [BLECommandManager stringSettingCommandTypeBy:contentBytes[0]];
    NSLog(@"setting: %@, result: %d", settingName, contentBytes[1]);
    
    switch (contentBytes[0]) {
        case BLECommandType_Setting_Type_SavingModeSection:{   //省电模式打开时间段
            
        }
            break;
        case BLECommandType_Setting_Type_VibrationSwitch:{     //震动告警开关
            NSLog(@"success: %d", success);
            if(_blockBLESettingVibrationSwitch){
                _blockBLESettingVibrationSwitch(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_GPSSwitch:{           //GPS开关
            
        }
            break;
        case BLECommandType_Setting_Type_SavingModeSwitch:{    //省电模式开关
            
        }
            break;
        case BLECommandType_Setting_Type_BeepMode:{            //蜂鸣器设置
            if(_blockBLESettingBeepMode){
                _blockBLESettingBeepMode(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_FenceInfo:{           //电子围栏设置
            if(_blockBLESettingFenceInfo){
                _blockBLESettingFenceInfo(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_TheftSwitch:{         //盗车告警开关, 未用到，不要调
           
        }
            break;
        case BLECommandType_Setting_Type_FenceSwitch:{         //电子围栏开关
            if(_blockBLESettingFenceSwitch){
                _blockBLESettingFenceSwitch(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_WakeupDuration:{      //设置定时唤醒时长
            
        }
            break;
        case BLECommandType_Setting_Type_AutoTheftSwitch:{     //自动开启防盗模式开关
            if(_blockBLESettingAutoTheftSwitch){
                _blockBLESettingAutoTheftSwitch(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_RolloverSwitch:{      //设置翻车告警开关
            
        }
            break;
        case BLECommandType_Setting_Type_RolloverBeepMode:{    //设置翻车告警后蜂鸣器时长
            
        }
            break;
        case BLECommandType_Setting_Type_TheftBeepMode:{       //设置盗车告警后蜂鸣器时长
            if(_blockBLESettingTheftBeepMode){
                _blockBLESettingTheftBeepMode(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_VibrationBeepMode:{   //设置震动唤醒后蜂鸣器响时长
            if(_blockBLESettingVibrationBeepMode){
                _blockBLESettingVibrationBeepMode(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
        case BLECommandType_Setting_Type_VibrationLevel:{      //设置震动唤醒等级
            
        }
            break;
        case BLECommandType_Setting_Type_GPSDuration:{         //设置GPS上报时间间隔
            
        }
            break;
        case BLECommandType_Setting_Type_BLEFortifySwitch:{     //蓝牙设防开关
            if(_blockBLESettingTheftSwitch){
                _blockBLESettingTheftSwitch(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            break;
            
        case BLECommandType_Setting_Type_TransportModeSwitch:{      //运输模式
            if(_blockBLETransportMode){
                _blockBLETransportMode(success?[LMError SuccessError]:[LMError normalFailedError]);
            }
        }
            
            
        default:
            break;
    }
}

-(BOOL) checkConnect{
    if(_peripheral.state != CBPeripheralStateConnected ||
       _peripheral.state != CBPeripheralStateConnecting){
//        [[LMBLEAdapter shareInstance] connectAndAuthoryDevice:self];
        
        return NO;
    }
    return YES;
}

-(NSString *) getBatteryLevelString{
    switch (_batteryLevel) {
        case kBatteryLevel_15:
            return @"15%";
            break;
        case kBatteryLevel_30:
            return @"30%";
            break;
        case kBatteryLevel_50:
            return @"50%";
            break;
        case kBatteryLevel_75:
            return @"75%";
            break;
        case kBatteryLevel_100:
            return @"100%";
            break;
        default:
            break;
    }
    return @"0%";
}

@end

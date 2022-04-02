//
//  BLEDevice.h
//  GTBLEDevice
//
//  Created by xwlsly on 2021/1/19.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "BLEDeviceBlock.h"
#import "BLEDeviceHeader.h"

NS_ASSUME_NONNULL_BEGIN


//盗车告警状态，由设备上报
typedef enum : UInt8 {
    DeviceTheftStatus_Stop = 0,     //盗车告警结束
    DeviceTheftStatus_Start = 1,        //盗车告警开始
} DeviceTheftStatus;

typedef enum : UInt8 {
    kBatteryLevel_0 = -1,    //设备不存在此值，仅为显示
    kBatteryLevel_15 = 0x00,     //0-15%
    kBatteryLevel_30 = 0x01,     //15% - 30%
    kBatteryLevel_50 = 0x02,     //30% - 50%
    kBatteryLevel_75 = 0x03,     //50% - 75%
    kBatteryLevel_100 = 0x04,      //75% - 100%
} BatteryLevel;

typedef enum : UInt8 {
    kGMSGSignalStrengthLevel_1 = 0x01,  //s<-103db
    kGMSGSignalStrengthLevel_2 = 0x02,  //-103<s<-97
    kGMSGSignalStrengthLevel_3 = 0x03,  //-97<s<-89
    kGMSGSignalStrengthLevel_4 = 0x04,   //-89<s
    kGMSGSignalStrengthLevel_unknown = 0x99     //未知或不可测
} GMSGSignalStrengthLevel;

typedef enum : UInt8 {
    kWakeupType_wakeup = 0x01,  //唤醒
    kWakeupType_sleep = 0x00    //休眠
} WakeupType;

typedef enum : UInt8 {
    kChargingStatus_unCharging, //未充电
    kChargingStatus_charging    //充电中
} ChargingStatus;

//控制命令调用结果
typedef enum : UInt8 {
    BLEDevice_ControlCommand_Status_Success = 0x00,     //成功
    BLEDevice_ControlCommand_Status_Error = 0x01        //失败
} BLEDevice_ControlCommand_Status;

//设备状态，是指在连接后与设备发现服务的过程，由BLEDevice自行维护
typedef enum : NSUInteger {
    kBLEDeviceStatus_preparation,   //准备中,不可使用
    kBLEDeviceStatus_getReady,      //蓝牙连接建立，服务已发现，可以发送命令
    kBLEDeviceStatus_error          //设备出错
} BLEDeviceStatus;

//开关状态,所有BLE设备的开关均由此枚举实现
typedef enum : UInt8 {
    BLEDevice_SwitchStatus_Unlock_OR_OFF = 0x00,     //关闭
    BLEDevice_SwitchStatus_Locked_OR_ON = 0x01       //打开
} BLEDevice_SwitchStatus;

@protocol BLEDeviceDelegate <NSObject>

-(void) didReceivedEvent:(BLECommandType) cmdType values:(nullable NSDictionary *) values;

-(void) didUpdateCoordinate:(CLLocationCoordinate2D) coordinate;

@end

@class CBPeripheral,BLEFence;
@interface BLEDevice : NSObject<CBPeripheralDelegate>
@property (assign, nonatomic) id<BLEDeviceDelegate> delegate;

@property (strong, nonatomic, setter=setPeripheral:) CBPeripheral *peripheral;
//@property (strong, nonatomic, readonly) CBPeripheral *peripheral;

@property (strong, nonatomic) NSDictionary<NSString *, id> * advertisementData;
@property (strong, nonatomic, readonly) NSNumber * rssi;
@property (strong, nonatomic) NSUUID *uuid;       //设备唯一标识，用于ios重连
@property (strong, nonatomic) NSString *mac;      //设备mac地址，从广播数据中读取，并用于重连

@property (assign, nonatomic, readonly) BLEDeviceStatus status;         //设备状态

@property (assign, nonatomic) ChargingStatus chargingStatus;  //充电状态

@property (assign, nonatomic) BOOL bAuthorized;       //是否鉴权

@property (strong, nonatomic) NSString *imei;
@property (strong, nonatomic) NSString *BLEName;
@property (strong, nonatomic, readonly) NSString *iccid;

@property (assign, nonatomic) BatteryLevel batteryLevel;
@property (strong, nonatomic) NSDate *batteryUpdateTime;
    
@property (strong, nonatomic, getter=getBatteryLevelString) NSString *batteryLevelString;

@property (strong, nonatomic) NSData *receiveData;  //收到的数据，打印用

@property (strong, nonatomic) NSString *softwareRevision;
//当未连接设备时，从后台取回UUID后，通过此方法初始化
-(instancetype) initWithUUID:(NSUUID *) uuid;

//通过真实设备CBPeripheral进行初始化
-(instancetype) initWithPeripheral:(CBPeripheral *) peripheral
                 advertisementData:(NSDictionary<NSString *, id> *) advertisementData
                              RSSI:(NSNumber *) rssi;

-(void) updateAdvertisementData:(NSDictionary<NSString *, id> *) advertisementData
                                 RSSI:(NSNumber *) rssi;

-(void) updateWithPeripheral:(CBPeripheral *) peripheral
           advertisementData:(NSDictionary<NSString *, id> *) advertisementData
                        RSSI:(NSNumber *) rssi;



//初始化设备状态,向蓝牙设备进行服务发现
//-(void) discoverServicesWithBlock:(BLEInitFinished) block;
-(void) BLEFunctionDiscoverService:(BLEInitFinished) block;

-(void) BLEFunctionQueryIMEI:(BLEqueryIMEI) block;
-(void) BLEFunctionQueryICCID:(BLEqueryICCID) block;
-(void) BLEFunctionAuthorizationWithImei:(NSString *) imei result:(BLEAuthorization) block;
-(void) BLEFunctionQueryState:(BLEQueryState) block;
-(void) BLEFunctionFindVehicle:(BLEFindVehicle) block;
-(void) BLEFunctionOpenFlyMode:(BLEOpenFlyMode) block;
-(void) BLEFunctionActive:(BLEActive) block;
-(void) BLEFunctionGoActive:(BLEGoActive) block;
-(void) BLEFunctionCancelAlarm:(BLECancelAlarm) block;
-(void) BLEFunctionSettingSavingModeSectionTime:(NSDate *) startDate lastTime:(NSInteger)lastTime result:(BLESettingSavingModeSection) block;
-(void) BLEFunctionSettingVibrationSwitchStats:(BOOL) locked result:(BLESettingVibrationSwitch) block;
-(void) BLEFunctionSettingGPSSwitchStatus:(BLEDevice_SwitchStatus) status  result:(BLESettingGPSSwitch) block;
-(void) BLEFunctionSettingSavingModeSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingSavingModeSwitch) block;
-(void) BLEFunctionSettingBeepModePower:(UInt8) power duration:(UInt8) duration result:(BLESettingBeepMode) block;
-(void) BLEFunctionSettingFenceInfo:(BLEFence *) fence result:(BLESettingFenceInfo) block;
-(void) BLEFunctionSettingTheftSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingTheftSwitch) block;
-(void) BLEFunctionSettingFenceSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingFenceSwitch) block;
-(void) BLEFunctionSettingWakeupDurationHour:(UInt16)hour result:(BLESettingWakeupDuration) block;
-(void) BLEFunctionSettingAutoTheftSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingAutoTheftSwitch) block;
-(void) BLEFunctionSettingRolloverSwitchStatus:(BLEDevice_SwitchStatus)status  result:(BLESettingRolloverSwitch) block;
-(void) BLEFunctionSettingRolloverBeepModeDuration:(UInt8) duration response:(BLESettingRolloverBeepMode) block;
-(void) BLEFunctionSettingTheftBeepModeDUration:(UInt8) duration result:(BLESettingTheftBeepMode) block;
-(void) BLEFunctionSettingVibrationBeepModeDuration:(UInt8) duration result:(BLESettingVibrationBeepMode) block;
-(void) BLEFunctionSettingVibrationLevel:(UInt8)level result:(BLESettingVibrationLevel) block;
-(void) BLEFunctionSettingGPSDuration:(UInt8) duration result:(BLESettingGPSDuration) block;
-(void) BLEFunctionSettingBLEFortify:(BLEDevice_SwitchStatus)status  result:(BLESettingBLEFortify) block;
-(void) BLEFunctionBeginDrive:(BLEBeginDrive) block;
-(void) BLEFunctionStopDrive:(BLEStopDrive) block;
-(void) BLEFunctionReboot:(BLEReboot) block;
-(void) BLEFunctionRestoreSetting:(BLERestoreSetting) block;
-(void) BLEFunctionWakeupMCU:(BLEWakeupMCU) block;
-(void) BLEFUnctionTransportSwitch:(BLEDevice_SwitchStatus) status result:(BLESettingTransportSwitch) block;
-(void) BLEUpdateFirmware:(BLEDevice_SwitchStatus) status result:(BLEUpdareFirmware) block;

-(BOOL) BLEFunctionSwithBLEOTAMode;

@end

NS_ASSUME_NONNULL_END

//
//  BLEDeviceBlock.h
//  Leopard
//
//  Created by xwlsly on 2021/2/23.
//

#ifndef BLEDeviceBlock_h
#define BLEDeviceBlock_h
#include "LMError.h"

static NSString *LMBLEQueryStateKey_FenceSwitch = @"LMBLEQueryStateKey_FenceSwitch";
static NSString *LMBLEQueryStateKey_ManualAntiTheft = @"LMBLEQueryStateKey_ManualAntiTheft";
static NSString *LMBLEQueryStateKey_BLEAutoAntiTheft = @"LMBLEQueryStateKey_BLEAutoAntiTheft";
static NSString *LMBLEQueryStateKey_TransportSwitch = @"LMBLEQueryStateKey_TransportSwitch";
static NSString *LMBLEQueryStateKey_VibrationBeepDuration = @"LMBLEQueryStateKey_VibrationBeepDuration";
static NSString *LMBLEQueryStateKey_TheftBeepDuration = @"LMBLEQueryStateKey_TheftBeepDuration";
static NSString *LMBLEQueryStateKey_Battery = @"LMBLEQueryStateKey_Battery";
static NSString *LMBLEQueryStateKey_DeviceChargingStatus = @"LMBLEQueryStateKey_DeviceChargingStatus";

@class BLEDevice;
#pragma mark BLEDeviceManager block
typedef void (^BLEManagerFindDevice)(NSArray <BLEDevice *>*devices);
typedef void (^BLEManagerConnectedDevice)(BLEDevice *device);
typedef void (^BLEManagerFailedConnectedDevice)(BLEDevice *device, NSError *error);

#pragma mark BLEDevice block
typedef void (^BLEInitFinished)(LMError *error);
typedef void (^BLEqueryIMEI)(NSString *imei, LMError *error);
typedef void (^BLEqueryICCID)(NSString *iccid, LMError *error);
typedef void (^BLEAuthorization)(LMError *error);
typedef void (^BLEQueryState)(NSDictionary *stateDic, LMError *error);
typedef void (^BLEFindVehicle)(LMError *error);
typedef void (^BLEOpenFlyMode)(LMError *error);
typedef void (^BLEActive)(LMError *error);
typedef void (^BLEGoActive)(LMError *error);
typedef void (^BLECancelAlarm)(LMError *error);
typedef void (^BLESettingSavingModeSection)(LMError *error);
typedef void (^BLESettingVibrationSwitch)(LMError *error);
typedef void (^BLESettingGPSSwitch)(LMError *error);
typedef void (^BLESettingSavingModeSwitch)(LMError *error);    //省电模式开关
typedef void (^BLESettingBeepMode)(LMError *error);            //蜂鸣器设置
typedef void (^BLESettingFenceInfo)(LMError *error);           //电子围栏设置
typedef void (^BLESettingTheftSwitch)(LMError *error);         //盗车告警开关
typedef void (^BLESettingFenceSwitch)(LMError *error);         //电子围栏开关
typedef void (^BLESettingWakeupDuration)(LMError *error);      //设置定时唤醒时长
typedef void (^BLESettingAutoTheftSwitch)(LMError *error);     //自动开启防盗模式开关
typedef void (^BLESettingRolloverSwitch)(LMError *error);      //设置翻车告警开关
typedef void (^BLESettingRolloverBeepMode)(LMError *error);    //设置翻车告警后蜂鸣器时长
typedef void (^BLESettingTheftBeepMode)(LMError *error);       //设置盗车告警后蜂鸣器时长
typedef void (^BLESettingVibrationBeepMode)(LMError *error);   //设置震动唤醒后蜂鸣器响时长
typedef void (^BLESettingVibrationLevel)(LMError *error);      //设置震动唤醒等级
typedef void (^BLESettingGPSDuration)(LMError *error);         //设置GPS上报时间间隔
typedef void (^BLESettingBLEFortify)(LMError *error);          //蓝牙设防开
typedef void (^BLEBeginDrive)(LMError *error);          //开始骑行
typedef void (^BLEStopDrive)(LMError *error);           //停止骑行
typedef void (^BLEReboot)(LMError *error);           //重启
typedef void (^BLERestoreSetting)(LMError *error);           //重置设置
typedef void (^BLEWakeupMCU)(LMError *error);           //唤醒MCU
typedef void (^BLESettingTransportSwitch)(LMError *error);     //切换运输模式
typedef void (^BLEUpdareFirmware)(LMError *error);     //切换运输模式

#endif /* BLEDeviceBlock_h */

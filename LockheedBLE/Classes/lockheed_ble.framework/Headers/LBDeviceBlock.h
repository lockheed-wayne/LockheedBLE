//
//  BLEDeviceBlock.h
//  Leopard
//
//  Created by xwlsly on 2021/2/23.
//

#ifndef BLEDeviceBlock_h
#define BLEDeviceBlock_h
#include "LBError.h"

static NSString *LMBLEQueryStateKey_FenceSwitch = @"LMBLEQueryStateKey_FenceSwitch";
static NSString *LMBLEQueryStateKey_ManualAntiTheft = @"LMBLEQueryStateKey_ManualAntiTheft";
static NSString *LMBLEQueryStateKey_BLEAutoAntiTheft = @"LMBLEQueryStateKey_BLEAutoAntiTheft";
static NSString *LMBLEQueryStateKey_TransportSwitch = @"LMBLEQueryStateKey_TransportSwitch";
static NSString *LMBLEQueryStateKey_VibrationBeepDuration = @"LMBLEQueryStateKey_VibrationBeepDuration";
static NSString *LMBLEQueryStateKey_TheftBeepDuration = @"LMBLEQueryStateKey_TheftBeepDuration";
static NSString *LMBLEQueryStateKey_Battery = @"LMBLEQueryStateKey_Battery";
static NSString *LMBLEQueryStateKey_DeviceChargingStatus = @"LMBLEQueryStateKey_DeviceChargingStatus";

@class LBDevice;
#pragma mark BLEDeviceManager block
typedef void (^BLEManagerFindDevice)(NSArray <LBDevice *>*devices);
typedef void (^BLEManagerConnectedDevice)(LBDevice *device);
typedef void (^BLEManagerFailedConnectedDevice)(LBDevice *device, NSError *error);

#pragma mark BLEDevice block
typedef void (^BLEInitFinished)(LBError *error);
typedef void (^BLEqueryIMEI)(NSString *imei, LBError *error);
typedef void (^BLEqueryICCID)(NSString *iccid, LBError *error);
typedef void (^BLEAuthorization)(LBError *error);
typedef void (^BLEQueryState)(NSDictionary *stateDic, LBError *error);
typedef void (^BLEFindVehicle)(LBError *error);
typedef void (^BLEOpenFlyMode)(LBError *error);
typedef void (^BLEActive)(LBError *error);
typedef void (^BLEGoActive)(LBError *error);
typedef void (^BLECancelAlarm)(LBError *error);
typedef void (^BLESettingSavingModeSection)(LBError *error);
typedef void (^BLESettingVibrationSwitch)(LBError *error);
typedef void (^BLESettingGPSSwitch)(LBError *error);
typedef void (^BLESettingSavingModeSwitch)(LBError *error);    //省电模式开关
typedef void (^BLESettingBeepMode)(LBError *error);            //蜂鸣器设置
typedef void (^BLESettingFenceInfo)(LBError *error);           //电子围栏设置
typedef void (^BLESettingTheftSwitch)(LBError *error);         //盗车告警开关
typedef void (^BLESettingFenceSwitch)(LBError *error);         //电子围栏开关
typedef void (^BLESettingWakeupDuration)(LBError *error);      //设置定时唤醒时长
typedef void (^BLESettingAutoTheftSwitch)(LBError *error);     //自动开启防盗模式开关
typedef void (^BLESettingRolloverSwitch)(LBError *error);      //设置翻车告警开关
typedef void (^BLESettingRolloverBeepMode)(LBError *error);    //设置翻车告警后蜂鸣器时长
typedef void (^BLESettingTheftBeepMode)(LBError *error);       //设置盗车告警后蜂鸣器时长
typedef void (^BLESettingVibrationBeepMode)(LBError *error);   //设置震动唤醒后蜂鸣器响时长
typedef void (^BLESettingVibrationLevel)(LBError *error);      //设置震动唤醒等级
typedef void (^BLESettingGPSDuration)(LBError *error);         //设置GPS上报时间间隔
typedef void (^BLESettingBLEFortify)(LBError *error);          //蓝牙设防开
typedef void (^BLEBeginDrive)(LBError *error);          //开始骑行
typedef void (^BLEStopDrive)(LBError *error);           //停止骑行
typedef void (^BLEReboot)(LBError *error);           //重启
typedef void (^BLERestoreSetting)(LBError *error);           //重置设置
typedef void (^BLEWakeupMCU)(LBError *error);           //唤醒MCU
typedef void (^BLESettingTransportSwitch)(LBError *error);     //切换运输模式
typedef void (^BLEUpdareFirmware)(LBError *error);     //切换运输模式

#endif /* BLEDeviceBlock_h */

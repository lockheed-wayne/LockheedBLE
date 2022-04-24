//
//  BLECommand.h
//  BLEDemo
//
//  Created by xwlsly on 2021/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//手机发出的命令字
typedef enum : UInt8 {
    BLECommandType_IMEI = 0x01,
    BLECommandType_ICCID = 0x02,
    BLECommandType_BLEAuthorization = 0x03,
    BLECommandType_QueryState = 0x04,
#pragma mark 控车类
    BLECommandType_FindVehicle = 0x20,
    BLECommandType_FlyMode = 0x21,
    BLECommandType_Active = 0x22,
    BLECommandType_GoActive = 0x23,
    BLECommandType_CancelAlarm = 0x24,
    BLECommandType_Setting = 0x2f,
    BLECommandType_UpdatFirmware = 0x2a,
    BLECommandType_BeginDrive = 0x25,
    BLECommandType_StopDrive = 0x26,
    BLECommandType_Reboot = 0x27,
    BLECommandType_RestoreSetting = 0x28,
    BLECommandType_WakeupMCU = 0x29,
#pragma mark 收到的命令
    BLECommandType_Vibration = 0x10,
    BLECommandType_Theft = 0x11,        //盗车告警
    BLECommandType_Fence = 0x12,
    BLECommandType_LowPower = 0x18,
    BLECommandType_GPSLongTimeNotLocaltion = 0x19,
    BLECommandType_GPS = 0x1a,
    BLECommandType_Rollover = 0x1b,
    BLECommandType_Battery = 0x1c,
    BLECommandType_GMSGSignalStrength = 0x1d,
    BLECommandType_Wakeup = 0x1e,
    BLECommandType_Charging = 0x1f,
    BLECommandType_NotExist = 0xff
} BLECommandType;

typedef enum : UInt8 {
    BLECommandType_Setting_Type_SavingModeSection = 0x01,   //省电模式打开时间段
    BLECommandType_Setting_Type_VibrationSwitch = 0x02,     //震动告警开关
    BLECommandType_Setting_Type_GPSSwitch = 0x03,           //GPS开关
    BLECommandType_Setting_Type_SavingModeSwitch = 0x04,    //省电模式开关
    BLECommandType_Setting_Type_BeepMode = 0x05,            //蜂鸣器设置
    BLECommandType_Setting_Type_FenceInfo = 0x06,           //电子围栏设置
    BLECommandType_Setting_Type_TheftSwitch = 0x07,         //盗车告警开关
    BLECommandType_Setting_Type_FenceSwitch = 0x08,         //电子围栏开关
    BLECommandType_Setting_Type_WakeupDuration = 0x09,      //设置定时唤醒时长
    BLECommandType_Setting_Type_AutoTheftSwitch = 0x0a,     //自动开启防盗模式开关
    BLECommandType_Setting_Type_RolloverSwitch = 0x0b,      //设置翻车告警开关
    BLECommandType_Setting_Type_RolloverBeepMode = 0x0c,    //设置翻车告警后蜂鸣器时长
    BLECommandType_Setting_Type_TheftBeepMode = 0x0d,       //设置盗车告警后蜂鸣器时长
    BLECommandType_Setting_Type_VibrationBeepMode = 0x0e,   //设置震动唤醒后蜂鸣器响时长
    BLECommandType_Setting_Type_VibrationLevel = 0x0f,      //设置震动唤醒等级
    BLECommandType_Setting_Type_GPSDuration = 0x10,         //设置GPS上报时间间隔
    BLECommandType_Setting_Type_BLEFortifySwitch = 0x11,     //蓝牙设防开关
    BLECommandType_Setting_Type_TransportModeSwitch = 0x12,     //运输模式开关
    BLECommandType_Setting_Type_NotExist = 0xff
} BLECommandType_Setting_Type;

struct BLECommandStruct {
    UInt16 header;          //帧头，固定为5555
    UInt8 length;           //整个数据帧长度
    UInt8 type;              //帧类型
    UInt16 msgID;           //序列号，不同帧对应不同序列号，递增
    UInt8 *data;             //有效数据
    UInt8 crc;              //从帧头到有效数据的校验位
    UInt16 footer;          //帧尾，固定为AAAA
};

#define BLE_HeaderPosition  0
#define BLE_HeaderLength    2
#define BLE_LenghtPosition  2
#define BLE_LenghtLength    1
#define BLE_TypePosition    3
#define BLE_TypeLength      1
#define BLE_MsgIDPosition   4
#define BLE_MsgIDLength     2
#define BLE_DATAPosition    6
#define BLE_DATAEndLength   1
#define BLE_CrcLength       1
#define BLE_FooterLength    2
#define BLE_NotDataLenth    9




@interface BLECommandManager : NSObject

//KVO用于打印
@property (strong, nonatomic) NSData *cmdData;

@property (assign, nonatomic) UInt16 cmdID;

+(instancetype) shareInstance;

//普通命令的正确响应
-(NSData *) normalSuccessCommand:(BLECommandType) type msgID:(NSData *)msgID;
-(NSData *) normalFailedCommand:(BLECommandType) type msgID:(NSData *)msgID;

-(NSData *) buildNewCommandFor:(BLECommandType) type data:(nullable NSData *) data;
-(NSData *) buildResponseCommandFor:(BLECommandType) type data:(nullable NSData *) data msgID:(nullable NSData *) msgID;
//鉴权
-(NSData *) buildAuthorizationFor:(BLECommandType) type data:(nullable NSData *) data;

+(NSString *) stringCommandTypeBy:(BLECommandType) type;
+(NSString *) stringSettingCommandTypeBy:(BLECommandType_Setting_Type) type;
+(BLECommandType) phraseCommandType:(NSData *) data;

+(NSString *) locationStringByCommandType:(BLECommandType) type;


@end

NS_ASSUME_NONNULL_END

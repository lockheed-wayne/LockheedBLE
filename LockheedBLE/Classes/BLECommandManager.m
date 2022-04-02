//
//  BLECommand.m
//  BLEDemo
//
//  Created by xwlsly on 2021/1/25.
//

#import "BLECommandManager.h"
#import "BLEDeviceHeader.h"

//蓝牙通讯中返回正确
#define BLE_CMD_SUCCESS (0x00)

@interface BLECommandManager ()
@property (strong, nonatomic, readonly) NSMutableDictionary <NSNumber*, NSNumber*>*dicMsgID;  //消息ID

@end

@implementation BLECommandManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dicMsgID = [NSMutableDictionary dictionaryWithCapacity:32];
        
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_IMEI]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_ICCID]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_BLEAuthorization]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_FindVehicle]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_FlyMode]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_Active]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_GoActive]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_CancelAlarm]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_Setting]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_BeginDrive]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_StopDrive]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_Reboot]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_RestoreSetting]];
        [_dicMsgID setObject:@0 forKey:[NSNumber numberWithInteger:BLECommandType_WakeupMCU]];
    }
    return self;
}

+(instancetype) shareInstance{
    static dispatch_once_t onceToken;
    static BLECommandManager *bleCommandManager_;
    dispatch_once(&onceToken, ^{
        bleCommandManager_ = [[BLECommandManager alloc]init];
    });
    return bleCommandManager_;
}

-(Byte) crc8:(Byte *)data size:(UInt32)size{
    Byte crc = 0;
    
    if(data != NULL && size > 0){
        for(UInt32 i=0; i<size; i++){
            crc ^= data[i];
        }
    }
    return crc;
}

//每次调用加1
-(NSInteger) loadNewMsgID{
    @synchronized (self) {
        _cmdID += 1;
        
        if(_cmdID <= 0){
            _cmdID = 1;
        }else if(_cmdID > UINT16_MAX){
            _cmdID = 0;
        }
        
        return _cmdID;
    }
}

-(NSData *) buildNewCommandFor:(BLECommandType) type data:(nullable NSData *) data{
    Byte dataLength = 0;
    
    if(data != nil){
        dataLength = data.length;
    }
    
    Byte length = dataLength + 10;
    UInt16 msgID = (UInt16)[self loadNewMsgID];
    Byte msgIDH = msgID/0x100;
    Byte msgIDL = msgID%0x100;
    
    Byte msgBody[length];// = {0x55,0x55, length, type, msgIDH, msgIDL};
    msgBody[0] = 0x55;
    msgBody[1] = 0x55;
    msgBody[2] = length;
    msgBody[3] = type;
    msgBody[4] = msgIDH;
    msgBody[5] = msgIDL;
    
    if(data != nil){
        Byte *dataBytes = (Byte *)[data bytes];
        
        for(int i=0; i<dataLength; i++){
            msgBody[6+i] = dataBytes[i];
        }
    }
    msgBody[5 + dataLength + BLE_DATAEndLength] = (Byte)0x01;
    
    Byte crc8 = [self crc8:msgBody size:dataLength + 5 + BLE_DATAEndLength + 1];
    
    msgBody[5 + dataLength + BLE_DATAEndLength + BLE_CrcLength] = crc8;
    msgBody[5 + dataLength + BLE_DATAEndLength + BLE_CrcLength + 1] = 0xaa;
    msgBody[5 + dataLength + BLE_DATAEndLength + BLE_CrcLength + 1 + 1] = 0xaa;
    
    NSData *cmdData = [NSData dataWithBytes:msgBody length:length];
    
    NSLog(@"build sending command %@: %@",[BLECommandManager stringCommandTypeBy:type], cmdData);
    self.cmdData = cmdData;
    
    return cmdData;
}

-(NSData *) buildResponseCommandFor:(BLECommandType) type data:(nullable NSData *) data msgID:(nullable NSData *) msgID{
    Byte dataLength = 0;
    
    if(data != nil){
        dataLength = data.length;
    }
    
    Byte length = dataLength + 9;
    Byte *msgIDByte = (Byte*)[msgID bytes];
    
    Byte msgBody[length];// = {0x55,0x55, length, type, msgIDH, msgIDL};
    msgBody[0] = 0x55;
    msgBody[1] = 0x55;
    msgBody[2] = length;
    msgBody[3] = type;
    
    if(msgIDByte != nil){
        msgBody[4] = msgIDByte[0];
        msgBody[5] = msgIDByte[1];
    }else{
        UInt16 msgID = (UInt16)[self loadNewMsgID];
        msgBody[4] = msgID/0x100;
        msgBody[5] = msgID%0x100;
    }
    
    if(data != nil){
        Byte *dataBytes = (Byte *)[data bytes];
        
        for(int i=0; i<dataLength; i++){
            msgBody[6+i] = dataBytes[i];
        }
    }
    
    Byte crc8 = [self crc8:msgBody size:dataLength + 5 + 1];
    
    msgBody[5 + dataLength + BLE_CrcLength] = crc8;
    msgBody[5 + dataLength + BLE_CrcLength + 1] = 0xaa;
    msgBody[5 + dataLength + BLE_CrcLength + 1 + 1] = 0xaa;
    
    NSData *cmdData = [NSData dataWithBytes:msgBody length:length];
    
    NSLog(@"build response command %@: %@",[BLECommandManager stringCommandTypeBy:type], cmdData);
    self.cmdData = cmdData;
    return cmdData;
}

-(NSData *) normalSuccessCommand:(BLECommandType) type msgID:(nonnull NSData *)msgID{
    Byte successByte = 0x00;
    NSData *successData = [NSData dataWithBytes:&successByte length:1];
    return [self buildResponseCommandFor:type data:successData msgID:msgID];
}

-(NSData *) normalFailedCommand:(BLECommandType) type msgID:(nonnull NSData *)msgID{
    Byte failedByte = 0x01;
    NSData *failedData = [NSData dataWithBytes:&failedByte length:1];
    return [self buildResponseCommandFor:type data:failedData msgID:msgID];
}

+(BLECommandType) phraseCommandType:(NSData *) data{
    if(data.length < 9)
        return BLECommandType_NotExist;
    
    Byte *bytes = (Byte *)[data bytes];
    
    return bytes[3];
}

+(NSString *) stringCommandTypeBy:(BLECommandType) type{
    switch (type) {
        case BLECommandType_IMEI :{
            return @"查询IMEI";
        }
        case BLECommandType_ICCID :{
            return @"查询ICCID";
        }
        case BLECommandType_BLEAuthorization :{
            return @"蓝牙鉴权";
        }
        case BLECommandType_QueryState:{
            return @"查询状态";
        }
        case BLECommandType_FindVehicle :{
            return @"找车";
        }
        case BLECommandType_FlyMode :{
            return @"打开飞行模式";
        }
        case BLECommandType_Active :{
            return @"激活";
        }
        case BLECommandType_GoActive :{
            return @"去激活";
        }
        case BLECommandType_CancelAlarm :{
            return @"取消告警";
        }
        case BLECommandType_Setting :{
            return @"设置";
        }
        case BLECommandType_UpdatFirmware:{
            return @"蓝牙升级";
        }
        case BLECommandType_BeginDrive :{
            return @"骑行开始";
        }
        case BLECommandType_StopDrive :{
            return @"骑行结束";
        }
        case BLECommandType_Reboot :{
            return @"远程重启";
        }
        case BLECommandType_RestoreSetting :{
            return @"远程恢复出厂设置";
        }
        case BLECommandType_WakeupMCU :{
            return @"App唤醒MCU";
        }
        case BLECommandType_Vibration :{
            return @"震动告警";
        }
        case BLECommandType_Theft :{
            return @"盗车告警";
        }
        case BLECommandType_Fence :{
            return @"电子围栏告警";
        }
        case BLECommandType_LowPower :{
            return @"低电告警";
        }
        case BLECommandType_GPSLongTimeNotLocaltion :{
            return @"GPS长时间不定位告警";
        }
        case BLECommandType_GPS :{
            return @"GPS数据";
        }
        case BLECommandType_Rollover :{
            return @"翻车告警";
        }
        case BLECommandType_Battery :{
            return @"电池电量";
        }
        case BLECommandType_GMSGSignalStrength :{
            return @"信号强度";
        }
        case BLECommandType_Wakeup :{
            return @"休眠唤醒事件";
        }
        case BLECommandType_Charging :{
            return @"充电事件";
        }
        case BLECommandType_NotExist :{
            return @"不在存";
        }
        default:
            break;
            return @"BLECommandType_NotExist";
    }
}

+(NSString *) stringSettingCommandTypeBy:(BLECommandType_Setting_Type) type{
    switch (type) {
        case BLECommandType_Setting_Type_SavingModeSection:    //省电模式打开时间段
            return @"省电模式打开时间段";
            break;
        case BLECommandType_Setting_Type_VibrationSwitch:
            return @"震动告警开关";
        case BLECommandType_Setting_Type_GPSSwitch:
            return @"GPS开关";
        case BLECommandType_Setting_Type_SavingModeSwitch:
            return @"省电模式开关";
        case BLECommandType_Setting_Type_BeepMode:
            return @"蜂鸣器模式";
        case BLECommandType_Setting_Type_FenceInfo:
            return @"电子围栏设置";
        case BLECommandType_Setting_Type_TheftSwitch:
            return @"防盗开关";
        case BLECommandType_Setting_Type_FenceSwitch:
            return @"电子围栏开关";
        case BLECommandType_Setting_Type_WakeupDuration:
            return @"定时唤醒时长";
        case BLECommandType_Setting_Type_AutoTheftSwitch:
            return @"自动防盗开关";
        case BLECommandType_Setting_Type_RolloverSwitch:
            return @"翻车告警开关";
        case BLECommandType_Setting_Type_RolloverBeepMode:
            return @"翻车告警蜂鸣器模式";
        case BLECommandType_Setting_Type_TheftBeepMode:
            return @"防盗蜂鸣器模式";
        case BLECommandType_Setting_Type_VibrationBeepMode:
            return @"振动蜂鸣器模式";
        case BLECommandType_Setting_Type_VibrationLevel:
            return @"震动唤醒等级";
        case BLECommandType_Setting_Type_GPSDuration:
            return @"GPS上报间隔时长";
        case BLECommandType_Setting_Type_BLEFortifySwitch:
            return @"蓝牙设防";
        case BLECommandType_Setting_Type_TransportModeSwitch:
            return @"运输模式开关";
        default:
            return nil;
    }

    return @"不存在";
}

+(NSString *) locationStringByCommandType:(BLECommandType) type{
    switch (type) {
        case BLECommandType_Vibration:
            return NSLocalizedString(@"Vibration", nil);
        case BLECommandType_Theft:
            return NSLocalizedString(@"Anti-theft", nil);
        case BLECommandType_Fence:
            return NSLocalizedString(@"Geo-fence", nil);
        default:
            break;
    }
    return @"";
}
    
@end

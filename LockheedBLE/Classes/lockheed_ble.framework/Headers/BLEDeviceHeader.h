//
//  BLEDevice.h
//  Pods
//
//  Created by xwlsly on 2021/1/19.
//

#ifndef BLEDeviceHeader_h
#define BLEDeviceHeader_h

#import "BLEDeviceManager.h"
#import "BLECommandManager.h"
#import "LMError.h"
#import "BLETools.h"
#import "BLEDevice.h"
#import "BLEFence.h"

//解析命令后的数据，通过字典返回，使用以下key
static const NSString *kDevice_Error = @"kDevice_Error";
static const NSString *kDevice_IMEI = @"kDevice_IMEI";
static const NSString *kDevice_ICCID = @"kDevice_ICCID";
static const NSString *kDevice_TheftStatus = @"kDevice_TheftStatus";

static const NSString *kDevice_GPS = @"kDevice_GPS";
static const NSString *kDevice_GPS_fixTime = @"kDevice_GPS_fixTime";	//定位时间
static const NSString *kDevice_GPS_fixSource = @"kDevice_GPS_fixSource";	//定位来源
static const NSString *kDevice_GPS_dataValidity = @"kDevice_GPS_dataValidity";	//定位有效性: 0-实时，1-最近一次
static const NSString *kDevice_GPS_longtiType = @"kDevice_GPS_longtiType";	//东西经: 0-东经， 1-西经
static const NSString *kDevice_GPS_latiType = @"kDevice_GPS_latiType";	//南北纬: 0-南纬， 1-北纬
static const NSString *kDevice_GPS_satilliteNum = @"kDevice_GPS_satilliteNum";	//定位卫星个数
static const NSString *kDevice_GPS_hight = @"kDevice_GPS_hight";	//高度
static const NSString *kDevice_GPS_latitude = @"kDevice_GPS_latitude";	//经度
static const NSString *kDevice_GPS_longtitude = @"kDevice_GPS_longtitude";	//纬度
static const NSString *kDevice_GPS_speed = @"kDevice_GPS_speed";	//GPS速度
static const NSString *kDevice_GPS_direction = @"kDevice_GPS_direction";	//航向
static const NSString *kDevice_GPS_pdopValue = @"kDevice_GPS_pdopValue";	//位置经度因子
static const NSString *kDevice_GPS_hdopValue = @"kDevice_GPS_hdopValue";	//水平分量经度因子
static const NSString *kDevice_GPS_vdopValue = @"kDevice_GPS_vdopValue";	//垂直分量经度因子
static const NSString *kDevice_GPS_haccValue = @"kDevice_GPS_haccValue";	//水平经度估计

static const NSString *kDevice_BatteryLevel = @"kDevice_BatteryLevel";
static const NSString *kDevice_GMSGSignalStrengthLevel = @"kDevice_GMSGSignalStrengthLevel";
static const NSString *kDevice_WakeupEvent = @"kDevice_WakeupEvent";
static const NSString *kDevice_ChargingStatus = @"kDevice_ChargingStatus";




#endif /* BLEDeviceHeader_h */

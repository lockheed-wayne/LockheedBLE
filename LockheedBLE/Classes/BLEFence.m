//
//  BLEFence.m
//  BLEDemo
//
//  Created by xwlsly on 2021/1/27.
//

#import "BLEFence.h"
#import "LBCocoaSecurity.h"

@implementation BLEFence

-(NSData *) getFenceData{
    Byte cmd[29] = {
        0x06,                                       //0
        0x08,   //圆形                               //1
        0x00,   //更新区域                            //2
        0x01,   //区域个数                            //3
        0x00,   //区域ID 0-2                         //4
        0x00,   //是否有效                            //5
        //区域有效性字节定义：bit0:时间有效性，bit1:车速有效性；bit6：0-北纬、1-南纬； bit7：0-东经、1-西经
        0x00, 0xc0, //区域属性, 1100 0011             //6, 7
        0x52,       //最高速度                        //8
        0x02, 0x09, 0xa9, 0xab, //中心纬度            //9,10,11,12
        0x06, 0x7d, 0x52, 0xdf, //中心经度            //13,14,15,16
        0x00, 0x00, 0x00, 0x64, //半径               //17,18,19,20
        0x00, 0x00, 0x00, 0x00, //起始时间            //21,22,23,24
        0xff, 0xff, 0xff, 0xff};    //结束时间        //25,26,27,28
    
    //确认南北纬
    if(_center.latitude > 0){
        cmd[7] &= 0xbf;
    }else{
        cmd[7] |= 0x40;
    }
    
    //确认东西经
    if(_center.longitude > 0){
        cmd[7] &= 0x7f;
    }else{
        cmd[7] |= 0x80;
    }
    
    //最高速度设置为0
    cmd[8] = 0x00;
    
    int latitude = fabs(_center.latitude) * 1000000;
    int longitude = fabs(_center.longitude) * 1000000;
    
    NSInteger radius = _radius;
    latitude = abs(latitude);
    longitude = abs(longitude);
    //设置纬度
    cmd[9] = (latitude & 0xff000000) >> 24;
    cmd[10] = (latitude & 0x00ff0000) >> 16;
    cmd[11] = (latitude & 0x0000ff00) >> 8;
    cmd[12] = (latitude & 0x000000ff);
    

    //设置经度
    cmd[13] = (longitude & 0xff000000) >> 24;
    cmd[14] = (longitude & 0x00ff0000) >> 16;
    cmd[15] = (longitude & 0x0000ff00) >> 8;
    cmd[16] = (longitude & 0x000000ff);
    
    
    //设置半径
    cmd[17] = lround(radius / 0x1000000);
    cmd[18] = lround(radius / 0x10000) % 0x100;
    cmd[19] = lround(radius / 0x100) % 0x10000;
    cmd[20] = lround(radius) % 0x1000000;
    
    NSMutableData *cmdData = [NSMutableData dataWithBytes:cmd length:29];
    
    LBCocoaSecurityEncoder *encoder = [LBCocoaSecurityEncoder new];
    NSString *dataString = [encoder hex:cmdData useLower:YES];
    NSLog(@"%@",dataString);
    return cmdData;
}

-(instancetype) initWithCenter:(CLLocationCoordinate2D) center radius:(NSInteger) radius{
    self = [super init];
    if(self){
        _center = center;
        _radius = radius;
    }
    return self;
}

@end

//
//  BLEFence.h
//  BLEDemo
//
//  Created by xwlsly on 2021/1/27.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : UInt8 {
    FenceShape_Circle = 0x08        //圆型区域
} FenceShape;

typedef enum : UInt8 {
    FenceID_0 = 0,
    FenceID_1 = 1,
    FenceID_2 = 2,
} FenceID;

#define BLEFenceDefaultRadius   (100)

@interface BLEFence : NSObject

@property (assign, nonatomic) FenceShape shape;
@property (assign, nonatomic) FenceID fenceID;     //目前仅有3个区域，分别为0-2
@property (assign, nonatomic) BOOL bWork;           //是否有效，默认0
@property (assign, nonatomic) BOOL bTimeDurationWork;       //设置的时间是否有效
@property (strong ,nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *stop;
@property (assign, nonatomic) BOOL bSpeedLimit;     //是否限速
@property (assign, nonatomic) UInt8 speed;
@property (assign, nonatomic) CLLocationCoordinate2D center;
@property (assign, nonatomic) NSInteger radius;

-(NSData *) getFenceData;

-(instancetype) initWithCenter:(CLLocationCoordinate2D) center radius:(NSInteger) radius;

@end

NS_ASSUME_NONNULL_END

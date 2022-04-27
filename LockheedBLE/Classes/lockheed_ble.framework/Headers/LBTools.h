//
//  BLETools.h
//  BLEDemo
//
//  Created by xwlsly on 2021/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBTools : NSObject

+ (NSString *)lb_convertDataToHexStr:(NSData *)data;
+ (NSData *)lb_convertString2ASCIIData:(NSString *) string;
+ (NSData *)lb_convertDate2Intervalue:(NSDate *) date;
+ (NSData *)lb_converLastTime2Data:(NSInteger) lastTime;

@end

NS_ASSUME_NONNULL_END

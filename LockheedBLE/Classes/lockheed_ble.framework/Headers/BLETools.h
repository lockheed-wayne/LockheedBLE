//
//  BLETools.h
//  BLEDemo
//
//  Created by xwlsly on 2021/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLETools : NSObject

+ (NSString *)convertDataToHexStr:(NSData *)data;
+ (NSData *) convertString2ASCIIData:(NSString *) string;
+(NSData *) convertDate2Intervalue:(NSDate *) date;
+(NSData *) converLastTime2Data:(NSInteger) lastTime;

@end

NS_ASSUME_NONNULL_END

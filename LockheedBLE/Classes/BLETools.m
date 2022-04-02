//
//  BLETools.m
//  BLEDemo
//
//  Created by xwlsly on 2021/1/25.
//

#import "BLETools.h"

@implementation BLETools

+ (NSString *)convertDataToHexStr:(NSData *)data{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+ (NSData *) convertString2ASCIIData:(NSString *) string{
    NSMutableString *mString = [[NSMutableString alloc]init];
    
    const char *ch = [string cStringUsingEncoding:NSASCIIStringEncoding];
    for(int i=0; i<strlen(ch); i++){
        [mString appendString:[NSString stringWithFormat:@"%02x", ch[i]]];
    }
    
    NSData *data = [NSData dataWithBytes:ch length:strlen(ch)];
    
    return data;
}

+(NSData *) convertDate2Intervalue:(NSDate *) date{
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    Byte dateByte[4];
    NSLog(@"time: %x", (UInt32)timeInterval);
    
    dateByte[0] = (UInt32)timeInterval / 0x1000000;
    dateByte[1] = ((UInt32)timeInterval / 0x10000) % 0x100;
    dateByte[2] = ((UInt32)timeInterval / 0x100) % 0x10000;
    dateByte[3] = (UInt32)timeInterval % 0x1000000;
    
    return [NSData dataWithBytes:dateByte length:4];
}

+(NSData *) converLastTime2Data:(NSInteger) lastTime{
    Byte dataByte[2];
    
    dataByte[0] = lastTime / 0x100;
    dataByte[1] = lastTime % 0x100;
    
    return [NSData dataWithBytes:dataByte length:2];
}

@end

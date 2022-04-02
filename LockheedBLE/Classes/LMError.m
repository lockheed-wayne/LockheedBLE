//
//  BLEError.m
//  BLEDemo
//
//  Created by xwlsly on 2021/1/26.
//

#import "LMError.h"

@implementation LMError


-(instancetype) initWithError:(nullable NSString *) err code:(LMErrorCode) code{
    self = [super init];
    if(self){
        _errorMessage = err;
        _code = code;
    }
    
    return self;
}

-(nullable NSString *) getErrorMessage{
    return _errorMessage;
}

//对错误做二次大类的区分
-(LMErrorCodeType) getErrorType{
    NSString *stringCode = [NSString stringWithFormat:@"%ld", self.code];
    
    if(
       _code == kLMErrorCode_TokenExpries ||
       _code == 1027      //用户不存在
       ){
        return LMErrorCodeType_InvalidToken;}
    else if([[stringCode substringToIndex:1] isEqualToString:@"1"]){
        return LMErrorCodeType_ShowMsg;
    }else if([[stringCode substringToIndex:1] isEqualToString:@"4"] ||
             [[stringCode substringToIndex:1] isEqualToString:@"5"]
             ){
        return LMErrorCodeType_SystemError;
    }else if(
             [[stringCode substringToIndex:1] isEqualToString:@"9"]
             ){
        return LMErrorCodeType_BLEError;
    }else{
        return LMErrorCodeType_Undefine;
    }
}


+(instancetype) SuccessError{
    LMError *error = [[LMError alloc]initWithError:@"Success" code:kLMErrorCode_Sucess];
    return error;
}

+(instancetype) normalFailedError{
    LMError *error = [[LMError alloc]initWithError:@"Failed to set device" code:kLMErrorCode_BLEError];
    return error;
}

-(BOOL) isSuccess{
    if(self.code == kLMErrorCode_Sucess)
        return YES;
    
    return NO;
}

@end

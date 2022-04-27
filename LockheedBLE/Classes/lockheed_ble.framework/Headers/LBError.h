//
//  BLEError.h
//  BLEDemo
//
//  Created by xwlsly on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//以4开头的代码为代码性错误
#define LMCodeErrorPrefix       4
//以1开头的错误代码，使用服务器返回的错误
#define LMServiceTipErrorPrefix 1
//以3开头的错误代码，需要进行逻辑处理
#define LMAppErrorTipPrefix     3

typedef NS_ENUM(NSInteger,LMErrorCode) {
    kLMErrorCode_undefined = -1,        //未定义
    kLMErrorCode_Sucess = 0,            //成功

    kLMErrorCode_BikeNotExist = 1011,   //车辆不存在
    kLMErrorCode_TokenExpries = 4003,   //TOKEN过期
    
#pragma mark iOS程序自定义错误
    kLMErrorCode_ErrorJsonFormat = 90001,
    kLMErrorCode_MacIsNull = 10001,     //mac地址为空
    kLMErrorCode_OTAFileIsNULL = 10002,     //OTA文件为空
    kLMErrorCode_OTAFileDownloadFailed = 10003, //OTA文件下载失败
    
#pragma mark 蓝牙定义错误
    kLMErrorCode_PhraseError = 91001,
    kLMErrorCode_BLEError = 91002,      //蓝牙错误
    
    
    kLMErrorCode_ParameterIsNull,       //参数为空
};

typedef enum : NSUInteger {
    LMErrorCodeType_Undefine = 0,   //无错误，或未定义的错误
    LMErrorCodeType_ShowMsg,        //直接显示后台返回错误
    LMErrorCodeType_InvalidToken,   //token过期，需要重新登录
    LMErrorCodeType_SystemError,    //系统错误，报错
    LMErrorCodeType_BLEError,       //蓝牙类错误
}LBErrorCodeType;

static NSString *ErrorDomain_ReceivedDataError = @"ErrorDomain_ReceivedDataError";

@interface LBError : NSObject


@property (assign, nonatomic, getter=getErrorType) LBErrorCodeType errorType;
@property (assign, nonatomic) LMErrorCode code;
@property (strong, nonatomic, getter=getErrorMessage, nullable) NSString *errorMessage;

-(nullable instancetype) initWithError:(nullable NSString *) err code:(LMErrorCode) code;

+(instancetype) SuccessError;
+(instancetype) normalFailedError;

-(BOOL) isSuccess;

@end

NS_ASSUME_NONNULL_END

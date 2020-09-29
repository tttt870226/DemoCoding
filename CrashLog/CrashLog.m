//
//  CrashLog.m
//  TestCrashLog
//
//  Created by skynj on 2020/9/24.
//  Copyright © 2020 skynj. All rights reserved.
//

#import "CrashLog.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <sys/utsname.h>
#import "AppDelegate.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString *const SingalExceptionHandlerAddressesKey = @"SingalExceptionHandlerAddressesKey";
NSString *const ExceptionHandlerAddressesKey = @"ExceptionHandlerAddressesKey";
const int32_t _uncaughtExceptionMaximum = 20;
// 系统信号截获处理方法
void signalHandler(int signal);
// 异常截获处理方法
void exceptionHandler(NSException *exception);
 
void signalHandler(int signal)
{
    NSLog(@"signalHandler");
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > _uncaughtExceptionMaximum) {
        return;
    }
    // 获取信息
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [CrashLog backtrace];
    [userInfo  setObject:callStack  forKey:SingalExceptionHandlerAddressesKey];
    
    NSException* exception=  [NSException
                              exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                              reason:
                              [NSString stringWithFormat:
                               NSLocalizedString(@"Signal %d was raised", nil),signal]
                              userInfo:
                              [NSDictionary
                               dictionaryWithObject:[NSNumber numberWithInt:signal]
                               forKey:UncaughtExceptionHandlerSignalKey]];
    [CrashLog upLogData:exception];
}
 
void exceptionHandler(NSException *exception)
{
    NSLog(@"exceptionHandler");
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > _uncaughtExceptionMaximum) {
        return;
    }
    NSArray *callStack = [CrashLog backtrace];
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:ExceptionHandlerAddressesKey];
    NSLog(@"Exception Invoked: %@", userInfo);
//    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
//    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
//    NSString *name = [exception name];//异常类型
    //打印错误信息：
//    NSLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
    [CrashLog upLogData:exception];
}


@implementation CrashLog

+(void)load{
    NSLog(@"崩溃日志信息监听启动");
    [CrashLog installExceptionHandler];
    
//    [CrashLog upLogData:nil];
    
}

//获取调用堆栈
+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack,frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i=0;i<frames;i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

// 注册崩溃拦截
+ (void)installExceptionHandler
{
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGHUP, signalHandler);
    signal(SIGINT, signalHandler);
    signal(SIGQUIT, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
}

/**
 *上传错误日志
 */
+(void)upLogData:(NSException*)exception{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString* url = [delegate.viewController.settings objectForKey:@"eapp_pm_ulr"];
    if (url==nil||url .length<=0) {
        return;
    }
    // 当前应用名称
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (appCurName==NULL || appCurName.length<=0) {
        appCurName = [infoDictionary objectForKey:@"CFBundleName"];
    }
    NSLog(@"当前应用名称：%@",appCurName);
    
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    NSString* log_desc = [NSString stringWithFormat:@"appname:%@  \n errorname:%@    \n reason:  %@   \n  exception:%@",appCurName,name,reason,arr];
    
    url=[NSString stringWithFormat:@"%@logTable/addLog.do",url];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]initWithCapacity:2];
    NSString *bundleId = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    NSLog(@"bundleId:%@",bundleId);
    [params setValue:bundleId forKey:@"package_id"];
    [params setValue:log_desc forKey:@"log_desc"];
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    [params setValue:appCurVersionNum forKey:@"sys_version"];
    NSString* mobileType = [CrashLog deviceModelName];
    [params setValue:mobileType forKey:@"phone_type"];
    [params setValue:@"2" forKey:@"platform_id"];   //平台id IOS 都是2
    [CrashLog requestWithMethods:@"POST" url:url params:params cookies:NULL block:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    //让程序短暂不死掉，进行发送服务器
    sleep(2);
    
}


/**
 普通的网络请求
 @param method POST GET
 @param url 请求url
 @param params 请求参数
 @param cookies cookies
 @param block 回调
 */
+ (NSURLSessionTask *)requestWithMethods:(NSString *)method
                                     url:(NSString *)url
                                  params:(NSDictionary *)params
                                 cookies:(NSArray *)cookies
                                   block:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))block {
    NSMutableURLRequest *request = nil;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if ([method isEqualToString:@"GET"]) {
        NSString *body = [self getPrams:params];
        if (body.length > 0) {
            url = [url stringByAppendingFormat:@"?%@",body];
            // url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];  //新版本改用这个了，对url中文转码
        }
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    }else if ([method isEqualToString:@"POST"]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                         error:nil];
        NSString *bodys = [[NSString alloc] initWithData:data
                                                encoding:NSUTF8StringEncoding];
        NSData *bodyData = [bodys dataUsingEncoding: NSUTF8StringEncoding];
        [request setHTTPBody: bodyData];
        
    }
    request.HTTPMethod = method;
    request.timeoutInterval = 30;
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    for (NSDictionary *obj in cookies) {
        for (NSString *key in obj.allKeys) {
            [request addValue:obj[key] forHTTPHeaderField:key];
        }
    }
    NSURLSession *postSession = [NSURLSession sharedSession];
    NSURLSessionTask *uploadTask = [[NSURLSessionTask alloc]init];
    uploadTask = [postSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (block) {
                block(data,response,error);
            }
        }else{
            if (block) {
                block(data,response,error);
            }
        }
    }];
    [uploadTask resume];
    return uploadTask;
}

+ (NSString*)getPrams:(NSDictionary*)params{
    if (!params||params.count == 0) {
        return @"";
    }
    NSMutableString *mutableStr= [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableStr appendFormat:@"%@=",key];
        [mutableStr appendFormat:@"%@&",obj];
    }];
    
    [mutableStr deleteCharactersInRange:NSMakeRange(mutableStr.length-1, 1)];
    
    return mutableStr;
}
@end

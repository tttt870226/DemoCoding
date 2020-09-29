//
//  CrashLog.h
//  TestCrashLog
//
//  Created by skynj on 2020/9/24.
//  Copyright © 2020 skynj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashLog : NSObject

+ (NSArray *)backtrace;
+ (void)installExceptionHandler;
+(void)getDeviceInfo;
+(void)upLogData:(NSException*)exception;
@end

NS_ASSUME_NONNULL_END

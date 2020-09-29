//
//  IOSUtilTool.h
//  TestCrashLog
//
//  Created by skynj on 2020/9/24.
//  Copyright © 2020 skynj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOSUtilTool : NSObject

+(void)getDeviceInfo;
+ (NSString*)deviceModelName;
@end

NS_ASSUME_NONNULL_END

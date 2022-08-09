//
//  NetCenterService.h
//  IOS_Demo
//
//  Created by skynj on 2021/1/23.
//  Copyright © 2021 skynj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetCenterService : NSObject
+ (NSURLSessionTask *)requestWithMethods:(NSString *)method
                                     url: (NSString *)url
                                  params:(NSDictionary * __nullable)params
                                 cookies:(NSArray * __nullable)cookies
                                   block:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))block ;
@end

NS_ASSUME_NONNULL_END

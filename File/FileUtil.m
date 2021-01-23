//
//  FileUtil.m
//  IOS_Demo
//
//  Created by skynj on 2021/1/23.
//  Copyright © 2021 skynj. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil
+(void)writeFile:(id)data fileName:(NSString*)fileName{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = [docPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]){  //文件不存在
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSError* error = nil;
    if([data writeToFile:path atomically:YES]) //写数据
    {
        NSLog(@"write Success");
    }else{
        NSLog(@"write Failed =%@",[error localizedDescription]);
    }
}
+(id)readFile:(NSString*)fileName{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = [docPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]){  //文件不存在
        return nil;
    }
    NSMutableArray* array =  [NSMutableArray arrayWithContentsOfFile:path];
    if (!array) {
        NSLog(@"getFileList Failed:");
        return nil;
    }
    return array;
}
@end

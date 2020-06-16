//
//  ImageTurnGray.m
//  CordovaApp
//
//  Created by skynj on 2020/6/16.
//

#import "ImageTurnGray.h"

@implementation ImageTurnGray

/**
* 将一个图片转成灰度图片
*/
+(UIImage *)grayImage:(UIImage*)source
{
    int width = source.size.width;
    int height = source.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), source.CGImage);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:quartzImage];
    //这里必须释放CGImageRef 不释放会导致内存奔溃，CGBitmapContextCreateImage(context) 不要写在其他语句里
    CGImageRelease(quartzImage);
    CGContextRelease(context);
    return grayImage;
}
@end

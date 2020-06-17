//
//  ImageAddWaterMark.m
//  CordovaApp
//
//  Created by skynj on 2020/6/17.
//

#import "ImageAddWaterMark.h"

@implementation ImageAddWaterMark

/**
 *图片加水印
 */
+(UIImage *)ImageAddWaterMark:(UIImage*)source text:(NSString*)text
{
    
    NSDate* g_date = [NSDate date];
    NSDateFormatter* g_dateFormate = [[NSDateFormatter alloc]init];
    [g_dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    text = [g_dateFormate stringFromDate:g_date];

    int width = source.size.width;
    int height = source.size.height;
 
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
    [source drawInRect:CGRectMake(0, 0, width, height)];
    //从图形上下文获取图片
    float scale = width/1080.0;
    UIFont *font =[UIFont boldSystemFontOfSize:80*scale];
    
    CGRect rect = [@"水印名" boundingRectWithSize:CGSizeMake(MAXFLOAT, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
        
    //绘制文字
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode =NSLineBreakByCharWrapping;
    NSDictionary* attr=@{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:paragraphStyle,
        NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.8]
    };
    //添加文字
    [@"水印名" drawAtPoint:CGPointMake((width - rect.size.width)/2.0,(height/2.0-100*scale)-100*scale-20*scale) withAttributes:attr];
    rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    [text drawAtPoint:CGPointMake((width - rect.size.width)/2.0,(height/2.0-100*scale)) withAttributes:attr];
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;

}


@end

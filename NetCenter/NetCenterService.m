//
//  NetCenterService.m
//  IOS_Demo
//
//  Created by skynj on 2021/1/23.
//  Copyright © 2021 skynj. All rights reserved.
//

#import "NetCenterService.h"

@implementation NetCenterService

- (NSString*)getPrams:(NSDictionary*)params{
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
/**
 普通的网络请求
 
 @param method POST GET
 @param url 请求url
 @param params 请求参数
 @param cookies cookies
 @param block 回调
 */
- (NSURLSessionTask *)requestWithMethods:(NSString *)method
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
            NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet];
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:set];
            //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    NSURLSessionTask *uploadTask = nil;
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

/**
 上传文件
 
 @param method POST
 @param url 请求url
 @param data 文件流
 @param cookies cookies
 @param block 回调
 */
- (NSURLSessionTask *)upLoadFile:(NSString *)method
                                     url:(NSString *)url
                                  params:(NSData *)data
                                 cookies:(NSArray *)cookies
                                   block:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))block {
    NSMutableURLRequest *request = nil;
    
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSString* boundary = [self getRandomStringWithLength:6 isContainNum:NO];
    NSData* f_data = [self getBodyDataWithFileData:data fileName:@"myfile.jpg" params:nil boundary:boundary];
    [request setHTTPBody: f_data];
    request.HTTPMethod = method;
    request.timeoutInterval = 200;
    NSString* content= [NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary];
    [request addValue:content forHTTPHeaderField:@"Content-Type"];
     [request setValue:[NSString stringWithFormat:@"%ld", (long)f_data.length] forHTTPHeaderField:@"Content-Length"];
    for (NSDictionary *obj in cookies) {
        for (NSString *key in obj.allKeys) {
            [request addValue:obj[key] forHTTPHeaderField:key];
        }
    }
    NSURLSession *postSession = [NSURLSession sharedSession];
    NSURLSessionTask *uploadTask = nil;
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

#pragma mark -表单拼接

- (NSString *)getRandomStringWithLength:(int)length isContainNum:(BOOL)isContainNum{
    NSString *resultStr = [[NSString alloc] init];
    for (NSInteger i = 0; i< length; i++) {
        NSInteger num = isContainNum ? arc4random_uniform(75)+48:arc4random_uniform(58)+65;
        if (num > 57 && num < 65 && isContainNum){
            num = num%57+48; // 过滤ASCII值为58~64之间的字符
        }else if (num > 90 && num < 97){
            num = num%90+65;
        }
        resultStr = [resultStr stringByAppendingFormat:@"%ld",(long)num];
    }
    
    return  resultStr;
}

/*
     fileData: 文件数据
     fileName:文件名称
     params:其他的参数
     */
- (NSData *)getBodyDataWithFileData:(NSData *)fileData fileName:(NSString *)fileName params:(NSDictionary *)params boundary:(NSString*) boundary{
    NSString *KNewLineString = @"\r\n";
    NSData *KNewLine = [KNewLineString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    NSString *Kboundary = [[NSString alloc] initWithFormat:@"--%@",boundary];

    // 开始拼接其他参数
    for(NSString *keys in params.allKeys){
        [bodyData appendData:[Kboundary dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:KNewLine];
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"",keys];
        [bodyData appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:KNewLine];
        [bodyData appendData:KNewLine];
        NSString *value = [NSString stringWithFormat:@"%@",[params valueForKey:keys]];
        [bodyData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:KNewLine];
    }
    
    // 开始拼接图片数据
    [bodyData appendData:[Kboundary dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:KNewLine];
    NSString *configString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"",fileName];
    [bodyData appendData:[configString dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:KNewLine];
    NSString *contentTypeString = @"Content-Type:image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg";
    [bodyData appendData:[contentTypeString dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:KNewLine];
    [bodyData appendData:KNewLine];
    [bodyData appendData:fileData];
    [bodyData appendData:KNewLine];
    
    // 拼接数据结束
    [bodyData appendData:[Kboundary dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}



@end

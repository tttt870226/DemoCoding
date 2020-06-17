//
//  PlayVoiceTool.h
//  libWeexDCScanCodeInto
//
//  Created by guyong on 2019/10/31.
//  Copyright © 2019 Bian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PlayVoiceTool : NSObject


+(PlayVoiceTool*)shareInstance;
@property(nonatomic,retain)NSString* m_voiceText;
@property(nonatomic,retain)NSString* m_language;
@property(nonatomic,assign)float m_rate;
@property(nonatomic,assign)float m_volume;
-(void)playVoice;
@end

NS_ASSUME_NONNULL_END

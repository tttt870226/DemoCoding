//
//  PlayVoiceTool.m
//  libWeexDCScanCodeInto
//
//  Created by guyong on 2019/10/31.
//  Copyright © 2019 Bian. All rights reserved.
//

#import "PlayVoiceTool.h"
static PlayVoiceTool* playVoiceTool = nil;

@interface PlayVoiceTool()

@property(nonatomic,retain)AVSpeechSynthesizer* m_synthesizer;


@end

@implementation PlayVoiceTool
+(PlayVoiceTool*)shareInstance{
    if (playVoiceTool == nil) {
        playVoiceTool = [[PlayVoiceTool alloc] init];
        [playVoiceTool initPlayVoice];
    }

    return playVoiceTool;
}

-(void)initPlayVoice{
       AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
       self.m_synthesizer = synthesizer;
}

-(void)playVoice
{
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.m_language];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.m_voiceText];
        utterance.voice = voice;
        utterance.rate = self.m_rate; //语速
        utterance.pitchMultiplier = 0.8f;//音调
        utterance.volume = self.m_volume; //音量
        utterance.postUtteranceDelay = 0.0f;
        [self.m_synthesizer speakUtterance:utterance];
}

/**
 播放系统的声音
 */
+ (void)playScanQRCodeFoundSound
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    SystemSoundID   soundID;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"qrcode" ofType:@"wav"];
    CFURLRef soundFileURLRef = (__bridge CFURLRef) [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end

# PlayVoiceTool
 播放短音频功能，文字转语音播放
 ``` objective_c
 [PlayVoiceTool shareInstance].m_voiceText = content;
 [PlayVoiceTool shareInstance].m_volume = 1;
 [PlayVoiceTool shareInstance].m_language =@"zh_CN";
 [PlayVoiceTool shareInstance].m_rate = speed_voice;
 [[PlayVoiceTool shareInstance] playVoice];
 ```
 

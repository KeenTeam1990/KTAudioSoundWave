//
//  AudioRecorder.h
//  AudioRecorder
//
//  Created by builder on 2018/4/24.
//  Copyright © 2018年 builder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AudioRecorder;
@protocol AudioRecorderDelegate <NSObject>

@optional

- (void)audioRecorderDidVoiceChanged:(AudioRecorder *)recorder value:(double)value;

- (void)audioRecorderDidFinished:(AudioRecorder *)recorder successfully:(BOOL)flag;

@end

@interface AudioRecorder : NSObject

#pragma mark - 录音

///单例
+ (AudioRecorder *)shareInstance;
///设置委托
- (void)setRecorderDelegate:(id<AudioRecorderDelegate>)recorderDelegate;
///设置录音配置
- (void)setRecorderSetting:(NSMutableDictionary *)settingDict;
///开始录音
- (NSError *)startRecordWithFilePath:(NSString *)filePath;
///停止录音
- (void)stopRecord;
///获取录音路径
- (NSString *)getRecordFilePath;
///获取录音时长
- (NSTimeInterval )getRecordDurationWithFilePath:(NSString *)filePath;
///获得录音实例
- (AVAudioRecorder *)getAVAudioRecorder;

@end

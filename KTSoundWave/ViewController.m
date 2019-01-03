//
//  ViewController.m
//  DDSoundWave
//
//  Created by Teaker on 2018/4/6.
//  Copyright © 2018年 Liuzhida. All rights reserved.
//

#import "ViewController.h"
#import "DDSoundWaveView.h"
#import "UIView+LayoutMethods.h"
#import "AudioRecorder.h"
@interface ViewController ()<AudioRecorderDelegate>
@property (nonatomic, strong) DDSoundWaveView *waveView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waveView];
    //录音开始
    [[AudioRecorder shareInstance] startRecordWithFilePath:[self getFilePathWithFileName:@"DemoOneRecord.wav"]];
    [[AudioRecorder shareInstance] setRecorderDelegate:self];
  
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.waveView setCt_size:CGSizeMake(SCREEN_WIDTH, 200)];
    [self.waveView centerXEqualToView:self.view];
    [self.waveView setCt_y:SCREEN_HEIGHT-self.view.safeAreaBottomGap - SCREEN_HEIGHT/2];
}

#pragma mark - AudioRecorderDelegate
//音量
- (void)audioRecorderDidVoiceChanged:(AudioRecorder *)recorder value:(double)value{
    
    [self.waveView displayWave:value];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (DDSoundWaveView *)waveView {
    if (!_waveView) {
        _waveView = [[DDSoundWaveView alloc] init];
    }
    return _waveView;
}

#pragma mark ----------------- path ----------------
- (NSString *)getFilePathWithFileName:(NSString *)fileName{
    NSString * filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES ) lastObject];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    return filePath;
}
@end

//
//  DDSoundWaveView.m
//  DDSoundWave
//
//  Created by Teaker on 2018/4/6.
//  Copyright © 2018年 Liuzhida. All rights reserved.
//

#import "DDSoundWaveView.h"
#import "UIView+LayoutMethods.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioToolbox.h>

#define kNumberOfWaves 5

@interface DDSoundWaveView ()<AVAudioRecorderDelegate> {
    
    CGFloat _phase;          //相位
    CGFloat _phaseShift;     //相位偏移
    CGFloat _amplitude;      //振幅
    CGFloat _maxAmplitude;   //波峰
    CGFloat _idleAmplitude;  //波谷
    CGFloat _waveHeight;     //波高度
    CGFloat _waveWidth;      //波长度
    CGFloat _waveMid;        //波中心点
    CGFloat _density;        //波分布密度
    CGFloat _frequency;      //波频率
    CGFloat _mainWaveWidth;  //主波宽度
    CGFloat _decorativeWavesWidth;//其他波宽度
}
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> * waves;
@property (nonatomic, strong) CADisplayLink *displayLink;   //计时器，用于刷新layer布局
@property (nonatomic, strong) CALayer *waveLayer;  //存放波浪layer
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;   //录音器
@property (nonatomic, assign) BOOL animated;    //动画是否开始
@property (nonatomic, strong) UIButton *microphoneBtn;  //话筒
@end

@implementation DDSoundWaveView

#pragma mark - overwrite init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _phaseShift = -0.25f;
    _idleAmplitude = 0.01f;
    _density = 1.f;
    _frequency = 1.2f;
    _mainWaveWidth = 2.0f;
    _decorativeWavesWidth = 1.0f;
    
    self.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.waveLayer];
    [self microphoneGo];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.waveLayer.frame = self.bounds;
    [self.microphoneBtn sizeToFit];
    [self.microphoneBtn centerEqualToView:self];
}

- (void)dealloc {
    [_displayLink invalidate];
}

#pragma mark - Event repose

- (void)microphoneGo{
    
    if (_animated) {
        return;
    }
    __weak __typeof__(self) weak_self = self;
    if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            __strong __typeof__(weak_self) strong_self = weak_self;
            if (!strong_self) return ;
            if (granted) {
                //获取权限方法回调需要返回主线程操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strong_self startRecord];
                });
            }
        }];
    }else if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用麦克风" message:@"请在iPhone的""设置-APP-麦克风""中打开开关" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 10, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            } else {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#pragma clang diagnostic pop
                
            }
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }else {
        [self startRecord];
    }
    
}


- (void)microphoneDidTap:(UIButton *)sender {
//    if (_animated) {
//        return;
//    }
//    __weak __typeof__(self) weak_self = self;
//    if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionUndetermined) {
//        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//            __strong __typeof__(weak_self) strong_self = weak_self;
//            if (!strong_self) return ;
//            if (granted) {
//                //获取权限方法回调需要返回主线程操作
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [strong_self startRecord];
//                });
//            }
//        }];
//    }else if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionDenied) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用麦克风" message:@"请在iPhone的""设置-APP-麦克风""中打开开关" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (@available(iOS 10, *)) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//            } else {
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//#pragma clang diagnostic pop
//
//            }
//        }]];
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//        return;
//    }else {
//        [self startRecord];
//    }
}

- (void)endRecord:(UIGestureRecognizer *)recognizer {
    [self.audioRecorder stop];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    //remove from current runloop
    [UIView animateWithDuration:0.2 animations:^{
        self.microphoneBtn.transform = CGAffineTransformMakeScale(1, 1);
        self.microphoneBtn.alpha = 1;
        self.waveLayer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    } completion:^(BOOL finished) {
        self.waveLayer.hidden = YES;
    }];
}

#pragma mark - Private methods

// 开始录音
- (void)startRecord {
    if ([self.audioRecorder prepareToRecord]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.microphoneBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.microphoneBtn.alpha = 0;
            self.waveLayer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [self.audioRecorder record];
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            self.waveLayer.hidden = NO;
        }];
    }
}

// 刷新layer布局
- (void)displayWave {
    
    [self.audioRecorder updateMeters];//刷新音量数据
    double lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    _waveHeight = CGRectGetHeight(self.bounds);
    _waveWidth  = CGRectGetWidth(self.bounds);
    _waveMid    = _waveWidth / 2.0f;
    _maxAmplitude = _waveHeight - 4.0f;
    _phase += _phaseShift;
    _amplitude = fmax(lowPassResults, _idleAmplitude);
    
    UIGraphicsBeginImageContext(self.frame.size);
    for(int i = 0; i < self.waves.count; i++) {
        
        UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
        CGFloat progress = 1.0f - (CGFloat)i / kNumberOfWaves;
        CGFloat normedAmplitude = (1.5f * progress - 0.5f) * _amplitude;
        
        for(CGFloat x = 0; x < _waveWidth + _density; x += _density) {
            
            CGFloat scaling = -pow(x / _waveMid  - 1, 2) + 1;
            CGFloat y = scaling * _maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / _waveWidth) * _frequency + _phase) + (_waveHeight * 0.5);
            
            if (x==0) {
                [wavelinePath moveToPoint:CGPointMake(x, y)];
            }
            else {
                [wavelinePath addLineToPoint:CGPointMake(x, y)];
            }
        }
        
        CAShapeLayer *waveline = [self.waves objectAtIndex:i];
        waveline.path = [wavelinePath CGPath];
    }
    UIGraphicsEndImageContext();
}

#pragma mark - Getters

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayWave)];
    }
    return _displayLink;
}

- (NSMutableArray<CAShapeLayer *> *)waves {
    if (!_waves) {
        _waves = [NSMutableArray arrayWithCapacity:kNumberOfWaves];
        for (int i = 0; i < kNumberOfWaves; ++i) {
            CAShapeLayer *waveline = [CAShapeLayer layer];
            waveline.lineCap       = kCALineCapButt;
            waveline.lineJoin      = kCALineJoinRound;
            waveline.strokeColor   = [[UIColor clearColor] CGColor];
            waveline.fillColor     = [[UIColor clearColor] CGColor];
            [waveline setLineWidth:(i==0 ? _mainWaveWidth : _decorativeWavesWidth)];
            CGFloat progress = 1.0f - (CGFloat)i / kNumberOfWaves;
            CGFloat multiplier = MIN(1.0, (progress / 3.0f * 2.0f) + (1.0f / 3.0f));
            UIColor *color = [[UIColor greenColor] colorWithAlphaComponent:(i == 0 ? 1.0 : 1.0 * multiplier * 0.6)];
            waveline.strokeColor = color.CGColor;
            CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
            gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, 200);
            
            //设置颜色
            [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor cyanColor] CGColor],(id)[[UIColor greenColor] CGColor], nil]];
            //每种颜色最亮的位置
            [gradientLayer setLocations:@[@0,@1]];
            //渐变的方向StartPoint－>EndPoint
            [gradientLayer setStartPoint:CGPointMake(0, 0.5)];
            [gradientLayer setEndPoint:CGPointMake(1, 0.5)];
            
            gradientLayer.mask = waveline;
            [self.waveLayer addSublayer:gradientLayer];
            [_waves addObject:waveline];
        }
    }
    return _waves;
}

- (CALayer *)waveLayer {
    if (!_waveLayer) {
        _waveLayer = [CALayer layer];
    }
    return _waveLayer;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSMutableDictionary *recordSetting  = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        [recordSetting setValue:@(YES) forKey:AVLinearPCMIsFloatKey];
         NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/voice.aac", strUrl]];
        NSError *error;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
        //开启音量检测
        _audioRecorder.meteringEnabled = YES;
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}


@end

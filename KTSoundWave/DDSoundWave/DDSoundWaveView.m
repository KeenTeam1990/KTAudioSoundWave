//
//  DDSoundWaveView.m
//  DDSoundWave
//
//  Created by Teaker on 2018/4/6.
//  Copyright © 2018年 Liuzhida. All rights reserved.
//

#import "DDSoundWaveView.h"
#import "UIView+LayoutMethods.h"

#define kNumberOfWaves 5

@interface DDSoundWaveView ()
{

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
@property (nonatomic, strong) CALayer *waveLayer;  //存放波浪layer

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
   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.waveLayer.frame = self.bounds;
  
}

// 刷新layer布局
- (void)displayWave:(double)value{
  
    double lowPassResults = value; 
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

@end

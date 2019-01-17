# KTAudioSoundWave

     KTAudioSoundWave-根据语音音贝绘制波浪动画
     
# 效果图

| :--------------------------------------: |
|                  项目效果图                   |

![](https://github.com/liuzhida33/DDSoundWave/blob/master/images/soundwave.gif)


```
[self.waveView setCt_size:CGSizeMake(SCREEN_WIDTH, 200)];
[self.waveView centerXEqualToView:self.view];
[self.waveView setCt_y:SCREEN_HEIGHT-self.view.safeAreaBottomGap - SCREEN_HEIGHT/2];

- (DDSoundWaveView *)waveView {
if (!_waveView) {
_waveView = [[DDSoundWaveView alloc] init];
}
return _waveView;
}
```


# 新手项目，多多包涵，谢谢！有相关问题可以在线留言或发邮件至Keen_Team@163.com，谢谢！

# License
The MIT License (MIT)

Copyright (c) 2016 KEENTEAM

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


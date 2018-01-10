//
//  LPPlayHeader.h
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/10.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#ifndef LPPlayHeader_h
#define LPPlayHeader_h

/*************** 播放器风格  ***************/
typedef NS_ENUM(NSInteger, LPPlayStyle) {
    ///正常风格
    LPPlayStyleNormal = 0,
    ///极简风格
    LPPlayStyleEsay   = 1,
    ///直播风格
    LPPlayStyleLive   = 2,
};


#define LPPLAYER_WIDTH 45
#define ANIMATION_DURATION .3f


#endif /* LPPlayHeader_h */

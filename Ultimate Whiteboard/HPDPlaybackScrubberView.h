//
//  HPDPlaybackScrubberView.h
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 15/9/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPDPlaybackScrubberView : UIView

@property (nonatomic) int numberOfKeyframes;

- (void)newKeyframe;
- (void)clearKeyframes;
- (void)scrubberPlaybackToKeyframe:(int)keyframeNumber duration:(CGFloat)duration beginTime:(CFTimeInterval)beginTime;



@end

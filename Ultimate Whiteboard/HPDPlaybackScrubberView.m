//
//  HPDPlaybackScrubberView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 15/9/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <POP/POP.h>

#import "HPDPlaybackScrubberView.h"

@interface HPDPlaybackScrubberView ()

// to track number of keyframes
@property (nonatomic) NSMutableArray *keyframePointArray;

// track link rectangle
@property (nonatomic) UIView *linkRectangle;

// Options
@property (nonatomic) CGFloat pointDiameter;
@property (nonatomic) CGFloat linkRectangleAnimationDuration;
@end

@implementation HPDPlaybackScrubberView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _pointDiameter = 3;
        _numberOfKeyframes = 0;
        _linkRectangleAnimationDuration = 0.2;
        _keyframePointArray = [[NSMutableArray alloc] init];

//        self.contentMode = UIViewContentModeRedraw;
    }
    
    return self;
}

- (void)newKeyframe
{

    CGPoint firstPointPosition = CGPointMake(0, self.bounds.size.height/2.0);
    CGFloat gapBetweenPoints = 30;
    
    
    [self createPointatPosition:CGPointMake(firstPointPosition.x + gapBetweenPoints * self.numberOfKeyframes, firstPointPosition.y)];
    
}


- (void)createPointatPosition:(CGPoint)position
{
    
    // Create point and configure
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(position.x-self.pointDiameter/2.0, position.y- self.pointDiameter/2.0, self.pointDiameter, self.pointDiameter)];
    pointView.layer.cornerRadius = self.pointDiameter/2.0;
    pointView.backgroundColor = [UIColor grayColor];
    
    // Create animation for point
    POPSpringAnimation *pointAnimation = [POPSpringAnimation animation];
    pointAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    pointAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    pointAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(self.pointDiameter, self.pointDiameter)];
    
    // Only create link rectangle if its not the first keyframe
    if (self.numberOfKeyframes != 0) {
        CGFloat linkRectangleHeight = 5;
        
        // Delays the begin time of the point animation to after the link rectangle has animated
        pointAnimation.beginTime = CACurrentMediaTime() + self.linkRectangleAnimationDuration;
        
        // lazy loading of link rectangle
        if (!self.linkRectangle) {
            self.linkRectangle = [[UIView alloc] initWithFrame:CGRectMake(0, position.y - linkRectangleHeight/2.0, 0, linkRectangleHeight)];
            self.linkRectangle.backgroundColor = [UIColor grayColor];
            self.linkRectangle.layer.cornerRadius = 3;
            [self addSubview:self.linkRectangle];
        }
        
        // Create link rectangle animation
        POPBasicAnimation *linkRectangleAnimation = [POPBasicAnimation linearAnimation];
        linkRectangleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        linkRectangleAnimation.duration = self.linkRectangleAnimationDuration;
        linkRectangleAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.linkRectangle.frame.origin.x, self.linkRectangle.frame.origin.y, position.x, self.linkRectangle.bounds.size.height)];

        // Completion block needed to prevent pointview subview from being added before pointview is ready to animate
        [linkRectangleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            [self addSubview:pointView];
        }
         ];
        
        // Adds link rectangle animation
        [self.linkRectangle pop_addAnimation:linkRectangleAnimation forKey:nil];
        
    } else {
        // If its the first keyframe, do not load the link rectangle, simply add the pointview subview and start animating
        [self addSubview:pointView];
    }
    
    // Add animation to pointview
    [pointView pop_addAnimation:pointAnimation forKey:nil];

    // Cleanup
    self.numberOfKeyframes += 1;
    [self.keyframePointArray addObject:pointView];
}

- (void)clearKeyframes
{
    
    // Deal with pointviews
    for (UIView *pointView in self.keyframePointArray) {
        POPSpringAnimation *pointViewAnimateOut = [POPSpringAnimation animation];
        pointViewAnimateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
        pointViewAnimateOut.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
        // Completion block to only remove from superview after its done animating
        [pointViewAnimateOut setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            [pointView removeFromSuperview];
        }
         ];
        
        [pointView pop_addAnimation:pointViewAnimateOut forKey:nil];
    }
    [self.keyframePointArray removeAllObjects];
    
    
    // Deal with link Rectangle
    POPBasicAnimation *linkRectangleAnimateOut = [POPBasicAnimation linearAnimation];
    linkRectangleAnimateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    linkRectangleAnimateOut.duration = self.linkRectangleAnimationDuration;
    linkRectangleAnimateOut.toValue = [NSValue valueWithCGRect:CGRectMake(self.linkRectangle.frame.origin.x, self.linkRectangle.frame.origin.y, 0, self.linkRectangle.bounds.size.height)];
    [linkRectangleAnimateOut setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [self.linkRectangle removeFromSuperview];
    }
     ];
    [self.linkRectangle pop_addAnimation:linkRectangleAnimateOut forKey:nil];
    self.linkRectangle = nil;

    self.numberOfKeyframes = 0;
}




@end

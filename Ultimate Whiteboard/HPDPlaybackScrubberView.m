//
//  HPDPlaybackScrubberView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 15/9/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
// flatuicolors http://flatuicolors.com/

#import <POP/POP.h>

#import "HPDPlaybackScrubberView.h"

@interface HPDPlaybackScrubberView ()

// to track number of keyframes
@property (nonatomic) NSMutableArray *keyframePointArray;

// track link rectangle
@property (nonatomic) UIView *linkRectangle;
@property (nonatomic) UIView *linkRectangleScrubber;

// Options
@property (nonatomic) CGFloat pointDiameter;
@property (nonatomic) CGFloat linkRectangleAnimationDuration;
@property (nonatomic) CGFloat gapBetweenPoints;
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
        _gapBetweenPoints = 30;
        
        

//        self.contentMode = UIViewContentModeRedraw;
    }
    
    return self;
}

- (void)newKeyframe
{

    CGPoint firstPointPosition = CGPointMake(0, self.bounds.size.height/2.0);

    
    
    [self createPointatPosition:CGPointMake(firstPointPosition.x + self.gapBetweenPoints * self.numberOfKeyframes, firstPointPosition.y)];
    
}


- (void)createPointatPosition:(CGPoint)position
{
    
    UIColor *pointColor = [UIColor colorWithRed:241.0/255 green:196.0/255 blue:15.0/255 alpha:1.0]; // Flatuicolors sunflower
    
    // Create point and configure
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(position.x-self.pointDiameter/2.0, position.y- self.pointDiameter/2.0, self.pointDiameter, self.pointDiameter)];
    pointView.layer.cornerRadius = self.pointDiameter/2.0;
    pointView.backgroundColor = pointColor;
    
    // Create animation for point
    POPSpringAnimation *pointAnimation = [POPSpringAnimation animation];
    pointAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    pointAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    pointAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(self.pointDiameter, self.pointDiameter)];
    pointAnimation.springBounciness = 10;
    
    // Only create link rectangle if its not the first keyframe
    if (self.numberOfKeyframes != 0) {
        CGFloat linkRectangleHeight = 5;
        
        // Delays the begin time of the point animation to after the link rectangle has animated
        pointAnimation.beginTime = CACurrentMediaTime() + self.linkRectangleAnimationDuration;
        
        // lazy loading of link rectangle
        if (!self.linkRectangle) {
            self.linkRectangle = [[UIView alloc] initWithFrame:CGRectMake(0, position.y - linkRectangleHeight/2.0, 0, linkRectangleHeight)];
            self.linkRectangle.backgroundColor = pointColor;
            self.linkRectangle.layer.cornerRadius = 3;
            // need this to make the link rectangle behind the first point
            [self insertSubview:self.linkRectangle belowSubview:self.subviews[0]];
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
    NSLog(@"Keyframes: %i", self.numberOfKeyframes);
    [self.keyframePointArray addObject:pointView];
    [self scrubberPlaybackFromKeyframe:NO toKeyframe:1 duration:NO beginTime:NO]; // Removes scrubber if keyframe is added after scrubber is visible
}

- (void)clearKeyframes
{
    
    // Deal with pointviews
    for (UIView *pointView in self.keyframePointArray) {
//        POPSpringAnimation *pointViewAnimateOut = [POPSpringAnimation animation];
//        pointViewAnimateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
//        pointViewAnimateOut.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
        
        POPBasicAnimation *pointViewAnimateOut = [POPBasicAnimation animation];
        pointViewAnimateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        pointViewAnimateOut.toValue = @(0);
        
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
    [self scrubberPlaybackFromKeyframe:self.numberOfKeyframes toKeyframe:1 duration:NO beginTime:NO];
    self.linkRectangle = nil;
    self.numberOfKeyframes = 0;
}


- (void)scrubberPlaybackFromKeyframe:(int)startKeyframe toKeyframe:(int)endKeyframe duration:(CGFloat)duration beginTime:(CFTimeInterval)beginTime
{

//    UIColor *scrubberColor = [UIColor colorWithRed:230.0/255 green:126.0/255 blue:34.0/255 alpha:1.0]; //flatuicolors carrot
    UIColor *scrubberColor = [UIColor colorWithRed:236.0/255 green:240.0/255 blue:241.0/255 alpha:1.0]; //flatuicolors clouds
    
//    if (self.numberOfKeyframes >= 2) {
//        [self.linkRectangleScrubber removeFromSuperview];
//        self.linkRectangleScrubber = nil;
//    }
    
    if (!self.linkRectangleScrubber) {
        self.linkRectangleScrubber = [[UIView alloc] initWithFrame:CGRectMake(0, self.linkRectangle.frame.size.height/4.0, 0, self.linkRectangle.frame.size.height/2.0)];
        self.linkRectangleScrubber.backgroundColor = scrubberColor;
        self.linkRectangleScrubber.layer.cornerRadius = 3;
        [self.linkRectangle insertSubview:self.linkRectangleScrubber atIndex:0];
    }

    CGFloat currentRightEdgeOfRect = self.gapBetweenPoints * (startKeyframe-1);
    CGFloat newRightEdgeOfRect = self.gapBetweenPoints * (endKeyframe-1);
    
    POPBasicAnimation *linkRectangleAnimation = [POPBasicAnimation linearAnimation];
    linkRectangleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    
    if (startKeyframe) {
        linkRectangleAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(self.linkRectangleScrubber.frame.origin.x, self.linkRectangleScrubber.frame.origin.y, currentRightEdgeOfRect, self.linkRectangleScrubber.bounds.size.height)];
    }
    

    linkRectangleAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.linkRectangleScrubber.frame.origin.x, self.linkRectangleScrubber.frame.origin.y, newRightEdgeOfRect, self.linkRectangleScrubber.bounds.size.height)];
    
    // To configure options
    if (duration) {
        linkRectangleAnimation.duration = duration;
    } else {
        linkRectangleAnimation.duration = self.linkRectangleAnimationDuration;
    }
    
    if (beginTime) {
        linkRectangleAnimation.beginTime = beginTime;
    } else {
        linkRectangleAnimation.beginTime = 0;
    }
    
    // If keyframe number is one, animate out and remove the scrubber
    if (endKeyframe == 1) {
        [linkRectangleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            
            [self.linkRectangleScrubber removeFromSuperview];
            self.linkRectangleScrubber = nil; // always set to nil after removefromsuperview, so lazy init will work again

        }
         ];

    }
    
    [self.linkRectangleScrubber pop_addAnimation:linkRectangleAnimation forKey:nil];
    
}

@end

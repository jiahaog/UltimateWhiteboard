//
//  HPDMarker.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDMarker.h"

@interface HPDMarker ()

@property (nonatomic) UIView *viewToDrawOn;

@end

@implementation HPDMarker

- (instancetype)initWithMarkerType:(char)markerType viewToDrawOn:(UIView *)view
{
    self = [super init];
    _markerType = markerType;
    
    _markerWidth = 20;
    
    
    _viewToDrawOn = view;
    [self updateMarkerLayer];
    [self.viewToDrawOn.layer addSublayer:self.markerCALayer];
    
    return self;
}


- (void)updateMarkerLayer
{
    
//    if (!self.markerCALayer) {
//        self.markerCALayer = [CAShapeLayer layer];
//        self.markerCALayer.fillColor = [UIColor blueColor].CGColor;
//        self.markerCALayer.backgroundColor = [UIColor redColor].CGColor;
//    }
//    UIBezierPath *markerPath = [UIBezierPath bezierPathWithArcCenter:self.markerPosition radius:self.markerWidth startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
//    self.markerCALayer.path = markerPath.CGPath;
    [CATransaction setDisableActions:YES];
    if (!self.markerCALayer) {
        self.markerCALayer = [CALayer layer];

        self.markerCALayer.backgroundColor = [UIColor blueColor].CGColor;
    }
    NSLog(@"Updating Position to: %@", NSStringFromCGPoint(self.markerPosition));

    self.markerCALayer.cornerRadius = self.markerWidth/2.0;
    self.markerCALayer.bounds = CGRectMake(0, 0, self.markerWidth, self.markerWidth);
    self.markerCALayer.position = self.markerPosition;
    [CATransaction setDisableActions:NO];
    
}


@end

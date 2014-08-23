//
//  HPDFieldView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <POP/POP.h>

#import "HPDFieldView.h"
#import "HPDMarker.h"
#import "HPDFieldBackground.h"

@interface HPDFieldView ()


// Storage for markers
@property (nonatomic) NSMutableArray *allMarkers;
@property (nonatomic) NSMutableArray *selectedMarkers;

// properties to aid in touch tracking
@property (nonatomic) CGPoint touchDownPosition;


@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame fieldBounds:(CGRect)fieldBounds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _allMarkers = [[NSMutableArray alloc] init];
        
        HPDMarker *newMarker = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeBluePlayer viewToDrawOn:self];
        [_allMarkers addObject:newMarker];
        self.opaque = NO;
        
        newMarker.markerPosition = CGPointMake(200, 200);
        [newMarker updateMarkerLayer];
    }
    return self;
}



//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//
////
//}


#pragma mark - Drawing Methods

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    self.touchDownPosition = location;
    
    HPDMarker *selectedMarker = [self markerAtPoint:location];
    
    if (selectedMarker) {

        [self animateMarkerSelected:selectedMarker selected:YES];
        
        if (!self.selectedMarkers) {
            self.selectedMarkers = [[NSMutableArray alloc] init];
        }
        
        [self.selectedMarkers addObject:selectedMarker];
    }

    
}

- (HPDMarker *)markerAtPoint:(CGPoint)point
{
    float touchThreshold = 10;
    for (HPDMarker *marker in self.allMarkers) {
        CGPoint markerPosition = marker.markerPosition;
        if (hypot(point.x - markerPosition.x, point.y - markerPosition.y) < touchThreshold) {
            return marker;
        }
    }
    return nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectedMarkers) {
        UITouch *myTouch = [touches anyObject];
        CGPoint location = [myTouch locationInView:self];
        CGSize movedDistance = CGSizeMake(location.x - self.touchDownPosition.x, location.y - self.touchDownPosition.y);
        for (HPDMarker *marker in self.selectedMarkers) {
            CGPoint previousPosition = marker.markerPosition;
            marker.markerPosition = CGPointMake(previousPosition.x + movedDistance.width, previousPosition.y + movedDistance.height);
            [marker updateMarkerLayer];
            
        }
        self.touchDownPosition = location;

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectedMarkers) {
        for (HPDMarker *marker in self.selectedMarkers) {
            [self animateMarkerSelected:marker selected:NO];
        }
    }
    self.selectedMarkers = nil;
}

#pragma mark - Animation Methods

// BOOLEAN indicates true for touches begin, and false for touches ended
- (void)animateMarkerSelected:(HPDMarker *)marker selected:(BOOL)selected
{
    CGFloat scaleFactor = 1.8;
    CGFloat opacityFactor = 0.5;
    
    if (!selected) {
        scaleFactor = 1.0;
        opacityFactor = 1.0;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
    marker.markerCALayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
//    [marker.markerCALayer addAnimation:animation forKey:nil];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = [NSNumber numberWithFloat:opacityFactor];
    marker.markerCALayer.opacity = opacityFactor;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = [NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil];
    [marker.markerCALayer addAnimation:animation forKey:nil];

}

@end

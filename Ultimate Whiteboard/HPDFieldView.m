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

// Properties for field dimensions
@property (nonatomic) CGRect fieldBounds;

// properties to aid in touch tracking
@property (nonatomic) CGPoint touchDownPosition;
@property (nonatomic) NSValue *selectionBox;
@property (nonatomic) CALayer *selectionBoxLayer;

// Options
@property (nonatomic) int playersPerSide;
@property (nonatomic) CGFloat touchoffset; // Offset for touches so that touched markers are not beneath the finger



@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame fieldBounds:(CGRect)fieldBounds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Default options here
        _playersPerSide = 7;
        _touchoffset = 60;
        
        
        // Need this to show field background
        self.opaque = NO;
        
        // assigns field dimensions to properties
        _fieldBounds = fieldBounds;
        
        
        [self playerPositionEndzoneLines];
        

        
        
        
        // Create buttons to allow changing of formations
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        button1.backgroundColor = [UIColor orangeColor];
        [button1 addTarget:self action:@selector(playerPositionEndzoneLines) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button1];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 50, 50)];
        button2.backgroundColor = [UIColor purpleColor];
        [button2 addTarget:self action:@selector(playerPositionVerticalStack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button2];
        
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(pinch:)];
        [self addGestureRecognizer:pinchRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapRecognizer];
        
        
        
        
    }
    return self;
}



//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//
////
//}

#pragma mark - Player Positions

- (void)initMarkers
{
    self.allMarkers = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= self.playersPerSide; i++) {
        HPDMarker *newBluePlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeBluePlayer viewToDrawOn:self];
        [self.allMarkers addObject:newBluePlayer];
        HPDMarker *newRedPlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer viewToDrawOn:self];
        [self.allMarkers addObject:newRedPlayer];
    }
    
    HPDMarker *disc = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeDisc viewToDrawOn:self];
    [self.allMarkers addObject:disc];

}

- (void)playerPositionEndzoneLines
{
    
    if (!self.allMarkers) {
        [self initMarkers];
    }
    
    [self deselectMarkers];
    
    CGFloat interval = self.fieldBounds.size.width/(self.playersPerSide + 1);
    
    int blueCounter = 0;
    int redCounter = 0;
    for (HPDMarker *marker in self.allMarkers) {
        if (marker.markerType == HPDMarkerTypeBluePlayer) {
            blueCounter ++;
            marker.markerPosition = CGPointMake(blueCounter *interval + self.fieldBounds.origin.x, self.fieldBounds.size.height / 110 * 87 + self.fieldBounds.origin.y);
        } else if (marker.markerType == HPDMarkerTypeRedPlayer) {
            redCounter ++;
            marker.markerPosition = CGPointMake(redCounter * interval + self.fieldBounds.origin.x, self.fieldBounds.size.height/110 * 23 + self.fieldBounds.origin.y);
        } else if (marker.markerType == HPDMarkerTypeDisc) {
            marker.markerPosition = CGPointMake(self.fieldBounds.origin.x + self.fieldBounds.size.width/2, self.fieldBounds.origin.y + self.fieldBounds.size.height/2);
        }
        [marker updateMarkerLayerDisableCATransaction:NO];
        
    }
    
}

- (void)playerPositionVerticalStack
{
 
    if (!self.allMarkers) {
        [self initMarkers];
    }
    
    [self deselectMarkers];
    
    CGFloat centerX = self.fieldBounds.origin.x + self.fieldBounds.size.width/2.0;
    CGFloat topEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*23;
    CGFloat bottomEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*87;
    CGFloat interval = (self.fieldBounds.size.height - 2*topEndzoneLineY)/ (7 + 1);
    //    CGFloat topFirstPlayerY = topEndzoneLineY + interval;
    
    int blueCounter = 0;
    int redCounter = 0;

    HPDMarker *handler1;
    HPDMarker *handler2;
    
    
    for (HPDMarker *marker in self.allMarkers) {
        
        CGFloat markingDistance = marker.markerWidth*1.7;
        CGFloat centerXDefenderPosition = centerX + markingDistance;
        // Vertical and horizontal distances for markers positioned 45 degrees away
        CGFloat distanceY = markingDistance*1/sqrtf(2);

        
        if (marker.markerType == HPDMarkerTypeBluePlayer) {
            blueCounter ++;
            if (blueCounter <= 5) {
                CGFloat newMarkerY = topEndzoneLineY + blueCounter * interval;
                marker.markerPosition = CGPointMake(centerX, newMarkerY);
            } else if (blueCounter == 6) {
                marker.markerPosition = CGPointMake(centerX, bottomEndzoneLineY);
                handler1 = marker;
            } else if (blueCounter == 7) {
                CGPoint handler2Position = CGPointMake(handler1.markerPosition.x + distanceY*2, handler1.markerPosition.y + distanceY*2);
                marker.markerPosition = handler2Position;
                handler2 = marker;
            }
        }
        
        if (marker.markerType == HPDMarkerTypeRedPlayer) {
            redCounter ++;
            if (redCounter <= 5) {
                CGFloat newMarkerY = topEndzoneLineY + redCounter * interval;
                marker.markerPosition = CGPointMake(centerXDefenderPosition, newMarkerY);
            } else if (redCounter == 6) {
                
                CGPoint position = CGPointMake(handler1.markerPosition.x-distanceY, handler1.markerPosition.y - distanceY);
                marker.markerPosition = position;
            } else if (redCounter == 7) {
                CGPoint position = CGPointMake(handler2.markerPosition.x, handler2.markerPosition.y - markingDistance);
                marker.markerPosition = position;
            }
        }
        
        [marker updateMarkerLayerDisableCATransaction:NO];
        
    }

    
}


#pragma mark - Drawing Methods

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    self.touchDownPosition = location;
    

    
    HPDMarker *selectedMarker = [self markerAtPoint:location];
    
    if (selectedMarker) {

        [self animateMarkerSelected:selectedMarker selected:YES offsetMarker:YES];
        if (!self.selectedMarkers) {
            self.selectedMarkers = [[NSMutableArray alloc] init];
        }
        
        [self.selectedMarkers addObject:selectedMarker];
    }

    
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectedMarkers) {
        UITouch *myTouch = [touches anyObject];
        CGPoint location = [myTouch locationInView:self];
        CGSize movedDistance = CGSizeMake(location.x - self.touchDownPosition.x, location.y - self.touchDownPosition.y);
        for (HPDMarker *marker in self.selectedMarkers) {
            CGPoint previousPosition = marker.markerPosition;
            CGPoint newPosition = CGPointMake(previousPosition.x + movedDistance.width, previousPosition.y + movedDistance.height);
            marker.markerPosition = newPosition;
//            [self animateMarker:marker toPosition:newPosition];
            
            [marker updateMarkerLayerDisableCATransaction:YES];
            
        }
        self.touchDownPosition = location;

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (HPDMarker *marker in self.selectedMarkers) {
        marker.markerPosition = marker.markerCALayer.position;
    }
    [self deselectMarkers];
}

#pragma mark Gesture Methods

- (void)pinch:(UIGestureRecognizer *)gr
{
    // Static to prevent rectangle from drawing weirdly when one of the touches is removed after pinching
    static CGPoint pointA;
    static CGPoint pointB;
    
    // Assign touches to points
    if ([gr numberOfTouches] >= 2) {
        pointA = [gr locationOfTouch:0 inView:self];
        pointB = [gr locationOfTouch:1 inView:self];
    }
    
    CGPoint topLeftCorner;
    
    // Maps top left corner of rect appropriately
    if (pointA.x <= pointB.x & pointA.y <= pointB.y) {
        topLeftCorner = pointA;
    } else if (pointA.x <= pointB.x & pointA.y > pointB.y){
        topLeftCorner = CGPointMake(pointA.x, pointB.y);
    } else if (pointA.x > pointB.x & pointA.y <= pointB.y) {
        topLeftCorner = CGPointMake(pointB.x, pointA.y);
    } else if (pointA.x > pointB.x & pointA.y > pointB.y) {
        topLeftCorner = pointB;
    }
    
    
    CGSize rectDimensions = CGSizeMake(labs(pointA.x - pointB.x), labs(pointA.y - pointB.y));
    CGRect rect = CGRectMake(topLeftCorner.x, topLeftCorner.y, rectDimensions.width, rectDimensions.height);
    
    if ([gr numberOfTouches] >= 2 ) {
        self.selectionBox = [NSValue valueWithCGRect:rect];
        if (!self.selectionBoxLayer) {
            self.selectionBoxLayer = [CALayer layer];
            self.selectionBoxLayer.backgroundColor = [UIColor grayColor].CGColor;
            self.selectionBoxLayer.opacity = 0.5;
            [self.layer addSublayer:self.selectionBoxLayer];
        }
        
    }
    
    if (self.selectionBoxLayer) {
        [CATransaction setDisableActions:YES];
        self.selectionBoxLayer.bounds = rect;
        self.selectionBoxLayer.anchorPoint = CGPointMake(0, 0);
        self.selectionBoxLayer.position = CGPointMake(topLeftCorner.x, topLeftCorner.y);
        [CATransaction setDisableActions:NO];
    }
    
    
    if (gr.state == (UIGestureRecognizerStateEnded)) {
        [self selection];
        self.selectionBox = nil;
        [self.selectionBoxLayer removeFromSuperlayer];
        self.selectionBoxLayer = nil;
    }
}

// Method to get markers within a selection box
- (void)selection
{
    if (!self.selectedMarkers) {
        self.selectedMarkers = [[NSMutableArray alloc] init];
    }
    
    CGRect selectionBox = [self.selectionBox CGRectValue];
    
    for (HPDMarker *marker in self.allMarkers) {
        if (CGRectContainsPoint(selectionBox, marker.markerPosition)) {
            [self animateMarkerSelected:marker selected:YES offsetMarker:NO];
            [self.selectedMarkers addObject:marker];
        }
    }
}

- (void)tap
{
    [self deselectMarkers];
}

#pragma mark - Helper Selection Methods

- (HPDMarker *)markerAtPoint:(CGPoint)point
{
    float touchThreshold = 15;
    for (HPDMarker *marker in self.allMarkers) {
        CGPoint markerPosition = marker.markerPosition;
        if (hypot(point.x - markerPosition.x, point.y - markerPosition.y) < touchThreshold) {
            return marker;
        }
    }
    return nil;
}

- (void)deselectMarkers
{
    if (self.selectedMarkers) {
        for (HPDMarker *marker in self.selectedMarkers) {
            [self animateMarkerSelected:marker selected:NO offsetMarker:NO];
        }
    }
    self.selectedMarkers = nil;
    
}


#pragma mark - Animation Methods

// BOOLEAN selected indicates true for touches begin, and false for touches ended
- (void)animateMarkerSelected:(HPDMarker *)marker selected:(BOOL)selected offsetMarker:(BOOL)offsetMarker
{
    CGFloat scaleFactor = 1.4;
    
    if (!selected) {
        scaleFactor = 1.0;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:marker.markerCALayer.transform];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    scaleAnimation.duration = 3;
    marker.markerCALayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);

    [marker.markerCALayer addAnimation:scaleAnimation forKey:nil];
    
    
    CGPoint positionAfterOffset;

    if (offsetMarker) {
        positionAfterOffset = CGPointMake(marker.markerCALayer.position.x, marker.markerPosition.y - self.touchoffset);
        CABasicAnimation *translateAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        translateAnimation.fromValue = [NSValue valueWithCGPoint:marker.markerPosition];
        translateAnimation.toValue = [NSValue valueWithCGPoint:positionAfterOffset];
        translateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        translateAnimation.duration = 3;
        marker.markerCALayer.position = positionAfterOffset;
        marker.markerPosition = positionAfterOffset;
        [marker.markerCALayer addAnimation:translateAnimation forKey:nil];
        
    }
    

}



- (void)animateMarker:(HPDMarker *)marker toPosition:(CGPoint)newPosition
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:marker.markerPosition];
    animation.toValue = [NSValue valueWithCGPoint:newPosition];
    marker.markerCALayer.position = newPosition;
    marker.markerPosition = newPosition;
    
//    CGFloat dx = newPosition.x - marker.markerPosition.x;
//    CGFloat dy = newPosition.y - marker.markerPosition.y;
//    
//    NSLog(@"Translating from:%@ to %@", NSStringFromCGPoint(marker.markerPosition), NSStringFromCGPoint(newPosition));
//    animation.toValue = [NSValue valueWithCGSize:CGSizeMake(dx, dy)];
//    marker.markerCALayer.position = newPosition;
    [marker.markerCALayer addAnimation:animation forKey:nil];
}

@end

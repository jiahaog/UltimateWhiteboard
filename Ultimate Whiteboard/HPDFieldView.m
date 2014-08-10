//
//  HPDFieldView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

//#import <POP/POP.h>

#import "HPDFieldView.h"
#import "HPDMarker.h"
#import "HPDFieldBackground.h"

@interface HPDFieldView ()

//@property (nonatomic, strong) HPDMarker *currentMarker;
@property (nonatomic, strong) NSMutableArray *allMarkers;
@property (nonatomic, strong) NSDictionary *markerWidths;
@property (nonatomic) HPDMarker *selectedMarker;
@property (nonatomic) NSValue *selectionBox;
@property (nonatomic) NSMutableArray *selectedMarkers;

@property (nonatomic) CGPoint touchDownPosition;


@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame fieldBounds:(CGRect)fieldBounds
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.allMarkers = [[NSMutableArray alloc] init];
        self.markerWidths = @{@"player":@10, @"disc":@10};
        self.opaque = NO;
        self.fieldBounds = fieldBounds;
        [self playerPositionEndzoneLines];
//        self.backgroundColor = [UIColor greenColor];
        
        UIInterpolatingMotionEffect *motionEffect;
        float motionEffectRelativeValue = 20;
        motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        motionEffect.minimumRelativeValue = @(-motionEffectRelativeValue);
        motionEffect.maximumRelativeValue = @(motionEffectRelativeValue);
        [self addMotionEffect:motionEffect];
        
        motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        motionEffect.minimumRelativeValue = @(-motionEffectRelativeValue);
        motionEffect.maximumRelativeValue = @(motionEffectRelativeValue);
        [self addMotionEffect:motionEffect];

        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        button1.backgroundColor = [UIColor orangeColor];
        [button1 addTarget:self action:@selector(playerPositionEndzoneLines) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button1];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 50, 50)];
        button2.backgroundColor = [UIColor purpleColor];
        [button2 addTarget:self action:@selector(playerPositionVerticalStack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button2];
        
        // Gesture Recognizers
//        self.multipleTouchEnabled = YES;
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(pinch:)];
        [self addGestureRecognizer:pinchRecognizer];
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapRecognizer];
        
        
        //Fix this pinch interrupt
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    // Drawing code

    
    for (HPDMarker *marker in self.allMarkers) {
        [self strokeMarker:marker selected:NO];
    }
    
    
    if (self.selectionBox) {
        [self strokeRectangleWithCGRect:[self.selectionBox CGRectValue]];
    }
    
    if (self.selectedMarkers) {
        for (HPDMarker *marker in self.selectedMarkers) {
            [self strokeMarker:marker selected:YES];
        }
    }
}


#pragma mark - Drawing Methods

- (void)strokeMarker:(HPDMarker *)marker selected:(BOOL)selected
{
    HPDMarker *currentMarker = marker;
    
    UIColor *markerColor = nil;
    UIColor *markerStroke = [UIColor clearColor];
    NSNumber *markerRadius = nil;
    
    
    switch (marker.markerType) {
        case HPDMarkerTypeBluePlayer:
            markerColor = [UIColor blueColor];

            markerRadius = [self.markerWidths objectForKey:@"player"];
            break;
        case HPDMarkerTypeRedPlayer:
            markerColor = [UIColor redColor];
            markerRadius = [self.markerWidths objectForKey:@"player"];
            break;
        case HPDMarkerTypeDisc:
            markerColor = [UIColor whiteColor];
            markerRadius = [self.markerWidths objectForKey:@"player"];
            markerStroke = [UIColor blackColor];
            
            break;
        default:
            break;
    }
    
    // Change marker width for selected items
    CGFloat multiplier;
    
    if (!selected) {
        multiplier = 1.0;
    } else {
        multiplier = 1.5;
    }
    CGFloat markerRadiusCGFloat = [markerRadius floatValue] * multiplier;

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:currentMarker.markerPosition radius:markerRadiusCGFloat startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
    bezierPath.lineWidth = 2;
    [markerStroke setStroke];
    [markerColor setFill];
    [bezierPath fill];
    [bezierPath stroke];
    
}

- (void)strokeRectangleWithCGRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor grayColor] setFill];
    [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
}
#pragma mark - Player Positions

- (void)playerPositionEndzoneLines
{
    // Create players
    int playersPerSide = 7;
    
    CGFloat interval = self.fieldBounds.size.width/(playersPerSide+1);
    CGPoint fieldOrigin = self.fieldBounds.origin;
    
    static BOOL afterInit = nil;
    
    if (!afterInit) {
        afterInit = TRUE;
        
        HPDMarker *disc = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeDisc];
        disc.markerPosition = CGPointMake(fieldOrigin.x + self.fieldBounds.size.width/2, fieldOrigin.y +self.fieldBounds.size.height/2);
        [self.allMarkers addObject:disc];
        
        for (int i = 1; i <= playersPerSide; i ++) {
            HPDMarker *newBluePlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeBluePlayer];
            [self.allMarkers addObject:newBluePlayer];
            HPDMarker *newRedPlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer];
            [self.allMarkers addObject:newRedPlayer];
            
            newBluePlayer.markerPosition = CGPointMake(i*interval+fieldOrigin.x, self.fieldBounds.size.height/110*87 + fieldOrigin.y);
            newRedPlayer.markerPosition = CGPointMake(i*interval+fieldOrigin.x, self.fieldBounds.size.height/110*23 + fieldOrigin.y);
        }
    } else {
        
        int blueCounter = 0;
        int redCounter = 0;
        for (HPDMarker *marker in self.allMarkers) {
            if (marker.markerType == HPDMarkerTypeBluePlayer) {
                blueCounter ++;
                marker.markerPosition = CGPointMake(blueCounter*interval+fieldOrigin.x, self.fieldBounds.size.height/110*87 + fieldOrigin.y);
            } else if (marker.markerType == HPDMarkerTypeRedPlayer) {
                redCounter ++;
                marker.markerPosition = CGPointMake(redCounter*interval+fieldOrigin.x, self.fieldBounds.size.height/110*23 + fieldOrigin.y);
            }
        }
    }
    
    self.selectedMarkers = nil;
    [self setNeedsDisplay];
    
}

- (void)playerPositionVerticalStack
{
    CGFloat centerX = self.fieldBounds.origin.x + self.fieldBounds.size.width/2.0;
    CGFloat topEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*23;
    CGFloat bottomEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*87;
    CGFloat interval = (self.fieldBounds.size.height - 2*topEndzoneLineY)/ (7 + 1);
//    CGFloat topFirstPlayerY = topEndzoneLineY + interval;
    
    int blueCounter = 0;
    int redCounter = 0;
    CGFloat markingDistance = [[self.markerWidths objectForKey:@"player"] floatValue] * 3;
    CGFloat centerXDefenderPosition = centerX + markingDistance;
    // Vertical and horizontal distances for markers positioned 45 degrees away
    CGFloat distanceY = markingDistance*1/sqrtf(2);
    HPDMarker *handler1;
    HPDMarker *handler2;
    
    
    for (HPDMarker *marker in self.allMarkers) {
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
        
    }
    self.selectedMarkers = nil;
    [self setNeedsDisplay];

}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//    UITouch *myTouch = [touches anyObject];
//    CGPoint location = [myTouch locationInView:self];
//    
//    HPDMarker *newMarker = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer];
//    newMarker.markerPosition = location;
//    [self.allMarkers addObject:newMarker];
//    [self setNeedsDisplay];
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    if (!self.selectedMarkers) {
        HPDMarker *selectedMarker = [self markerAtPoint:location];
        self.selectedMarker = selectedMarker;
    } else {
        self.touchDownPosition = location;
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    
    if (!self.selectedMarkers) {
        self.selectedMarker.markerPosition = location;
    } else {
        CGSize movedDistance = CGSizeMake(location.x - self.touchDownPosition.x, location.y - self.touchDownPosition.y);
        for (HPDMarker *marker in self.selectedMarkers) {
            CGPoint previousPosition = marker.markerPosition;
            marker.markerPosition = CGPointMake(previousPosition.x + movedDistance.width, previousPosition.y + movedDistance.height);
            
        }
        self.touchDownPosition = location;
    }
    [self setNeedsDisplay];
}
- (HPDMarker *)markerAtPoint:(CGPoint)point
{
    float touchThreshold = 20;
    for (HPDMarker *marker in self.allMarkers) {
        CGPoint markerPosition = marker.markerPosition;
        if (hypot(point.x-markerPosition.x, point.y-markerPosition.y) < touchThreshold) {
            return marker;
        }
    }
    return nil;
}

- (void)pinch:(UIGestureRecognizer *)gr
{
    CGPoint pointA;
    CGPoint pointB;
    
    if ([gr numberOfTouches] >= 2) {
        pointA = [gr locationOfTouch:0 inView:self];
        pointB = [gr locationOfTouch:1 inView:self];

    }
    
    CGPoint topLeftCorner;
    CGPoint bottomRightCorner;
    
    if (hypot(pointA.x, pointA.y) > hypot(pointB.x, pointB.y)) {
        topLeftCorner = pointB;
        bottomRightCorner = pointA;
    } else {
        topLeftCorner = pointA;
        bottomRightCorner = pointB;
    }
    
    CGRect rect = CGRectMake(topLeftCorner.x, topLeftCorner.y, bottomRightCorner.x-topLeftCorner.x, bottomRightCorner.y-topLeftCorner.y);
    
    if ([gr numberOfTouches] >= 2) {
        self.selectionBox = [NSValue valueWithCGRect:rect];
    }


    if (gr.state == (UIGestureRecognizerStateEnded)) {
        [self selection];
        self.selectionBox = nil;

    }
    [self setNeedsDisplay];
}

- (void)selection
{
    if (!self.selectedMarkers) {
        self.selectedMarkers = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *selectedMarkers = self.selectedMarkers;

    CGRect selectionBox = [self.selectionBox CGRectValue];
    for (HPDMarker *marker in self.allMarkers) {
        if (CGRectContainsPoint(selectionBox, marker.markerPosition)) {
            [selectedMarkers addObject:marker];
        }
    }
}

// Clear selection
- (void)tap
{
    NSLog(@"tap");
    self.selectedMarkers = nil;
    [self setNeedsDisplay];
}

@end

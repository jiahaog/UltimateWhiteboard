//
//  HPDFieldView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDFieldView.h"
#import "HPDMarker.h"
#import "HPDFieldBackground.h"

@interface HPDFieldView ()

//@property (nonatomic, strong) HPDMarker *currentMarker;
@property (nonatomic, strong) NSMutableArray *allMarkers;
@property (nonatomic, strong) NSDictionary *markerWidths;
@property (nonatomic) HPDMarker *selectedMarker;


@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame fieldBounds:(CGRect)fieldBounds
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.allMarkers = [[NSMutableArray alloc] init];
        self.markerWidths = @{@"player":@20, @"disc":@10};
        self.opaque = NO;
        self.fieldBounds = fieldBounds;
        [self playerPositionEndzoneLines];
//        self.backgroundColor = [UIColor greenColor];
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    [self strokeFieldBackground];
    // Get x positions for 7 players
    
    for (HPDMarker *marker in self.allMarkers) {
        [self strokeMarker:marker];
    }
    
    
}


#pragma mark - Drawing Methods

- (void)strokeMarker:(HPDMarker *)marker
{
    HPDMarker *currentMarker = marker;
    
    UIColor *markerColor = nil;
//    int markerRadius = ;
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
            break;
        default:
            break;
    }
    CGFloat markerRadiusCGFloat = [markerRadius floatValue];
    

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:currentMarker.markerPosition radius:markerRadiusCGFloat startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
    [[UIColor clearColor] setStroke];
    [markerColor setFill];
    [bezierPath fill];
    
}
//
//- (void)strokeFieldBackground
//{
//    // Line width of lines on the field
//    CGFloat lineWidth = 5;
//    [[UIColor whiteColor] set];
//    
//    // Padding between bounds of field and screen edge
//    CGFloat padding = 20;
//    
//    // Draw the bounds of the field
//    CGRect fieldBounds = CGRectMake(lineWidth/2.0 + padding, lineWidth/2.0 + padding, self.bounds.size.width - lineWidth - padding*2.0, self.bounds.size.height - lineWidth - padding *2.0);
//    self.fieldBounds = fieldBounds;
//    UIBezierPath *fieldOutline = [UIBezierPath bezierPathWithRect:fieldBounds];
//    fieldOutline.lineWidth = lineWidth;
//    [fieldOutline stroke];
//    
//    // End Zone Lines
//    CGFloat topLinePositionY = fieldBounds.size.height/110.0*23;
//    CGPoint topLineStart = CGPointMake(fieldBounds.origin.x, topLinePositionY);
//    CGPoint topLineEnd = CGPointMake(fieldBounds.size.width + fieldBounds.origin.x, topLinePositionY);
//    
//    CGFloat bottomLinePositionY = fieldBounds.size.height/110.0*87;
//    CGPoint bottomLineStart = CGPointMake(fieldBounds.origin.x, bottomLinePositionY);
//    CGPoint bottomLineEnd = CGPointMake(fieldBounds.size.width + fieldBounds.origin.x, bottomLinePositionY);
//    
//    UIBezierPath *topLine = [UIBezierPath bezierPath];
//    topLine.lineWidth = lineWidth;
//    CGFloat bezierPattern[] = {2,2};
//    [topLine setLineDash:bezierPattern count:2 phase:0];
//    [topLine moveToPoint:topLineStart];
//    [topLine addLineToPoint:topLineEnd];
//    [topLine stroke];
//    
//    UIBezierPath *bottomLine = [UIBezierPath bezierPath];
//    bottomLine.lineWidth = lineWidth;
//    [bottomLine setLineDash:bezierPattern count:2 phase:0];
//    [bottomLine moveToPoint:bottomLineStart];
//    [bottomLine addLineToPoint:bottomLineEnd];
//    [bottomLine stroke];
//    
//    
//    // Draw Brick positions
//    CGFloat brickPositionX = fieldBounds.size.width/2.0 + fieldBounds.origin.x;
//    CGPoint brickPositionTop = CGPointMake(brickPositionX, fieldBounds.size.height/110.0*(23+18));
//    CGPoint brickPositionBottom = CGPointMake(brickPositionX, fieldBounds.size.height/110.0*(23+64-18));
//    
//    NSArray *brickPosition = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:brickPositionTop], [NSValue valueWithCGPoint:brickPositionBottom], nil];
//    CGFloat brickRadius = lineWidth;
//    
//    for (NSValue *pointNSValue in brickPosition) {
//        CGPoint point = [pointNSValue CGPointValue];
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:brickRadius startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
//        [path fill];
//    }
//    
//}

#pragma mark - Player Positions

- (void)playerPositionEndzoneLines
{
    // Create players
    int playersPerSide = 7;
    
    CGFloat interval = self.fieldBounds.size.width/(playersPerSide+1);
    CGPoint fieldOrigin = self.fieldBounds.origin;
    
    for (int i = 1; i <= playersPerSide; i ++) {
        HPDMarker *newBluePlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeBluePlayer];
        newBluePlayer.markerPosition = CGPointMake(i*interval+fieldOrigin.x, self.fieldBounds.size.height/110*23 + fieldOrigin.y);
        [self.allMarkers addObject:newBluePlayer];
        
        HPDMarker *newRedPlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer];
        newRedPlayer.markerPosition = CGPointMake(i*interval+fieldOrigin.x, self.fieldBounds.size.height/110*87 + fieldOrigin.y);
        [self.allMarkers addObject:newRedPlayer];
    }
    
    NSLog(@"%@", self.allMarkers);
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
    HPDMarker *selectedMarker = [self markerAtPoint:location];
    self.selectedMarker = selectedMarker;
//    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    self.selectedMarker.markerPosition = location;
    [self setNeedsDisplay];
}
- (HPDMarker *)markerAtPoint:(CGPoint)point
{
    float touchThreshold = 30;
    for (HPDMarker *marker in self.allMarkers) {
        CGPoint markerPosition = marker.markerPosition;
        if (hypot(point.x-markerPosition.x, point.y-markerPosition.y) < touchThreshold) {
            return marker;
        }
    }
    return nil;
}

@end

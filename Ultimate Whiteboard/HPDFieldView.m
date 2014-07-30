//
//  HPDFieldView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDFieldView.h"
#import "HPDMarker.h"

@interface HPDFieldView ()

//@property (nonatomic, strong) HPDMarker *currentMarker;
@property (nonatomic, strong) NSMutableArray *finishedMarkers;
@property (nonatomic, strong) NSDictionary *markerWidths;
@property (nonatomic) CGRect fieldBounds;

@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.finishedMarkers = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor greenColor];
        self.markerWidths = @{@"player":@10, @"disc":@10};
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self strokeFieldBackground];
    for (HPDMarker *marker in self.finishedMarkers) {
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
    
    [markerColor setFill];
    [bezierPath fill];
    
}

- (void)strokeFieldBackground
{
    // Line width of lines on the field
    CGFloat lineWidth = 5;
    [[UIColor whiteColor] set];
    
    // Padding between bounds of field and screen edge
    CGFloat padding = 20;
    
    // Draw the bounds of the field
    CGRect fieldBounds = CGRectMake(lineWidth/2.0 + padding, lineWidth/2.0 + padding, self.bounds.size.width - lineWidth - padding*2.0, self.bounds.size.height - lineWidth - padding *2.0);
    self.fieldBounds = fieldBounds;
    UIBezierPath *fieldOutline = [UIBezierPath bezierPathWithRect:fieldBounds];
    fieldOutline.lineWidth = lineWidth;
    [fieldOutline stroke];
    
    // End Zone Lines
    CGFloat topLinePositionY = fieldBounds.size.height/110.0*23;
    CGPoint topLineStart = CGPointMake(fieldBounds.origin.x, topLinePositionY);
    CGPoint topLineEnd = CGPointMake(fieldBounds.size.width + fieldBounds.origin.x, topLinePositionY);
    
    CGFloat bottomLinePositionY = fieldBounds.size.height/110.0*87;
    CGPoint bottomLineStart = CGPointMake(fieldBounds.origin.x, bottomLinePositionY);
    CGPoint bottomLineEnd = CGPointMake(fieldBounds.size.width + fieldBounds.origin.x, bottomLinePositionY);
    
    UIBezierPath *topLine = [UIBezierPath bezierPath];
    topLine.lineWidth = lineWidth;
    CGFloat bezierPattern[] = {2,2};
    [topLine setLineDash:bezierPattern count:2 phase:0];
    [topLine moveToPoint:topLineStart];
    [topLine addLineToPoint:topLineEnd];
    [topLine stroke];
    
    UIBezierPath *bottomLine = [UIBezierPath bezierPath];
    bottomLine.lineWidth = lineWidth;
    [bottomLine setLineDash:bezierPattern count:2 phase:0];
    [bottomLine moveToPoint:bottomLineStart];
    [bottomLine addLineToPoint:bottomLineEnd];
    [bottomLine stroke];
    
    
    // Draw Brick positions
    CGFloat brickPositionX = fieldBounds.size.width/2.0 + fieldBounds.origin.x;
    CGPoint brickPositionTop = CGPointMake(brickPositionX, fieldBounds.size.height/110.0*(23+18));
    CGPoint brickPositionBottom = CGPointMake(brickPositionX, fieldBounds.size.height/110.0*(23+64-18));
    
    NSArray *brickPosition = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:brickPositionTop], [NSValue valueWithCGPoint:brickPositionBottom], nil];
    CGFloat brickRadius = lineWidth;
    
    for (NSValue *pointNSValue in brickPosition) {
        CGPoint point = [pointNSValue CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:brickRadius startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
        [path fill];
    }
    
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    
    HPDMarker *newMarker = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer];
    newMarker.markerPosition = location;
    [self.finishedMarkers addObject:newMarker];
    [self setNeedsDisplay];
}

@end

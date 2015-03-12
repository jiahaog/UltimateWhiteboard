//
//  HPDFieldBackground.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDFieldBackground.h"

@implementation HPDFieldBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:46.0/255 green:204.0/255 blue:113.0/255 alpha:1]; //flatuicolors emerald
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    // Line width of lines on the field
    CGFloat lineWidth = 5;
    [[UIColor whiteColor] set];
    
    // Padding between bounds of field and screen edge
    CGFloat padding = 5;
    
    // Draw the bounds of the field
    CGRect fieldBounds = CGRectMake(lineWidth/2.0 + padding, lineWidth/2.0 + padding, self.bounds.size.width - lineWidth - padding*2.0, self.bounds.size.height - lineWidth - padding *2.0);
    UIBezierPath *fieldOutline = [UIBezierPath bezierPathWithRect:fieldBounds];
    fieldOutline.lineWidth = lineWidth;
    [fieldOutline stroke];
    
    // End Zone Lines
    CGFloat topLinePositionY = fieldBounds.origin.y + fieldBounds.size.height/110.0*23;
    CGPoint topLineStart = CGPointMake(fieldBounds.origin.x, topLinePositionY);
    CGPoint topLineEnd = CGPointMake(fieldBounds.size.width + fieldBounds.origin.x, topLinePositionY);
    
    CGFloat bottomLinePositionY = fieldBounds.origin.y + fieldBounds.size.height/110.0*87;
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
    CGPoint brickPositionTop = CGPointMake(brickPositionX, fieldBounds.origin.y + fieldBounds.size.height/110.0*(23+18));
    CGPoint brickPositionBottom = CGPointMake(brickPositionX, fieldBounds.origin.y + fieldBounds.size.height/110.0*(23+64-18));
    
    NSArray *brickPosition = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:brickPositionTop], [NSValue valueWithCGPoint:brickPositionBottom], nil];
    CGFloat brickRadius = lineWidth/2.0;
    
    for (NSValue *pointNSValue in brickPosition) {
        CGPoint point = [pointNSValue CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:brickRadius startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
        [path fill];
    }
    
    self.fieldBounds = fieldBounds;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Fieldbackground received touches");
}

@end

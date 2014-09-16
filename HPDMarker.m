//
//  HPDMarker.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDMarker.h"

@interface HPDMarker ()

@property (nonatomic) NSMutableArray *privateKeyframeArray;

@end

@implementation HPDMarker

- (instancetype)initWithMarkerType:(char)markerType viewToDrawOn:(UIView *)view markerNumber:(int)markerNumber
{
    self = [super init];
    
    _markerType = markerType;
    _markerWidth = 24;
    _viewToDrawOn = view;
    _markerNumber = markerNumber;
    
    [self updateMarkerLayerDisableCATransaction:YES];

    
    
    return self;
}

- (void)updateMarkerLayerDisableCATransaction:(BOOL)disableCATransaction
{
    
//    if (!self.markerCALayer) {
//        self.markerCALayer = [CAShapeLayer layer];
//        self.markerCALayer.fillColor = [UIColor blueColor].CGColor;
//        self.markerCALayer.backgroundColor = [UIColor redColor].CGColor;
//    }
//    UIBezierPath *markerPath = [UIBezierPath bezierPathWithArcCenter:self.markerPosition radius:self.markerWidth startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
//    self.markerCALayer.path = markerPath.CGPath;
    

    
    
    if (disableCATransaction) {
        [CATransaction setDisableActions:YES];
    }

    if (!self.markerCALayer) {
        self.markerCALayer = [CALayer layer];
        self.markerCALayer.zPosition = 0;
        
        UIColor *markerColor = nil;
        CGFloat markerWidth = self.markerWidth;
        UIColor *markerStroke = [UIColor clearColor];
        
        
        switch (self.markerType) {
            case HPDMarkerTypeBluePlayer:
//                markerColor = [UIColor blueColor];
                markerColor = [UIColor colorWithRed:52.0/255 green:152.0/255 blue:219.0/255 alpha:1.0]; //flatuicolors peter river
                break;
            case HPDMarkerTypeRedPlayer:
//                markerColor = [UIColor redColor];
                markerColor = [UIColor colorWithRed:211.0/255 green:84.0/255 blue:0 alpha:1.0]; //flatuicolors pumpkin
                break;
            case HPDMarkerTypeDisc:
                markerColor = [UIColor colorWithRed:236.0/255 green:240.0/255 blue:241.0/255 alpha:1.0]; //flatuicolors clouds
                markerStroke = [UIColor colorWithRed:127.0/255 green:140.0/255 blue:141.0/255 alpha:1.0]; //flatuicolors asbestos
                self.markerCALayer.borderWidth = 1.5;
                self.markerCALayer.borderColor = markerStroke.CGColor;
                markerWidth = self.markerWidth*0.8;
                break;
            default:
                break;
        }

        
        // Create label only for non disc marker types
        if (self.markerType != HPDMarkerTypeDisc) {
            // Create label
            CATextLayer *label = [[CATextLayer alloc] init];
            [label setFont:@"AvenirNext-UltraLight"];
            [label setFontSize:18];
            [label setFrame:CGRectMake(0, 0, markerWidth, markerWidth)];
            [label setString:[NSString stringWithFormat:@"%d", self.markerNumber]];
            [label setAlignmentMode:kCAAlignmentCenter];
            [label setForegroundColor:[UIColor whiteColor].CGColor];
            
            // Important line to stop textlayer from being blurred
            [label setContentsScale:[[UIScreen mainScreen] scale]];
            
            
            [self.markerCALayer addSublayer:label];
            
        }
        
        
        self.markerCALayer.backgroundColor = markerColor.CGColor;
        self.markerCALayer.cornerRadius = markerWidth/2.0;
        self.markerCALayer.bounds = CGRectMake(0, 0, markerWidth, markerWidth);
        // Anti aliasing
        self.markerCALayer.rasterizationScale = [UIScreen mainScreen].scale;
        self.markerCALayer.shouldRasterize = YES;

    }



    self.markerCALayer.position = self.markerPosition;
    


    
    if (disableCATransaction) {
        [CATransaction setDisableActions:NO];
    }
    
    // If it does not have a superlayer to draw on, add it to the viewToDrawOn
    if (![self.markerCALayer superlayer]) {
        [self.viewToDrawOn.layer addSublayer:self.markerCALayer];
    }
    
}

#pragma mark - NSCoding Methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.markerPosition forKey:@"markerPosition"];
    [aCoder encodeInt:self.markerType forKey:@"markerType"];
    [aCoder encodeInt:self.markerNumber forKey:@"markerNumber"];
    [aCoder encodeObject:self.markerCALayer forKey:@"markerCALayer"];
    [aCoder encodeFloat:self.markerWidth forKey:@"markerWidth"];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _markerPosition = [aDecoder decodeCGPointForKey:@"markerPosition"];
        _markerType = [aDecoder decodeIntForKey:@"markerType"];
        _markerNumber = [aDecoder decodeIntForKey:@"markerNumber"];
        _markerCALayer = [aDecoder decodeObjectForKey:@"markerCALayer"];
        _markerWidth = [aDecoder decodeFloatForKey:@"markerWidth"];
        _viewToDrawOn = [aDecoder decodeObjectForKey:@"viewToDrawOn"];

        
    }
    return self;
}

- (NSArray *)keyframeArray
{
    return self.privateKeyframeArray;
}

- (void)addKeyframe
{
    if (!self.privateKeyframeArray) {
        self.privateKeyframeArray = [[NSMutableArray alloc] init];
    }
    
    NSValue *markerPositionValue = [NSValue valueWithCGPoint:self.markerPosition];
    
    [self.privateKeyframeArray addObject:markerPositionValue];
    
}

- (void)removeKeyframes
{
    self.privateKeyframeArray = nil;
}

@end

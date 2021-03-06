//
//  HPDMarker.h
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <Foundation/Foundation.h>


// ENUM to classify type of marker
typedef NS_ENUM(char, markerType) {
    HPDMarkerTypeBluePlayer,
    HPDMarkerTypeRedPlayer,
    HPDMarkerTypeDisc,
};

@interface HPDMarker : NSObject <NSCoding>

@property (nonatomic) CGPoint markerPosition;
@property (nonatomic) int markerType;
@property (nonatomic) int markerNumber;

// Drawing Properties
@property (nonatomic) CALayer *markerCALayer;
@property (nonatomic) CGFloat markerWidth;
@property (nonatomic) UIView *viewToDrawOn;

// Previous locations
@property (nonatomic) NSArray *keyframeArray;

// Designated Initiator
- (instancetype)initWithMarkerType:(char)markerType viewToDrawOn:(UIView *)view markerNumber:(int)markerNumber;

- (void)updateMarkerLayerDisableCATransaction:(BOOL)disableCATransaction;

- (void)addKeyframe;
- (void)removeKeyframes;

@end

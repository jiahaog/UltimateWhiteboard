//
//  HPDMarker.h
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, markerType) {
    HPDMarkerTypeBluePlayer,
    HPDMarkerTypeRedPlayer,
    HPDMarkerTypeDisc,
};

@interface HPDMarker : NSObject

@property (nonatomic) CGPoint markerPosition;
@property (nonatomic) int markerType;


- (instancetype)initWithMarkerType:(char)markerType;

@end

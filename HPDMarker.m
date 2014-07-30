//
//  HPDMarker.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 30/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDMarker.h"

@implementation HPDMarker

- (instancetype)initWithMarkerType:(char)markerType
{
    self = [super init];
    _markerType = markerType;
    return self;
}


@end

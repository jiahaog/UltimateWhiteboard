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
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    _markerKey = key;
    return self;
}


@end

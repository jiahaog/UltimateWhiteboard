//
//  HPDMarkerStore.h
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 14/9/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HPDMarker;

@interface HPDMarkerStore : NSObject

@property (nonatomic, readonly) NSArray *allMarkers;


+ (instancetype)sharedStore;
- (BOOL)saveChanges;
- (void)addMarker:(HPDMarker *)marker;

@end

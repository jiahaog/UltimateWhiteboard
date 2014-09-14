//
//  HPDMarkerStore.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 14/9/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import "HPDMarkerStore.h"
#import "HPDMarker.h"

@interface HPDMarkerStore ()

@property (nonatomic) NSMutableArray *privateMarkers;

@end

@implementation HPDMarkerStore



+(instancetype)sharedStore
{
    static HPDMarkerStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        NSString *path = [self markerArchivePath];
        _privateMarkers = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        

        
    }
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Sington"
                                   reason:@"Use + [BNRItemStore sharedStore]" userInfo:nil];
    
    return nil;
}

#pragma mark - Modification of Storage NSArray

- (NSArray *)allMarkers
{
    return self.privateMarkers;
}

- (void)addMarker:(HPDMarker *)marker
{
    if (!_privateMarkers) {
        _privateMarkers = [[NSMutableArray alloc] init];
    }
    [self.privateMarkers addObject:marker];
}

#pragma mark - Storage Methods

- (NSString *)markerArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"markers.archive"];
    
}

- (BOOL)saveChanges
{
    NSString *path = [self markerArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.allMarkers toFile:path];
}



@end

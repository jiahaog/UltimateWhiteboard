//
//  HPDFieldView.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

#import <POP/POP.h>

#import "HPDFieldView.h"
#import "HPDMarker.h"
#import "HPDFieldBackground.h"
#import "HPDMarkerStore.h"
#import "HPDPlaybackScrubberView.h"
#import "UIColor+FlatUIColors.h"

@interface HPDFieldView ()

// Model storage for all markers
@property (nonatomic) NSArray *allMarkers;

// Temporary pointers for markers
@property (nonatomic) NSMutableArray *selectedMarkers;
@property (nonatomic) HPDMarker *discMarker;

// Properties for field dimensions
@property (nonatomic) CGRect fieldBounds;

// properties to aid in touch tracking
@property (nonatomic) CGPoint touchDownPosition;
@property (nonatomic) NSValue *selectionBox;
@property (nonatomic) CALayer *selectionBoxLayer;
@property (nonatomic) CGFloat largestZposition;

// Property to hold views
@property (nonatomic) UIView *controlBar;
@property (nonatomic) HPDPlaybackScrubberView *playbackScrubberView;
@property (nonatomic) UIView *notificationForUser;

// Property to hold buttons
@property (nonatomic) UIButton *tutorialButton;
@property (nonatomic) UIButton *menuButton;
@property (nonatomic) UIButton *toggleFormationButton;
@property (nonatomic) UIButton *addKeyframeButton;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *deleteKeyframesButton;

// Property to track keyframes
@property (nonatomic) int currentKeyframe;

// Property to track if animation mode has started
@property (nonatomic) BOOL animationMode;

// Options
@property (nonatomic) int playersPerSide;
@property (nonatomic) CGFloat touchoffset; // Offset for touches so that touched markers are not beneath the finger
@property (nonatomic) CGFloat keyframeDuration;

// Color constant
@property (nonatomic) UIColor *menuBarColor;
@property (nonatomic) UIColor *buttonTintColor;

// Menu Constant
@property (nonatomic) CGFloat menuIconsize;

// Tutorial counter
@property (nonatomic) int tutorialState;
@property (nonatomic) int tutorialMovesCounter;

// Tracks if control bar is displayed
@property (nonatomic) BOOL controlBarIsDisplayed;


@end

@implementation HPDFieldView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame fieldBounds:(CGRect)fieldBounds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Default options here
        _playersPerSide = 7;
        _touchoffset = 30;
        _keyframeDuration = 1; // sets time interval per keyframe animation
        
        // color constants
        self.menuBarColor = [UIColor clearColor];
        self.buttonTintColor = [UIColor colorWithRed:236.0/255 green:240.0/255 blue:241.0/255 alpha:1.0];
        
        _menuIconsize = 40;
        // Need this to show field background
        self.opaque = NO;
        
        // assigns field dimensions to properties
        _fieldBounds = fieldBounds;
        
        
        // initialize variables
        self.largestZposition = 0;
        self.tutorialState = 999;
        
        [self initMarkers];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(pinch:)];
        [self addGestureRecognizer:pinchRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapRecognizer];

        
//        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentControlBar)];
//        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
//        twoFingerTapRecognizer.cancelsTouchesInView = YES;
//        [self addGestureRecognizer:twoFingerTapRecognizer];

        
        // Menu bar button
//        UIImageView *buttonToShowControlBar = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, self.bounds.size.height-50, 50, 50)];
        
        
        [self initializeControlBar];
        
        self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - self.menuIconsize, self.bounds.size.height-self.menuIconsize, self.menuIconsize, self.menuIconsize)];
        UIImage *menuImage = [[UIImage imageNamed:@"menuIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.menuButton setTintColor:self.buttonTintColor];
        [self.menuButton setImage:menuImage forState:UIControlStateNormal];
        self.menuButton.alpha = 0.8;
        self.menuButton.backgroundColor = [UIColor wetAsphaltColor];
        [self.menuButton addTarget:self action:@selector(presentControlBar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.menuButton];

        self.tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - self.menuIconsize, 0, self.menuIconsize, self.menuIconsize)];
        UIImage *tutorialImage = [[UIImage imageNamed:@"tutorialIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.tutorialButton setTintColor:self.buttonTintColor];
        self.tutorialButton.alpha = 0.8;
        [self.tutorialButton setImage:tutorialImage forState:UIControlStateNormal];

        [self.tutorialButton setBackgroundColor:[UIColor wetAsphaltColor]];
        [self.tutorialButton addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.tutorialButton];
        
        
        
        
    }
    return self;
}

#pragma mark - Player Positions

- (void)initMarkers
{
    
    self.allMarkers = [[HPDMarkerStore sharedStore] allMarkers];
   
    // If no data is stored
    if (!self.allMarkers) {
        
        for (int i = 1; i <= self.playersPerSide; i++) {
            HPDMarker *newBluePlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeBluePlayer viewToDrawOn:self markerNumber:i];
            [[HPDMarkerStore sharedStore] addMarker:newBluePlayer];
            HPDMarker *newRedPlayer = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeRedPlayer viewToDrawOn:self markerNumber:i];
            [[HPDMarkerStore sharedStore] addMarker:newRedPlayer];
        }
        
        HPDMarker *disc = [[HPDMarker alloc] initWithMarkerType:HPDMarkerTypeDisc viewToDrawOn:self markerNumber:0];
        [[HPDMarkerStore sharedStore] addMarker:disc];
        self.discMarker = disc;
        
        
        self.allMarkers = [[HPDMarkerStore sharedStore] allMarkers];
        
        [self playerPositionEndzoneLines];
        
    } else {
        
        // If Data is stored
        for (HPDMarker *marker in self.allMarkers) {
            
            // Need to update the viewToDrawOn, as a new UIView is created each time
            marker.viewToDrawOn = self;
            [marker updateMarkerLayerDisableCATransaction:YES];
            
            // Assigns disc to pointer
            if (marker.markerType == HPDMarkerTypeDisc) {
                self.discMarker = marker;
            }
            
        }
    }
    
}

- (void)playerPositionEndzoneLines
{
    
    [self deselectMarkers];
    
    CGFloat interval = self.fieldBounds.size.width/(self.playersPerSide + 1);
    
    int blueCounter = 0;
    int redCounter = 0;
    for (HPDMarker *marker in self.allMarkers) {
        if (marker.markerType == HPDMarkerTypeBluePlayer) {
            blueCounter ++;
            marker.markerPosition = CGPointMake(blueCounter *interval + self.fieldBounds.origin.x, self.fieldBounds.size.height / 110 * 87 + self.fieldBounds.origin.y);
        } else if (marker.markerType == HPDMarkerTypeRedPlayer) {
            redCounter ++;
            marker.markerPosition = CGPointMake(redCounter * interval + self.fieldBounds.origin.x, self.fieldBounds.size.height/110 * 23 + self.fieldBounds.origin.y);
        } else if (marker.markerType == HPDMarkerTypeDisc) {
            marker.markerPosition = CGPointMake(self.fieldBounds.origin.x + self.fieldBounds.size.width/2, self.fieldBounds.origin.y + self.fieldBounds.size.height/2);
        }
        [marker updateMarkerLayerDisableCATransaction:NO];
        
    }
    
    // Add notification on screen to inform user of action
    [self presentNotification:@"Pull"];

    
}

- (void)playerPositionVerticalStack
{

    [self deselectMarkers];
    
    CGFloat centerX = self.fieldBounds.origin.x + self.fieldBounds.size.width/2.0;
    CGFloat topEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*23;
    CGFloat bottomEndzoneLineY = self.fieldBounds.origin.y + self.fieldBounds.size.height/110*87;
    CGFloat interval = (self.fieldBounds.size.height - 2*topEndzoneLineY)/ (7 + 1);
    //    CGFloat topFirstPlayerY = topEndzoneLineY + interval;
    
    // Counters are used to position the players in the vert stack
    int blueCounter = 3;
    int redCounter = 3;

    HPDMarker *handler1;
    HPDMarker *handler2;
    
    
    for (HPDMarker *marker in self.allMarkers) {
        
        CGFloat markingDistance = marker.markerWidth*1.5;
        CGFloat centerXDefenderPosition = centerX + markingDistance;
        
        // Vertical and horizontal distances for markers positioned 45 degrees away
        CGFloat distanceY = markingDistance*1/sqrtf(2);

        
        if (marker.markerType == HPDMarkerTypeBluePlayer) {
            if (marker.markerNumber >= 3) {
                CGFloat newMarkerY = bottomEndzoneLineY - blueCounter * interval;
                marker.markerPosition = CGPointMake(centerX, newMarkerY);
                blueCounter ++;
            } else if (marker.markerNumber == 1) {
                marker.markerPosition = CGPointMake(centerX, bottomEndzoneLineY);
                handler1 = marker;
            } else if (marker.markerNumber == 2) {
                CGPoint handler2Position = CGPointMake(handler1.markerPosition.x + distanceY*2, handler1.markerPosition.y + distanceY*2);
                marker.markerPosition = handler2Position;
                handler2 = marker;
            }
        } else if (marker.markerType == HPDMarkerTypeRedPlayer) {

            if (marker.markerNumber >= 3) {
                CGFloat newMarkerY = bottomEndzoneLineY - redCounter * interval;
                marker.markerPosition = CGPointMake(centerXDefenderPosition, newMarkerY);
                redCounter ++;
            } else if (marker.markerNumber == 1) {
                
                CGPoint position = CGPointMake(handler1.markerPosition.x-distanceY, handler1.markerPosition.y - distanceY);
                marker.markerPosition = position;
            } else if (marker.markerNumber == 2) {
                CGPoint position = CGPointMake(handler2.markerPosition.x, handler2.markerPosition.y - markingDistance);
                marker.markerPosition = position;
            }
        } else if (marker.markerType == HPDMarkerTypeDisc) {
            marker.markerPosition = CGPointMake(handler1.markerPosition.x, handler1.markerPosition.y - distanceY);
        }
    
        [marker updateMarkerLayerDisableCATransaction:NO];
        
    }

    // Add notification on screen to inform user of action
    [self presentNotification:@"Vertical Stack"];
}

- (void)togglePlayerPositions
{
    static int previousPosition;
    
    if (!previousPosition) {
        previousPosition = 1;
    }
    
    if (previousPosition == 1) {
        [self playerPositionVerticalStack];
        previousPosition = 2;
    } else if (previousPosition == 2) {
        [self playerPositionEndzoneLines];
        previousPosition = 1;
    }
    
    if (self.tutorialState == 3) {
        [self nextTutorialState];
    }
    
    [self enableAddKeyframeButton];
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:self];
    self.touchDownPosition = location;
    

    if (!self.selectedMarkers) {
        HPDMarker *selectedMarker = [self markerAtPoint:location];
        
        if (selectedMarker) {
            
            //Change zposition to make selected marker on top of everything
            self.largestZposition += 1;
            selectedMarker.markerCALayer.zPosition = self.largestZposition;
            
            [self animateMarkerSelected:selectedMarker selected:YES offsetMarker:YES];
            if (!self.selectedMarkers) {
                self.selectedMarkers = [[NSMutableArray alloc] init];
            }
            
            // enables the add keyframe button only if touches have begun
            
            [self enableAddKeyframeButton];
            // tutorial
//            NSLog(@"tutorialstate: %d", self.tutorialState);
            if (self.tutorialState == 0) {
                self.tutorialMovesCounter += 1;
                
                if (self.tutorialMovesCounter == 3) {
                    [self nextTutorialState];
                }
            } else if (self.tutorialState == 4) {
                
                if (self.tutorialMovesCounter %2 != 0) {
                    [self presentNotification:@"Add another keyframe" duration:0];
                    self.tutorialMovesCounter += 1;
                }
                
                
            }
            
            [self.selectedMarkers addObject:selectedMarker];
        }
        

    }
    
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectedMarkers) {
        UITouch *myTouch = [touches anyObject];
        CGPoint location = [myTouch locationInView:self];
        CGSize movedDistance = CGSizeMake(location.x - self.touchDownPosition.x, location.y - self.touchDownPosition.y);
        
        self.largestZposition += 1;
        
        for (HPDMarker *marker in self.selectedMarkers) {
            CGPoint previousPosition = marker.markerPosition;
            CGPoint newPosition = CGPointMake(previousPosition.x + movedDistance.width, previousPosition.y + movedDistance.height);
            marker.markerPosition = newPosition;
            marker.markerCALayer.zPosition = self.largestZposition;
            [marker updateMarkerLayerDisableCATransaction:YES];
            
        }
        self.touchDownPosition = location;

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//        NSLog(@"Touches ended");
    for (HPDMarker *marker in self.selectedMarkers) {
        marker.markerPosition = marker.markerCALayer.position;
    }

    [self deselectMarkers];
    
    if (self.tutorialState == 1) {
        if (self.tutorialMovesCounter > 0) {
            [self nextTutorialState];
        }
    }

    
    // Make disc on top of everything
    self.discMarker.markerCALayer.zPosition = self.largestZposition;
    [self.discMarker updateMarkerLayerDisableCATransaction:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"Touches cancelled");
    [self deselectMarkers];
}

#pragma mark Gesture Methods

- (void)pinch:(UIGestureRecognizer *)gr
{
    
    // Prevents two pinches at once
    if (self.selectedMarkers) {
        return;
    }
    
    
    // Static to prevent rectangle from drawing weirdly when one of the touches is removed after pinching
    static CGPoint pointA;
    static CGPoint pointB;
    
    // Assign touches to points
    if ([gr numberOfTouches] >= 2) {
        pointA = [gr locationOfTouch:0 inView:self];
        pointB = [gr locationOfTouch:1 inView:self];
    }
    
    CGPoint topLeftCorner;
    
    // Maps top left corner of rect appropriately
    if (pointA.x <= pointB.x & pointA.y <= pointB.y) {
        topLeftCorner = pointA;
    } else if (pointA.x <= pointB.x & pointA.y > pointB.y){
        topLeftCorner = CGPointMake(pointA.x, pointB.y);
    } else if (pointA.x > pointB.x & pointA.y <= pointB.y) {
        topLeftCorner = CGPointMake(pointB.x, pointA.y);
    } else if (pointA.x > pointB.x & pointA.y > pointB.y) {
        topLeftCorner = pointB;
    }
    
    
    CGSize rectDimensions = CGSizeMake(labs(pointA.x - pointB.x), labs(pointA.y - pointB.y));
    CGRect rect = CGRectMake(topLeftCorner.x, topLeftCorner.y, rectDimensions.width, rectDimensions.height);
    
    if ([gr numberOfTouches] >= 2 ) {
        self.selectionBox = [NSValue valueWithCGRect:rect];
        if (!self.selectionBoxLayer) {
            self.selectionBoxLayer = [CALayer layer];
            self.selectionBoxLayer.backgroundColor = [UIColor grayColor].CGColor;
            self.selectionBoxLayer.opacity = 0.5;
            [self.layer addSublayer:self.selectionBoxLayer];
        }
        
    }
    
    if (self.selectionBoxLayer) {
        [CATransaction setDisableActions:YES];
        self.selectionBoxLayer.bounds = rect;
        self.selectionBoxLayer.anchorPoint = CGPointMake(0, 0);
        self.selectionBoxLayer.position = CGPointMake(topLeftCorner.x, topLeftCorner.y);
        [CATransaction setDisableActions:NO];
    }
    
    
    if (gr.state == (UIGestureRecognizerStateEnded)) {
        [self selection];
        self.selectionBox = nil;
        [self.selectionBoxLayer removeFromSuperlayer];
        self.selectionBoxLayer = nil;
    }
    
    if (gr.state == (UIGestureRecognizerStateCancelled)) {
        self.selectionBox = nil;
        [self.selectionBoxLayer removeFromSuperlayer];
        self.selectionBoxLayer = nil;
    }
}

// Method to get markers within a selection box
- (void)selection
{
    if (!self.selectedMarkers) {
        self.selectedMarkers = [[NSMutableArray alloc] init];
    }
    
    CGRect selectionBox = [self.selectionBox CGRectValue];
    
    for (HPDMarker *marker in self.allMarkers) {
        if (CGRectContainsPoint(selectionBox, marker.markerPosition)) {
            [self animateMarkerSelected:marker selected:YES offsetMarker:NO];
            [self.selectedMarkers addObject:marker];
            
            if (self.tutorialState == 1) {
                self.tutorialMovesCounter += 1;
            }
        }
    }
}

- (void)tap
{
//    NSLog(@"Tap");
    [self deselectMarkers];
}


#pragma mark - UIView Methods

- (void)initializeControlBar
{
    CGPoint positionOutsideScreen = CGPointMake(0, self.bounds.size.height + 100);
    CGFloat controlBarHeight = self.menuIconsize;
    
    if (!self.controlBar) {
        self.controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, positionOutsideScreen.y, self.bounds.size.width - controlBarHeight, controlBarHeight)];
        
        self.controlBar.backgroundColor = self.menuBarColor;
        //        self.controlBar.alpha = 0.9;
        [self addSubview:self.controlBar];
        
        self.toggleFormationButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 0, controlBarHeight, controlBarHeight)];
        self.toggleFormationButton.backgroundColor = [UIColor sunFlowerColor];
        
        UIImage *toggleIcon = [[UIImage imageNamed:@"toggleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.toggleFormationButton setTintColor:self.buttonTintColor];
        [self.toggleFormationButton setImage:toggleIcon forState:UIControlStateNormal];
        [self.toggleFormationButton addTarget:self action:@selector(togglePlayerPositions) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.controlBar addSubview:self.toggleFormationButton];
        
        // Buttons for animation
        self.addKeyframeButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 0, controlBarHeight, controlBarHeight)];
        self.addKeyframeButton.backgroundColor = [UIColor carrotColor];
        UIImage *recordIcon = [[UIImage imageNamed:@"recordIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.addKeyframeButton setTintColor:self.buttonTintColor];
        [self.addKeyframeButton setImage:recordIcon forState:UIControlStateNormal];
        [self.addKeyframeButton addTarget:self action:@selector(addKeyframe) forControlEvents:UIControlEventTouchUpInside];
        
        // initial state of addkeyframe button is disabled until touches have been made
        [self disableAddKeyframeButton];
        
        
        [self.controlBar addSubview:self.addKeyframeButton];
        
        self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(135, 0, controlBarHeight, controlBarHeight)];
        self.playButton.backgroundColor = [UIColor belizeHoleColor];
        UIImage *playImage = [[UIImage imageNamed:@"playIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.playButton setTintColor:self.buttonTintColor];
        [self.playButton setImage:playImage forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playbackFullAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self.controlBar addSubview:self.playButton];
        
        self.deleteKeyframesButton = [[UIButton alloc] initWithFrame:CGRectMake(185, 0, controlBarHeight, controlBarHeight)];
        self.deleteKeyframesButton.backgroundColor = [UIColor alizarinColor];
        UIImage *deleteImage = [[UIImage imageNamed:@"deleteIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.deleteKeyframesButton setTintColor:self.buttonTintColor];
        [self.deleteKeyframesButton setImage:deleteImage forState:UIControlStateNormal];
        [self.deleteKeyframesButton addTarget:self action:@selector(clearKeyframes) forControlEvents:UIControlEventTouchUpInside];
        [self.controlBar addSubview:self.deleteKeyframesButton];
        
        self.controlBarIsDisplayed = false;
    }

}

- (void)presentControlBar
{
    CGPoint positionOutsideScreen = CGPointMake(0, self.bounds.size.height + 100);
    CGFloat controlBarHeight = self.menuIconsize;
    
    if (self.tutorialState == 7) {
        [self nextTutorialState];
    }
    
    if (!self.controlBarIsDisplayed) {
        
        POPSpringAnimation *animation = [POPSpringAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/2.0 - controlBarHeight/2.0, self.bounds.size.height-controlBarHeight/2.0)];
        [self.controlBar pop_addAnimation:animation forKey:nil];
        
        if (self.tutorialState == 2 ) {
            [self nextTutorialState];
        }
        
        self.controlBarIsDisplayed = true;

    } else {
        POPSpringAnimation *animation = [POPSpringAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/2.0 - controlBarHeight/2.0, positionOutsideScreen.y)];
        [self.controlBar pop_addAnimation:animation forKey:nil];
    
        self.controlBarIsDisplayed = false;
    }
    
    
    
}

- (void)presentNotification:(NSString *)notificationText location:(CGPoint)point {
    [self presentNotification:notificationText location:point duration:0.5];
}

- (void)presentNotification:(NSString *)notificationText
{
    [self presentNotification:notificationText location:CGPointMake(self.bounds.size.width/2.0, 60)];
}

- (void)presentNotification:(NSString *)notificationText duration:(CGFloat) time {
    [self presentNotification:notificationText location:CGPointMake(self.bounds.size.width/2.0, 60) duration:time];
}

- (void)presentNotification:(NSString *)notificationText location:(CGPoint)point duration:(CGFloat)time{
    
    
    // Prevents overlapping notifications
    if (self.notificationForUser) {
        [self.notificationForUser removeFromSuperview];
    }
    // Options
    CGFloat timeNotificationStaysOn = time; // Time notification stays on screen
    CGFloat padding = 10;     // How much larger (extra width) the background of label is
    
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    labelText.text = notificationText;
    labelText.font = [labelText.font fontWithSize:13];
    labelText.textColor = [UIColor whiteColor];
    labelText.alpha = 0.7;
    [labelText sizeToFit];
    
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelText.frame.size.width + padding, labelText.frame.size.height + padding)];
    labelView.backgroundColor = [UIColor blackColor];
    labelView.alpha = 0.7;
    [self bringSubviewToFront:labelView];
    labelView.layer.cornerRadius = 3;
    [labelView addSubview:labelText];
    labelText.center = labelView.center;
    [labelView setCenter:point];
    
    [self addSubview:labelView];
    self.notificationForUser = labelView;
    
    POPBasicAnimation *animateIn = [POPBasicAnimation animation];
    animateIn.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    animateIn.fromValue = @(0);
    animateIn.toValue = [NSNumber numberWithFloat:labelView.alpha];
    [labelView pop_addAnimation:animateIn forKey:nil];
    
    CGFloat animateInDuration = animateIn.duration;
    
    
    if (time != 0) {
        POPSpringAnimation *animateOut = [POPSpringAnimation animation];
        animateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        animateOut.toValue = @(0);
        animateOut.beginTime = CACurrentMediaTime() + animateInDuration + timeNotificationStaysOn;
        [labelView pop_addAnimation:animateOut forKey:nil];

    }
}

- (CGSize)getSizeOfNotificationForText:(NSString *)text {
   
    // We create a new label here with the text string and return the size of the width
    CGFloat padding = 10;     // How much larger (extra width) the background of label is
    
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    labelText.text = text;
    labelText.font = [labelText.font fontWithSize:13];
    [labelText sizeToFit];
    
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelText.frame.size.width + padding, labelText.frame.size.height + padding)];
    labelView.layer.cornerRadius = 3;
    [labelView addSubview:labelText];
    
    return labelView.bounds.size;
}

- (void)clearNotification
{
    if (self.notificationForUser) {
        POPSpringAnimation *animateOut = [POPSpringAnimation animation];
        animateOut.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        animateOut.toValue = @(0);
        [self.notificationForUser pop_addAnimation:animateOut forKey:nil];

    }

}

- (void)disableAddKeyframeButton {
    self.addKeyframeButton.enabled = false;
}

- (void)disablePlayButton {
    self.playButton.enabled = false;
}

- (void)enablePlayButton {
    self.playButton.enabled = true;
}

- (void)enableAddKeyframeButton {
    self.addKeyframeButton.enabled = true;
}
#pragma mark - Helper Selection Methods

- (HPDMarker *)markerAtPoint:(CGPoint)point
{
    float touchThreshold = 23;
    for (HPDMarker *marker in self.allMarkers) {
        CGPoint markerPosition = marker.markerPosition;
        if (hypot(point.x - markerPosition.x, point.y - markerPosition.y) < touchThreshold) {
            return marker;
        }
    }
    return nil;
}

- (void)deselectMarkers
{
    if (self.selectedMarkers) {
//        NSLog(@"deselecting");
        for (HPDMarker *marker in self.allMarkers) {
            [self animateMarkerSelected:marker selected:NO offsetMarker:NO];
        }
    }
    self.selectedMarkers = nil;
    
}

#pragma mark - Tutorial Methods

- (void)startTutorial
{
    // state 0 basic touch
    // state 1 two finger drag
    // state 2 open menu
    // state 3 trigger formation
    // state 4 add frames
    // state 5 play animation
    // state 6 delete
    // state 7 close menu
    
    
    if (self.tutorialState <= 7) {
        self.tutorialState = 999;
        [self clearNotification];
        [self disableButtonsExcept:-1];
        return;
    }
    
    
    self.tutorialState = -1;
    self.tutorialMovesCounter = 0;
//    self.tutorialState = 1;
    
    if (self.controlBarIsDisplayed) {
        // hides the control bar
        [self presentControlBar];
    }
    
    [self nextTutorialState];
}

- (void)doTutorialWithState:(int)index
{
    
    
    CGFloat margin = 10;
    
    if (index == 0) {
        [self presentNotification:@"Drag a marker to move" duration:0];
        [self disableButtonsExcept:0];
        
    } else if (index == 1) {
        [self presentNotification:@"Use two fingers to select multiple markers" duration:0];
        [self disableButtonsExcept:0];
    } else if (index == 2) {
        
        NSString *openMenuString = @"Open Menu";
        CGSize labelSize = [self getSizeOfNotificationForText:openMenuString];
        

        [self presentNotification:openMenuString
                         location:CGPointMake(
                                              self.bounds.size.width - labelSize.width/2.0 - margin,
                                              self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin
                                              )
                         duration:0];
        [self disableButtonsExcept:1];
    } else if (index == 3) {
        

        NSString *toggleFormationString = @"Toggle formations";
        CGSize labelSize = [self getSizeOfNotificationForText:toggleFormationString];
        
        [self presentNotification:toggleFormationString
                         location:CGPointMake(
                                              labelSize.width/2.0 + margin,
                                              self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin
                                              )
                         duration:0];
        
        [self disableButtonsExcept:2];
        
    } else if (index == 4) {
        NSString *addKeyframeString = @"Add a keyframe";
        

        CGSize labelSize = [self getSizeOfNotificationForText:addKeyframeString];
        CGPoint location = CGPointMake(self.menuIconsize + labelSize.width/2.0 + margin,
                                       self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin);
        
        [self presentNotification:addKeyframeString location:location duration:0];
        [self disableButtonsExcept:3];
    } else if (index == 5) {
        NSString *pressPlayString = @"Press play";
        
        CGSize labelSize = [self getSizeOfNotificationForText:pressPlayString];
        CGPoint location = CGPointMake(self.menuIconsize*3+ labelSize.width/2.0,
                                       self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin);
        
        
        
        [self presentNotification:@"Press play" location:location duration:0];
        [self disableButtonsExcept:4];
    } else if (index == 6) {
        NSString *clearFramesString = @"Clear frames";
        
        CGSize labelSize = [self getSizeOfNotificationForText:clearFramesString];
        CGPoint location = CGPointMake(self.menuIconsize*4 + labelSize.width/2.0,
                                       self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin);
        
        [self presentNotification:clearFramesString location:location duration:0];
        [self disableButtonsExcept:5];
    } else if (index == 7) {
        NSString *closeMenuString = @"Close Menu";
        CGSize labelSize = [self getSizeOfNotificationForText:closeMenuString];
        
        
        [self presentNotification:closeMenuString
                         location:CGPointMake(
                                              self.bounds.size.width - labelSize.width/2.0 - margin,
                                              self.bounds.size.height - self.menuIconsize - labelSize.height/2.0 - margin
                                              )
                         duration:0];
        [self disableButtonsExcept:1];
    } else if (index == 8) {
        // set it to a number outside of the tutorial states
        self.tutorialState = 999;
        [self presentNotification:@"Tutorial Complete!" duration:1.0];
        [self disableButtonsExcept:-1];
    }

}

- (void)nextTutorialState
{
    self.tutorialState += 1;
    self.tutorialMovesCounter = 0;
//    NSLog(@"%d", self.tutorialState);
    [self clearNotification];
    [self doTutorialWithState:self.tutorialState];
}

// Put a zero to disable all buttons
// Put -1 to enable all buttons
- (void)disableButtonsExcept:(int)buttonIndex {
    
    // 0 - tutorial button
    // 1 - menu button
    // 2 - formation toggle button
    // 3 - add keyframe button
    // 4 - play button
    // 5 - delete button
    
    NSArray *buttonArray = [NSArray arrayWithObjects:
                            self.tutorialButton,
                            self.menuButton,
                            self.toggleFormationButton,
                            self.addKeyframeButton,
                            self.playButton,
                            self.deleteKeyframesButton,
                            nil];
    
    // start index at 1 because we don't want to disable the tutorial button
    for (int i = 1; i < buttonArray.count; i++) {
        
        UIButton *button = [buttonArray objectAtIndex:i];
        if (i == buttonIndex || buttonIndex < 0) {
            button.enabled = true;
        } else {
            button.enabled = false;
        }
    }
    
    
}
#pragma mark - Animation Methods

// BOOLEAN selected indicates true for touches begin, and false for touches ended
- (void)animateMarkerSelected:(HPDMarker *)marker selected:(BOOL)selected offsetMarker:(BOOL)offsetMarker
{
    CGFloat scaleFactor = 1.4;

    
    if (!selected) {
        scaleFactor = 1.0;
    }
    
//    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:marker.markerCALayer.transform];
//    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)];
//    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    scaleAnimation.duration = 0.1;
//    marker.markerCALayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
//
//    [marker.markerCALayer addAnimation:scaleAnimation forKey:nil];
//    
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
    springAnimation.springBounciness = 20;
    springAnimation.springSpeed = 50;
    springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(scaleFactor, scaleFactor)];
    

    [marker.markerCALayer pop_addAnimation:springAnimation forKey:nil];
    
    
    
    
    CGPoint positionAfterOffset;

    if (offsetMarker) {
        positionAfterOffset = CGPointMake(marker.markerCALayer.position.x, marker.markerPosition.y - self.touchoffset);

        POPBasicAnimation *translateAnimation = [POPBasicAnimation animation];
        translateAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
        translateAnimation.toValue = [NSValue valueWithCGPoint:positionAfterOffset];
        translateAnimation.duration = 0.1;
        marker.markerPosition = positionAfterOffset;
        [marker.markerCALayer pop_addAnimation:translateAnimation forKey:nil];
    }
}

// Using pop animtation
- (void)animateMarker:(HPDMarker *)marker toPosition:(CGPoint)newPosition beginTime:(CFTimeInterval)beginTime
{
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
    animation.toValue = [NSValue valueWithCGPoint:newPosition];
    animation.beginTime = beginTime;
    animation.duration = self.keyframeDuration;
    
    [marker.markerCALayer pop_addAnimation:animation forKey:nil];
    marker.markerPosition = newPosition;
}

#pragma mark - Marker Animated Strategy Methods

- (void)addKeyframe
{
    
    
    
    self.animationMode = YES;
    for (HPDMarker *marker in self.allMarkers) {
        [marker addKeyframe];
    }
    
    
    // Add playback scrubber bar
    if (!self.playbackScrubberView) {
        self.playbackScrubberView = [[HPDPlaybackScrubberView alloc] initWithFrame:CGRectMake(25, 15, self.bounds.size.width - 60, 20)];
//        self.playbackScrubberView.center = CGPointMake(self.center.x, 60);
        [self addSubview:self.playbackScrubberView];
    }
    
    // If number of keyframes exceed the screen, return
    if (self.playbackScrubberView.numberOfKeyframes >= 10) {
        [self presentNotification:@"Too many keyframes"];
        return;
    }
    
    [self.playbackScrubberView newKeyframe];
    
    // Add notification on screen to inform user of action
    if (self.tutorialState == 4) {
        
        if (self.tutorialMovesCounter == 6) {
            [self nextTutorialState];
        
        } else if (self.tutorialMovesCounter %2 == 0) {
            [self presentNotification:@"Move a marker" duration:0];
            self.tutorialMovesCounter += 1;
        }
        
    } else {
        [self presentNotification:@"Keyframe Added"];
    }
    

    
    [self disableAddKeyframeButton];
    
    if (self.tutorialState > 10) {
    
        [self enablePlayButton];
    }


}

- (void)playbackFullAnimation
{
    [self playbackAnimationfromFrame:0 toFrame:0];
    if (self.tutorialState == 5) {
        if (self.tutorialMovesCounter == 0) {
            [self presentNotification:@"Press play to playback again"  duration:0];
            self.tutorialMovesCounter += 1;
        } else {
            [self nextTutorialState];
        }

    }
}

- (void)playBackForwardToNextKeyframe
{
    if (self.currentKeyframe < self.playbackScrubberView.numberOfKeyframes) {
        [self playbackAnimationfromFrame:self.currentKeyframe toFrame:self.currentKeyframe+1];
        self.currentKeyframe+= 1;
    } else {
        self.currentKeyframe = 1;
        [self playbackAnimationfromFrame:self.currentKeyframe toFrame:self.currentKeyframe+1];
        self.currentKeyframe+= 1;
    }
}

- (void)playbackAnimationfromFrame:(int)startFrameNumber toFrame:(int)endFrameNumber
{
    // If not in animation mode, meaning that no keyframes have been created, return
    if (!self.animationMode) {
        return;
    }
    
    
    // Teleports all markers to original position
    for (HPDMarker *marker in self.allMarkers) {
        NSValue *firstPositionValue = [marker.keyframeArray firstObject];
        CGPoint firstPositionCGPoint = firstPositionValue.CGPointValue;
        
        marker.markerPosition = firstPositionCGPoint;
        [marker updateMarkerLayerDisableCATransaction:YES];
    }
    
    CGFloat totalDuration = 0;
    
    for (int i = 1; i < self.playbackScrubberView.numberOfKeyframes; i++) {
    
        for (HPDMarker *marker in self.allMarkers) {
            NSValue *nextPositionValue = [marker.keyframeArray objectAtIndex:i];
            CGPoint nextPositionCGPoint = nextPositionValue.CGPointValue;
            [self animateMarker:marker toPosition:nextPositionCGPoint beginTime:CACurrentMediaTime() +totalDuration];
        }


        totalDuration += self.keyframeDuration;

    }
    
    [self.playbackScrubberView scrubberPlaybackFromKeyframe:1 toKeyframe:(int)self.playbackScrubberView.numberOfKeyframes duration:self.keyframeDuration*(self.playbackScrubberView.numberOfKeyframes-1) beginTime:NO];
    
    // Add notification on screen to inform user of action
    if (self.tutorialState != 5) {
        [self presentNotification:@"Playing Animation"];
    }

    
}

- (void)clearKeyframes
{
    for (HPDMarker *marker in self.allMarkers) {
        [marker removeKeyframes];
    }
    
    self.animationMode = NO;
    
    // Remove from scrubber
    [self.playbackScrubberView clearKeyframes];
    
    // Add notification on screen to inform user of action
    if (self.tutorialState == 6) {
        [self nextTutorialState];
    } else {
        [self presentNotification:@"Keyframes Cleared"];
    }

    [self disablePlayButton];
    
}


@end

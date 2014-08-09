//
//  HPDFieldViewController.m
//  Ultimate Whiteboard
//
//  Created by Jia Hao on 29/7/14.
//  Copyright (c) 2014 Hippo Design. All rights reserved.
//

//#import <POP/POP.h>

#import "HPDFieldViewController.h"
#import "HPDFieldView.h"
#import "HPDFieldBackground.h"

@interface HPDFieldViewController ()

@property (nonatomic) HPDFieldView *fieldView;
@property (nonatomic) HPDFieldBackground *fieldBackground;

@end

@implementation HPDFieldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView
{


    
    HPDFieldBackground *fieldBackground = [[HPDFieldBackground alloc] init];
    self.fieldBackground = fieldBackground;
    self.view = self.fieldBackground;


}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    }

- (void)viewDidAppear:(BOOL)animated
{
    HPDFieldView *fieldView = [[HPDFieldView alloc] initWithFrame:self.view.bounds fieldBounds:self.fieldBackground.fieldBounds];
    
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
//    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 400, 400)];
//    [fieldView pop_addAnimation:anim forKey:@"myKey"];
    

    self.fieldView = fieldView;
    [self.view addSubview:self.fieldView];
//    self.fieldView.fieldBounds = self.fieldBackground.fieldBounds;
    [self.fieldView setNeedsDisplay];
    
    

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

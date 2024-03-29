//
//  MainViewController.m
//  CGFlowControllerDemo
//
//  Created by Chase (Charles) Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CGFlowController.h"
#import "TestViewController.h"

@interface MainViewController() <CGFlowControllerDelegate>

@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Example of creating test controllers with nonlive views vs live views
#ifndef STORYBOARD
    NSString *identifier;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        identifier = @"_iPad";
    } else {
        identifier = @"_iPhone";
    }
    
#if LIVE_VIEWS
    // Live Example
    // Passes the pointer reference to the actual instantiated view controller in memory
    TestViewController *testControllerCenter = [[TestViewController alloc] initWithNib:[NSString stringWithFormat:@"TestViewController%@", identifier] withName:@"Center" andCoordX:0 andY:0];
    TestViewController *testControllerLeft = [[TestViewController alloc] initWithNib:[NSString stringWithFormat:@"TestViewController%@", identifier] withName:@"Left" andCoordX:-1 andY:0];
    TestViewController *testControllerRight = [[TestViewController alloc] initWithNib:[NSString stringWithFormat:@"TestViewController%@", identifier] withName:@"Right" andCoordX:1 andY:0];
    TestViewController *testControllerTop = [[TestViewController alloc] initWithNib:[NSString stringWithFormat:@"TestViewController%@", identifier] withName:@"Top" andCoordX:0 andY:1];
    TestViewController *testControllerBottom = [[TestViewController alloc] initWithNib:[NSString stringWithFormat:@"TestViewController%@", identifier] withName:@"Bottom" andCoordX:0 andY:-1];
    [[CGFlowController sharedFlow] addLiveView:testControllerCenter withCoordX:0 andY:0];
    [[CGFlowController sharedFlow] addLiveView:testControllerLeft withCoordX:-1 andY:0];
    [[CGFlowController sharedFlow] addLiveView:testControllerRight withCoordX:1 andY:0];
    [[CGFlowController sharedFlow] addLiveView:testControllerTop withCoordX:0 andY:1];
    [[CGFlowController sharedFlow] addLiveView:testControllerBottom withCoordX:0 andY:-1];
    [[CGFlowController sharedFlow] setDelegate:self];
    testControllerCenter = nil;
    testControllerLeft = nil;
    testControllerRight = nil;
    testControllerTop = nil;
    testControllerBottom = nil;
#else
    // Non Live Example
    // Just passing the class that will be instantiated in the controller as it transitions to that view
    [[CGFlowController sharedFlow] setDelegate:self];
    [[CGFlowController sharedFlow] setNibIdentifier:identifier];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:-1 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:1 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:1];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:-1];
#endif
#else
    [[CGFlowController sharedFlow] setDelegate:self];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"CenterTestPanel" withCoordX:0 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"LeftTestPanel" withCoordX:-1 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"RightTestPanel" withCoordX:1 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"TopTestPanel" withCoordX:0 andY:1];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"BottomTestPanel" withCoordX:0 andY:-1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[CGFlowController sharedFlow] setStoryBoardName:@"Main_iPhone"];
    } else {
        [[CGFlowController sharedFlow] setStoryBoardName:@"Main_iPad"];
    }
#endif
    
    [self.view addSubview:[CGFlowController sharedFlow].view];
    [self addChildViewController:[CGFlowController sharedFlow]];
    [self.view bringSubviewToFront:[CGFlowController sharedFlow].view];
}

#pragma mark - CGFlowDelegate Methods

// These methods are optional, but are shown for proof of concept and can also be turned on and off
// in the prefix
#if TRANSITION_METHODS
-(void)startFlowTransition:(BOOL)animated {
    NSLog(@"Starting Transition");
}

-(void)endFlowTransition:(BOOL)animated {
    NSLog(@"Ending Transition");
}
#endif

#pragma mark - Memory Delegate

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

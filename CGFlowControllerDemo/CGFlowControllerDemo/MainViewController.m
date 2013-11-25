//
//  MainViewController.m
//  FlowControllerTest
//
//  Created by Chase Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CGFlowController.h"
#import "TestViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *identifier;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        identifier = @"_iPad";
    } else {
        identifier = @"_iPhone";
    }
    
    // Example of creating test controllers with nonlive views vs live views
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
    testControllerCenter = nil;
    testControllerLeft = nil;
    testControllerRight = nil;
    testControllerTop = nil;
    testControllerBottom = nil;
#else
    // Non Live Example
    // Just passing the class that will be instantiated in the controller as it transitions to that view
    [[CGFlowController sharedFlow] setNibIdentifier:identifier];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:-1 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:1 andY:0];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:1];
    [[CGFlowController sharedFlow] addNonLiveView:[TestViewController class] withCoordX:0 andY:-1];
#endif
    
    [self.view addSubview:[CGFlowController sharedFlow].view];
    [self addChildViewController:[CGFlowController sharedFlow]];
    [self.view bringSubviewToFront:[CGFlowController sharedFlow].view];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CGPanelView.m
//  FlowControllerTest
//
//  Created by Chase Gorectke on 11/22/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
//

#import "CGPanelView.h"
#import "CGFlowController.h"

@interface CGPanelView()

@end

@implementation CGPanelView
@synthesize allowAppearenceCalls=_allowAppearenceCalls;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _allowAppearenceCalls = false;
}

+(void)viewWillAppear:(BOOL)animated {
//    if (_allowAppearenceCalls) {
//        [super viewWillAppear:animated];
//        CGPoint currentPos = [[CGFlowController sharedFlow] getCoordsForLoadedView:self];
//        NSLog(@"View %d,%d Will Appear", (int)currentPos.x, (int)currentPos.y);
//    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        [super viewDidAppear:animated];
        CGPoint currentPos = [[CGFlowController sharedFlow] getCoordsForLoadedView:self];
        NSLog(@"View %d,%d Will Appear", (int)currentPos.x, (int)currentPos.y);
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        CGPoint currentPos = [[CGFlowController sharedFlow] getCoordsForLoadedView:self];
        NSLog(@"View %d,%d Will Appear", (int)currentPos.x, (int)currentPos.y);
        [super viewWillDisappear:animated];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        CGPoint currentPos = [[CGFlowController sharedFlow] getCoordsForLoadedView:self];
        NSLog(@"View %d,%d Will Appear", (int)currentPos.x, (int)currentPos.y);
        [super viewDidDisappear:animated];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

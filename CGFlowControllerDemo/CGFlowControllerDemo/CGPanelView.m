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
-(void)panelWillAppear:(BOOL)animated;
-(void)panelDidAppear:(BOOL)animated;
-(void)panelWillDisappear:(BOOL)animated;
-(void)panelDidDisappear:(BOOL)animated;
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

-(void)viewWillAppearCall:(BOOL)animated {
    _allowAppearenceCalls = YES;
    [self viewWillAppear:animated];
}

-(void)viewDidAppearCall:(BOOL)animated {
    _allowAppearenceCalls = YES;
    [self viewDidAppear:animated];
}

-(void)viewWillDisappearCall:(BOOL)animated {
    _allowAppearenceCalls = YES;
    [self viewWillDisappear:animated];
}

-(void)viewDidDisappearCall:(BOOL)animated {
    _allowAppearenceCalls = YES;
    [self viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        [super viewWillAppear:animated];
        [self panelWillAppear:animated];
        _allowAppearenceCalls = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        [super viewDidAppear:animated];
        [self panelDidAppear:animated];
        _allowAppearenceCalls = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        [self panelWillDisappear:animated];
        [super viewWillDisappear:animated];
        _allowAppearenceCalls = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        [self panelDidDisappear:animated];
        [super viewDidDisappear:animated];
        _allowAppearenceCalls = NO;
    }
}

-(void)panelWillAppear:(BOOL)animated {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

-(void)panelDidAppear:(BOOL)animated {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

-(void)panelWillDisappear:(BOOL)animated {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

-(void)panelDidDisappear:(BOOL)animated {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CGPanelView.m
//
//  Created by Chase (Charles) Gorectke on 11/22/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
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
        _allowAppearenceCalls = NO;
        [super viewWillAppear:animated];
        [self panelWillAppear:animated];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        _allowAppearenceCalls = NO;
        [super viewDidAppear:animated];
        [self panelDidAppear:animated];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        _allowAppearenceCalls = NO;
        [self panelWillDisappear:animated];
        [super viewWillDisappear:animated];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    if (_allowAppearenceCalls) {
        _allowAppearenceCalls = NO;
        [self panelDidDisappear:animated];
        [super viewDidDisappear:animated];
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

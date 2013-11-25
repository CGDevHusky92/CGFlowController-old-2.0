//
//  TestViewController.m
//  FlowControllerTest
//
//  Created by Chase Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
#import "CGFlowController.h"

@interface TestViewController()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *testLabel;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) IBOutlet UIButton *topButton;
@property (nonatomic, weak) IBOutlet UIButton *bottomButton;

#if LIVE_VIEWS
@property (nonatomic, strong) NSString *name;
@property (atomic) int xCoord;
@property (atomic) int yCoord;
#endif

@end

@implementation TestViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#if LIVE_VIEWS
-(id)initWithNib:(NSString *)nibNameOrNil withName:(NSString *)name andCoordX:(int)xCoord andY:(int)yCoord {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        _name = name;
        _xCoord = xCoord;
        _yCoord = yCoord;
    }
    return self;
}
#endif

-(void)viewDidLoad {
    [super viewDidLoad];
#if LIVE_VIEWS
    _nameLabel.text = _name;
    _testLabel.text = [NSString stringWithFormat:@"Screen (%d, %d)", _xCoord, _yCoord];

    if (![[CGFlowController sharedFlow] viewHasLeft:self]) {
        [_leftButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasRight:self]) {
        [_rightButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasTop:self]) {
        [_topButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasBottom:self]) {
        [_bottomButton setHidden:YES];
    }
#endif
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    // Example of getting information about where the view controller is located
    [super viewWillAppear:animated];
#if !LIVE_VIEWS
    CGPoint currentPos = [[CGFlowController sharedFlow] getCoordsForLoadedView:self];
    _testLabel.text = [NSString stringWithFormat:@"Screen (%d, %d)", ((int)currentPos.x), ((int)currentPos.y)];
    
    if (![[CGFlowController sharedFlow] viewHasLeft:self]) {
        [_leftButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasRight:self]) {
        [_rightButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasTop:self]) {
        [_topButton setHidden:YES];
    }
    
    if (![[CGFlowController sharedFlow] viewHasBottom:self]) {
        [_bottomButton setHidden:YES];
    }
#endif
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(IBAction)upPressed:(id)sender {
    NSLog(@"Up Pressed");
    [[CGFlowController sharedFlow] showTopController];
}

-(IBAction)downPressed:(id)sender {
    NSLog(@"Down Pressed");
    [[CGFlowController sharedFlow] showBottomController];
}

-(IBAction)leftPressed:(id)sender {
    NSLog(@"Left Pressed");
    [[CGFlowController sharedFlow] showLeftController];
}

-(IBAction)rightPressed:(id)sender {
    NSLog(@"Right Pressed");
    [[CGFlowController sharedFlow] showRightController];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

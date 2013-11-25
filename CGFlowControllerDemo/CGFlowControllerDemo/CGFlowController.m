//
//  CGFlowViewController.m
//  ThisOrThat
//
//  Created by Charles (Chase) Gorectke on 7/24/13.
//  Copyright Revision Works 2013
//  Engineering A Better World
//

#import "CGFlowController.h"

#define SLIDE_TIMING                .25     /* Good Slide Value */
#define ACCELERATED_SWIPE_RATIO     .008    /* 0 will kill any added acceleration I wouldn't recommend no more then .01 */
#define PER_COMPLETE_SLIDE_X        .7      /* Percentage you need to swipe and then let go for it to complete in x direction */
#define PER_COMPLETE_SLIDE_Y        .5      /* Percentage you need to swipe and then let go for it to complete in x direction */

@interface CGFlowController()
@property (nonatomic, strong) CGPanelView *centerController;
@property (nonatomic, strong) CGPanelView *leftController;
@property (nonatomic, strong) CGPanelView *rightController;
@property (nonatomic, strong) CGPanelView *topController;
@property (nonatomic, strong) CGPanelView *bottomController;
@property (nonatomic, strong) NSString *nibIdentifier;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) BOOL showingTopPanel;
@property (nonatomic, assign) BOOL showingBottomPanel;
@property (nonatomic, assign) BOOL showPanelX;
@property (nonatomic, assign) BOOL showPanelY;
@property (nonatomic, assign) int velocityCheck;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic, strong) NSMutableDictionary *viewCollection;
@property (nonatomic, strong) NSMutableDictionary *liveCollection;
@property (nonatomic, strong) NSNumber *xCoordinate;
@property (nonatomic, strong) NSNumber *yCoordinate;
-(void)setStartViewWithCoord:(int)theX andY:(int)theY;
@end

@implementation CGFlowController
@synthesize xMovement=_xMovement;
@synthesize yMovement=_yMovement;
@synthesize xWrapAround=_xWrapAround;
@synthesize yWrapAround=_yWrapAround;
@synthesize forceFinish=_forceFinish;

-(id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        _xMovement = true;
        _yMovement = true;
        _xWrapAround = false;
        _yWrapAround = false;
        _viewCollection = [[NSMutableDictionary alloc] init];
        _liveCollection = [[NSMutableDictionary alloc] init];
        _forceFinish = false;
    }
    return self;
}

+(CGFlowController *)sharedFlow {
    static CGFlowController *sharedFlow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFlow = [[CGFlowController alloc] init];
    });
    
    return sharedFlow;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setStartViewWithCoord:0 andY:0];
    self.started = false;
    _velocityCheck = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.started) {
        [self determineNewViews:0 and:0];
        
        _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        
        [self.view addSubview:_centerController.view];
        [self.view addSubview:_leftController.view];
        [self.view addSubview:_rightController.view];
        [self.view addSubview:_topController.view];
        [self.view addSubview:_bottomController.view];
        [self.view bringSubviewToFront:_bottomController.view];
        [self.view bringSubviewToFront:_topController.view];
        [self.view bringSubviewToFront:_leftController.view];
        [self.view bringSubviewToFront:_rightController.view];
        [self.view bringSubviewToFront:_centerController.view];
        self.started = true;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)movePanel:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if (_forceFinish) {
        if (_velocityCheck == 1 && _xMovement) {
            if (!_showPanelX) {
                [self movePanelToOriginalPosition];
            } else {
                if (_showingLeftPanel) {
                    [self movePanelRight];
                }  else if (_showingRightPanel) {
                    [self movePanelLeft];
                }
            }
        } else if (_velocityCheck == 2 && _yMovement) {
            if (!_showPanelY) {
                [self movePanelToOriginalPosition];
            } else {
                if (_showingBottomPanel) {
                    [self movePanelUp];
                }  else if (_showingTopPanel) {
                    [self movePanelDown];
                }
            }
        }
        
        _velocityCheck = 0;
        _forceFinish = false;
    } else {
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            UIView *childView = nil;
            [self startTransition];
            if (abs(velocity.x) > abs(velocity.y)) {
                // Velocity in x is greater then y move screen left or right
                _velocityCheck = 1;
            } else if (abs(velocity.y) > abs(velocity.x))  {
                // Velocity in y is greater then x move screen up or down
                _velocityCheck = 2;
            }
            
            if (_velocityCheck == 1 && _xMovement) {
                if(velocity.x > 0) {
                    if (!_showingRightPanel) {
#warning viewWillAppear and viewWillDisappear
//                        [_leftController viewWillAppear:YES];
//                        [_centerController viewWillDisappear:YES];
                        childView = [self getLeftViewController].view;
                    }
                } else {
                    if (!_showingLeftPanel) {
//                        [_rightController viewWillAppear:YES];
                        childView = [self getRightViewController].view;
                    }
                }
            } else if (_velocityCheck == 2 && _yMovement) {
                if(velocity.y > 0) {
                    if (!_showingBottomPanel) {
//                        [_topController viewWillAppear:YES];
                        childView = [self getTopViewController].view;
                    }
                } else {
                    if (!_showingTopPanel) {
//                        [_bottomController viewWillAppear:YES];
                        childView = [self getBottomViewController].view;
                    }
                }
            }
            // make sure the view we're working with is front and center
            if (childView != nil) {
                [self.view sendSubviewToBack:childView];
                [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
            }
        }
        
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            if (_velocityCheck == 1 && _xMovement) {
                if (!_showPanelX) {
                    [self movePanelToOriginalPosition];
                } else {
                    if (_showingLeftPanel) {
#warning viewDidDisappear and viewDidAppear
                        [self movePanelRight];
                    }  else if (_showingRightPanel) {
                        [self movePanelLeft];
                    }
                }
            } else if (_velocityCheck == 2 && _yMovement) {
                if (!_showPanelY) {
                    [self movePanelToOriginalPosition];
                } else {
                    if (_showingBottomPanel) {
                        [self movePanelUp];
                    }  else if (_showingTopPanel) {
                        [self movePanelDown];
                    }
                }
            }
            
            _velocityCheck = 0;
        }
        
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
            if (_velocityCheck == 1 && _xMovement) {
                // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
                _showPanelX = abs([sender view].center.x - [sender view].frame.size.width / 2) > (([sender view].frame.size.width / 2) * PER_COMPLETE_SLIDE_X);
                
                if (_leftController != nil && _rightController != nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if (!((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) > (self.view.frame.size.width / 2) || (_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) < (self.view.frame.size.width / 2))) {
                        _leftController.view.center = CGPointMake(_leftController.view.center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO), _leftController.view.center.y);
                        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO), [sender view].center.y);
                        _rightController.view.center = CGPointMake(_rightController.view.center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO), _rightController.view.center.y);
                    } else if ((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) > (self.view.frame.size.width / 2)) {
                        _leftController.view.center = CGPointMake((self.view.frame.size.width / 2), _leftController.view.center.y);
                        [sender view].center = CGPointMake((self.view.frame.size.width + (self.view.frame.size.width / 2)), [sender view].center.y);
                        _rightController.view.center = CGPointMake(((2 * self.view.frame.size.width) + (self.view.frame.size.width / 2)), _rightController.view.center.y);
                    } else if ((_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) < (self.view.frame.size.width / 2)) {
                        _leftController.view.center = CGPointMake(-(self.view.frame.size.width + (self.view.frame.size.width / 2)), _leftController.view.center.y);
                        [sender view].center = CGPointMake(-(self.view.frame.size.width / 2), [sender view].center.y);
                        _rightController.view.center = CGPointMake((self.view.frame.size.width / 2), _rightController.view.center.y);
                    }
                } else if (_leftController == nil && _rightController == nil) { } else if (_leftController == nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if ((([sender view].center.x <= (self.view.frame.size.width / 2)) && velocity.x < 0) || (([sender view].center.x < (self.view.frame.size.width / 2)) && velocity.x > 0)) {
                        if ((_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) <= self.view.center.x) {
                            _rightController.view.center = CGPointMake(self.view.center.x, _rightController.view.center.y);
                            [sender view].center = CGPointMake((self.view.center.x - self.view.frame.size.width), [sender view].center.y);
                        } else {
                            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO), [sender view].center.y);
                            _rightController.view.center = CGPointMake(_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO), _rightController.view.center.y);
                        }
                    } else {
                        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y);
                        _rightController.view.center = CGPointMake(_rightController.view.center.x, _rightController.view.center.y);
                    }
                } else if (_rightController == nil) {
                    if (([sender view].center.x >= (self.view.frame.size.width / 2) && velocity.x > 0) || ([sender view].center.x > (self.view.frame.size.width / 2) && velocity.x < 0)) {
                        if ((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO)) >= self.view.center.x) {
                            _leftController.view.center = CGPointMake(self.view.center.x, _leftController.view.center.y);
                            [sender view].center = CGPointMake((self.view.center.x + self.view.frame.size.width), [sender view].center.y);
                        } else {
                            _leftController.view.center = CGPointMake(_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO), _leftController.view.center.y);
                            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO), [sender view].center.y);
                        }
                    } else {
                        _leftController.view.center = CGPointMake(_leftController.view.center.x, _leftController.view.center.y);
                        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y);
                    }
                }
                
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
                _preVelocity = velocity;
            } else if (_velocityCheck == 2 && _yMovement) {
                // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
                _showPanelY = abs([sender view].center.y - [sender view].frame.size.height / 2) > (([sender view].frame.size.height / 2) * PER_COMPLETE_SLIDE_Y);
                
                if (_bottomController != nil && _topController != nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if (!((_bottomController.view.center.y + translatedPoint.y + ((double)velocity.y) * ACCELERATED_SWIPE_RATIO) < (self.view.frame.size.height / 2) || (_topController.view.center.y + translatedPoint.y + ((double)velocity.y) * ACCELERATED_SWIPE_RATIO) > (self.view.frame.size.height / 2))) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, _bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                        _topController.view.center = CGPointMake(_topController.view.center.x, _topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                    } else if ((_bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO)) < (self.view.frame.size.height / 2)) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, (self.view.frame.size.height / 2));
                        [sender view].center = CGPointMake([sender view].center.x, -(self.view.frame.size.height / 2));
                        _topController.view.center = CGPointMake(_topController.view.center.x, -(self.view.frame.size.height + (self.view.frame.size.height / 2)));
                    } else if ((_topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO)) > (self.view.frame.size.height / 2)) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, ((2 * self.view.frame.size.height) + (self.view.frame.size.height / 2)));
                        [sender view].center = CGPointMake([sender view].center.x, (self.view.frame.size.height + (self.view.frame.size.height / 2)));
                        _topController.view.center = CGPointMake(_topController.view.center.x, (self.view.frame.size.height / 2));
                    }
                } else if (_bottomController == nil && _topController == nil) { } else if (_bottomController == nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if ((([sender view].center.y <= (self.view.frame.size.height / 2)) && velocity.y < 0) || (([sender view].center.y < (self.view.frame.size.height / 2)) && velocity.y > 0)) {
                        [sender view].center = CGPointMake([sender view].center.x, (self.view.frame.size.height / 2));
                        _topController.view.center = CGPointMake(_topController.view.center.x, -(self.view.frame.size.height / 2));
                    } else {
                        if ((_topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO)) >= self.view.center.y) {
                            [sender view].center = CGPointMake([sender view].center.x, (self.view.center.y + self.view.frame.size.height));
                            _topController.view.center = CGPointMake(_topController.view.center.x, self.view.center.y);
                        } else {
                            [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                            _topController.view.center = CGPointMake(_topController.view.center.x, _topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                        }
                    }
                } else if (_topController == nil) {
                    if (([sender view].center.y >= (self.view.frame.size.height / 2) && velocity.y > 0) || ([sender view].center.y > (self.view.frame.size.height / 2) && velocity.y < 0)) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, (self.view.frame.size.height + (self.view.frame.size.height / 2)));
                        [sender view].center = CGPointMake([sender view].center.x, (self.view.frame.size.height / 2));
                    } else {
                        if ((_bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO)) <= self.view.center.y) {
                            [sender view].center = CGPointMake([sender view].center.x, (self.view.center.y - self.view.frame.size.height));
                            _bottomController.view.center = CGPointMake(_bottomController.view.center.x, self.view.center.y);
                        } else {
                            _bottomController.view.center = CGPointMake(_bottomController.view.center.x, _bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                            [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO));
                        }
                    }
                }
                
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
                _preVelocity = velocity;
            }
        }
    }
}

-(void)startTransition {
    // Add code you need to fire when starting to transition.
    // aka end table views from editing or any other sort of transition
}

-(void)movePanelToOriginalPosition {
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self resetMainView];
        }
    }];
}

-(void)movePanelLeft {
    if (_xMovement) {
        UIView *childView = [self getRightViewController].view;
        [self.view sendSubviewToBack:childView];
        
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _leftController.view.frame = CGRectMake(-self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
            _centerController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
            _rightController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self determineNewViews:1 and:0];
            [self resetMainView];
        }];
    }
}

-(void)movePanelRight {
    if (_xMovement) {
        UIView *childView = [self getLeftViewController].view;
        [self.view sendSubviewToBack:childView];
        
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _leftController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _centerController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
            _rightController.view.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self determineNewViews:-1 and:0];
            [self resetMainView];
        }];
    }
}

-(void)movePanelUp {
    if (_yMovement) {
        UIView *childView = [self getBottomViewController].view;
        [self.view sendSubviewToBack:childView];
        
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            _topController.view.frame = CGRectMake(0, -self.view.frame.size.height * 2, self.view.frame.size.width, self.view.frame.size.height);
            _bottomController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self determineNewViews:0 and:-1];
            [self resetMainView];
        }];
    }
}

-(void)movePanelDown {
    if (_yMovement) {
        UIView *childView = [self getTopViewController].view;
        [self.view sendSubviewToBack:childView];
        
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            _topController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height * 2, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self determineNewViews:0 and:1];
            [self resetMainView];
        }];
    }
}

-(BOOL)hasLeftController {
    return (_leftController != nil);
}

-(BOOL)hasRightController {
    return (_rightController != nil);
}

-(BOOL)hasTopController {
    return (_topController != nil);
}

-(BOOL)hasBottomController {
    return (_bottomController != nil);
}

-(void)showLeftController {
    if (_leftController != nil) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _xMovement = true;
        _yMovement = false;
        [_centerController viewWillDisappear:true];
        [_leftController viewWillAppear:true];
        [self movePanelRight];
        [_rightController viewDidDisappear:true];
        [_centerController viewDidAppear:true];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showRightController {
    if (_rightController != nil) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _xMovement = true;
        _yMovement = false;
        [_centerController viewWillDisappear:true];
        [_rightController viewWillAppear:true];
        [self movePanelLeft];
        [_leftController viewDidDisappear:true];
        [_centerController viewDidAppear:true];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showTopController {
    if (_topController != nil) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _yMovement = true;
        _xMovement = false;
        [_centerController viewWillDisappear:true];
        [_topController viewWillAppear:true];
        [self movePanelDown];
        [_bottomController viewDidDisappear:true];
        [_centerController viewDidAppear:true];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showBottomController {
    if (_bottomController != nil) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _yMovement = true;
        _xMovement = false;
        [_centerController viewWillDisappear:true];
        [_bottomController viewWillAppear:true];
        [self movePanelUp];
        [_topController viewDidDisappear:true];
        [_centerController viewDidAppear:true];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(UIViewController *)getLeftViewController {
	// init view if it doesn't already exist
    self.showingLeftPanel = YES;
	return _leftController;
}

-(UIViewController *)getRightViewController {
	// init view if it doesn't already exist
    self.showingRightPanel = YES;
	return _rightController;
}

-(UIViewController *)getTopViewController {
    // init view if it doesn't already exist
    self.showingTopPanel = YES;
	return _topController;
}

-(UIViewController *)getBottomViewController {
    // init view if it doesn't already exist
    self.showingBottomPanel = YES;
	return _bottomController;
}

-(void)resetMainView {
    self.showingLeftPanel = NO;
    self.showingRightPanel = NO;
    self.showingTopPanel = NO;
    self.showingBottomPanel = NO;
    
    if (_centerController != nil) {
        [self.view addSubview:_centerController.view];
        [self.view bringSubviewToFront:_centerController.view];
        [_centerController setAllowAppearenceCalls:NO];
    }
    if (_leftController != nil) {
        [self.view addSubview:_leftController.view];
        [self.view bringSubviewToFront:_leftController.view];
    }
    if (_rightController != nil) {
        [self.view addSubview:_rightController.view];
        [self.view bringSubviewToFront:_rightController.view];
    }
    if (_topController != nil) {
        [self.view addSubview:_topController.view];
        [self.view bringSubviewToFront:_topController.view];
    }
    if (_bottomController != nil) {
        [self.view addSubview:_bottomController.view];
        [self.view bringSubviewToFront:_bottomController.view];
    }
    
    _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {}];
}

-(void)determineNewViews:(int)dirRightLeft and:(int)dirUpDown {
    // dirRightLeft: -1 - left, 0 - Neutral, 1 - right
    // dirUpDown: -1 - Down, 0 - no change, 1 - up
    int newX = ([_xCoordinate intValue] + dirRightLeft);
    int newY = ([_yCoordinate intValue] + dirUpDown);
    
    if ([self viewExistsAtCoordX:newX andY:newY]) {
        // Set Center
        [_centerController setAllowAppearenceCalls:YES];
        [_centerController.view removeFromSuperview];
        [_leftController.view removeFromSuperview];
        [_rightController.view removeFromSuperview];
        [_topController.view removeFromSuperview];
        [_bottomController.view removeFromSuperview];
        
        _centerController = [self getViewAtCoordX:newX andY:newY];
        [self.view bringSubviewToFront:_centerController.view];
        
        _leftController = [self getViewAtCoordX:(newX - 1) andY:newY];
        _rightController = [self getViewAtCoordX:(newX + 1) andY:newY];
        _topController = [self getViewAtCoordX:newX andY:(newY + 1)];
        _bottomController = [self getViewAtCoordX:newX andY:(newY - 1)];
        
//        [_centerController setAllowAppearenceCalls:NO];
//        if (dirRightLeft < 0) {
//            [_rightController setAllowAppearenceCalls:YES];
//        } else if (dirRightLeft > 0) {
//            [_leftController setAllowAppearenceCalls:YES];
//        } else if (dirUpDown > 0) {
//            [_bottomController setAllowAppearenceCalls:YES];
//        } else if (dirUpDown < 0) {
//            [_topController setAllowAppearenceCalls:YES];
//        }
        
        _xCoordinate = [NSNumber numberWithInt:newX];
        _yCoordinate = [NSNumber numberWithInt:newY];
        
        UIPanGestureRecognizer *panGestureCenter = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panGestureCenter setMinimumNumberOfTouches:1];
        [panGestureCenter setMaximumNumberOfTouches:1];
        [panGestureCenter setDelegate:self];
        
        UIPanGestureRecognizer *panGestureLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panGestureLeft setMinimumNumberOfTouches:1];
        [panGestureLeft setMaximumNumberOfTouches:1];
        [panGestureLeft setDelegate:self];
        
        UIPanGestureRecognizer *panGestureRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panGestureRight setMinimumNumberOfTouches:1];
        [panGestureRight setMaximumNumberOfTouches:1];
        [panGestureRight setDelegate:self];
        
        UIPanGestureRecognizer *panGestureTop = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panGestureTop setMinimumNumberOfTouches:1];
        [panGestureTop setMaximumNumberOfTouches:1];
        [panGestureTop setDelegate:self];
        
        UIPanGestureRecognizer *panGestureBottom = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panGestureBottom setMinimumNumberOfTouches:1];
        [panGestureBottom setMaximumNumberOfTouches:1];
        [panGestureBottom setDelegate:self];
        
        [_centerController.view addGestureRecognizer:panGestureCenter];
        [_leftController.view addGestureRecognizer:panGestureLeft];
        [_rightController.view addGestureRecognizer:panGestureRight];
        [_bottomController.view addGestureRecognizer:panGestureBottom];
        [_topController.view addGestureRecognizer:panGestureTop];
        
        panGestureCenter = nil;
        panGestureLeft = nil;
        panGestureRight = nil;
        panGestureTop = nil;
        panGestureBottom = nil;
    } else {
        [self movePanelToOriginalPosition];
    }
}

#pragma mark - Custom View Grab Code

-(void)addNonLiveView:(Class)theClass withCoordX:(int)theX andY:(int)theY {
    NSString *newIdentifier = [NSString stringWithFormat:@"%d,%d", theX, theY];
    NSMutableArray *classArray = [[NSMutableArray alloc] init];
    
    [classArray addObject:theClass];
    [classArray addObject:[NSNumber numberWithInt:theX]];
    [classArray addObject:[NSNumber numberWithInt:theY]];
    
    [_viewCollection setValue:classArray forKey:newIdentifier];
}

-(void)addLiveView:(UIViewController *)view withCoordX:(int)theX andY:(int)theY {
    [_liveCollection setValue:view forKey:[NSString stringWithFormat:@"%d,%d", theX, theY]];
}

-(id)getViewAtCoordX:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        NSString *newIdentifier = [NSString stringWithFormat:@"%d,%d", theX, theY];
        if ([_liveCollection valueForKey:newIdentifier] != nil) {
            return [_liveCollection valueForKey:newIdentifier];
        }
        
        NSMutableArray *classArray = [_viewCollection valueForKey:newIdentifier];
        Class type = [classArray objectAtIndex:0];
        __strong __typeof__(type) classController = classController = [[type alloc] initWithNibName:[NSString stringWithFormat:@"%@%@", NSStringFromClass(type), _nibIdentifier] bundle:nil];
        
        return classController;
    }
    return nil;
}

-(void)moveCustomPathToX:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        _xCoordinate = [NSNumber numberWithInt:theX];
        _yCoordinate = [NSNumber numberWithInt:theY];
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [self determineNewViews:0 and:0];
            [self resetMainView];
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    [self determineNewViews:theX and:theY];
                    [self resetMainView];
                } completion:^(BOOL finished){
                    if (finished) {
                        [self.parentViewController viewWillAppear:NO];
                        [self.centerController viewWillAppear:NO];
                    }
                }];
            }
        }];
    }
}

-(BOOL)viewExistsAtCoordX:(int)theX andY:(int)theY {
    NSString *newIdentifier = [NSString stringWithFormat:@"%d,%d", theX, theY];
    if ([_liveCollection valueForKey:newIdentifier] != nil) {
        return YES;
    } else if ([_viewCollection valueForKey:newIdentifier] != nil) {
        return YES;
    }
    return NO;
}

-(void)setStartViewWithCoord:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        _xCoordinate = [NSNumber numberWithInt:theX];
        _yCoordinate = [NSNumber numberWithInt:theY];
    }
}

-(CGPoint)getCurrentView {
    return CGPointMake([_xCoordinate floatValue], [_yCoordinate floatValue]);
}

-(NSString *)whichViewAmI:(UIViewController *)view {
    if ([view isEqual:_leftController]) {
        return @"Left";
    } else if ([view isEqual:_rightController]) {
        return @"Right";
    } else if ([view isEqual:_centerController]) {
        return @"Center";
    } else if ([view isEqual:_topController]) {
        return @"Top";
    } else if ([view isEqual:_bottomController]) {
        return @"Bottom";
    } else {
        return @"Not Found";
    }
}

-(CGPoint)getCoordsForLoadedView:(UIViewController *)view {
    if ([view isEqual:_leftController]) {
        return CGPointMake([_xCoordinate intValue] - 1, [_yCoordinate intValue]);
    } else if ([view isEqual:_rightController]) {
        return CGPointMake([_xCoordinate intValue] + 1, [_yCoordinate intValue]);
    } else if ([view isEqual:_centerController]) {
        return CGPointMake([_xCoordinate intValue], [_yCoordinate intValue]);
    } else if ([view isEqual:_topController]) {
        return CGPointMake([_xCoordinate intValue], [_yCoordinate intValue] + 1);
    } else if ([view isEqual:_bottomController]) {
        return CGPointMake([_xCoordinate intValue], [_yCoordinate intValue] - 1);
    } else {
        return CGPointZero;
    }
}

-(BOOL)viewHasLeft:(CGPanelView *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:(viewCoords.x - 1) andY:viewCoords.y];
}

-(BOOL)viewHasRight:(CGPanelView *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:(viewCoords.x + 1) andY:viewCoords.y];
}

-(BOOL)viewHasTop:(CGPanelView *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:viewCoords.x andY:(viewCoords.y + 1)];
}

-(BOOL)viewHasBottom:(CGPanelView *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:viewCoords.x andY:(viewCoords.y - 1)];
}

-(void)setNibIdentifier:(NSString *)ident {
    _nibIdentifier = ident;
}

#pragma mark - Memory Delegate

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

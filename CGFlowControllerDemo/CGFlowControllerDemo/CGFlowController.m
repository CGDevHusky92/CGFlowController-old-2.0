//
//  CGFlowViewController.m
//
//  Created by Chase (Charles) Gorectke on 7/24/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//

#import "CGFlowController.h"

#define SLIDE_TIMING                .25     /* Good Slide Value */
#define ACCELERATED_SWIPE_RATIO_X   .008    /* swipe acceleration in the x dir 0 is no acceleration I wouldn't recommend more then .01 */
#define ACCELERATED_SWIPE_RATIO_Y   .012    /* swipe acceleration in the y dir 0 is no acceleration I wouldn't recommend more then .014 */
#define PER_COMPLETE_SLIDE_X        .7      /* Percentage you need to swipe and then let go for it to complete in x direction */
#define PER_COMPLETE_SLIDE_Y        .5      /* Percentage you need to swipe and then let go for it to complete in x direction */

@interface CGFlowController()
#ifdef STORYBOARD
@property (nonatomic, strong) UIViewController *centerController;
@property (nonatomic, strong) UIViewController *leftController;
@property (nonatomic, strong) UIViewController *rightController;
@property (nonatomic, strong) UIViewController *topController;
@property (nonatomic, strong) UIViewController *bottomController;
@property (nonatomic, strong) NSMutableDictionary *identifierCollection;
#else
@property (nonatomic, strong) CGPanelView *centerController;
@property (nonatomic, strong) CGPanelView *leftController;
@property (nonatomic, strong) CGPanelView *rightController;
@property (nonatomic, strong) CGPanelView *topController;
@property (nonatomic, strong) CGPanelView *bottomController;
@property (nonatomic, strong) NSMutableDictionary *viewCollection;
@property (nonatomic, strong) NSMutableDictionary *liveCollection;
@property (nonatomic, strong) NSString *nibIdentifier;
#endif

@property (nonatomic, strong) NSNumber *xCoordinate;
@property (nonatomic, strong) NSNumber *yCoordinate;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic, assign) int velocityCheck;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) BOOL showingTopPanel;
@property (nonatomic, assign) BOOL showingBottomPanel;
@property (nonatomic, assign) BOOL showPanelX;
@property (nonatomic, assign) BOOL showPanelY;
@property (nonatomic, assign) BOOL started;
-(void)setStartViewWithCoord:(int)theX andY:(int)theY;
@end

@implementation CGFlowController {
    struct {
        unsigned int startFlow:1;
        unsigned int endFlow:1;
    } delegateRespondsTo;
#ifdef STORYBOARD
    UIPanGestureRecognizer *_panGestureRecognizer;
#endif
}
@synthesize delegate;
@synthesize xMovement=_xMovement;
@synthesize yMovement=_yMovement;
@synthesize xWrapAround=_xWrapAround;
@synthesize yWrapAround=_yWrapAround;
@synthesize forceFinish=_forceFinish;

static dispatch_once_t onceToken;
static CGFlowController *sharedFlow = nil;

+(CGFlowController *)sharedFlow {
    dispatch_once(&onceToken, ^{
        sharedFlow = [[CGFlowController alloc] init];
    });
    
    return sharedFlow;
}

#ifndef STORYBOARD
-(id)init {
    self = [super init];
    if (self) {
        // Custom initialization
#ifndef STORYBOARD
        _viewCollection = [[NSMutableDictionary alloc] init];
        _liveCollection = [[NSMutableDictionary alloc] init];
#else
        _identifierCollection = [[NSMutableDictionary alloc] init];
#endif
        _xWrapAround = false;
        _yWrapAround = false;
        _xMovement = true;
        _yMovement = true;
        _forceFinish = false;
    }
    return self;
}
#else
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
#ifndef STORYBOARD
        _viewCollection = [[NSMutableDictionary alloc] init];
        _liveCollection = [[NSMutableDictionary alloc] init];
#else
        dispatch_once(&onceToken, ^{
            sharedFlow = self;
        });
        _identifierCollection = [[NSMutableDictionary alloc] init];
        
#endif
        _xWrapAround = false;
        _yWrapAround = false;
        _xMovement = true;
        _yMovement = true;
        _forceFinish = false;
    }
    return self;
}
#endif

#pragma mark - Initialization Methods

- (void)setDelegate:(id <CGFlowControllerDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        delegateRespondsTo.startFlow = [delegate respondsToSelector:@selector(startFlowTransition:)];
        delegateRespondsTo.endFlow = [delegate respondsToSelector:@selector(endFlowTransition:)];
    }
}

#ifndef STORYBOARD
-(void)setNibIdentifier:(NSString *)ident {
    _nibIdentifier = ident;
}
#endif

-(void)setStartViewWithCoord:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        _xCoordinate = [NSNumber numberWithInt:theX];
        _yCoordinate = [NSNumber numberWithInt:theY];
    }
}

#pragma mark - viewAppearence calls

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#ifdef STORYBOARD
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"CenterTestPanel" withCoordX:0 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"LeftTestPanel" withCoordX:-1 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"RightTestPanel" withCoordX:1 andY:0];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"TopTestPanel" withCoordX:0 andY:1];
    [[CGFlowController sharedFlow] addStoryBoardIdentifier:@"BottomTestPanel" withCoordX:0 andY:-1];
#endif
    [self setStartViewWithCoord:0 andY:0];
    self.started = false;
    _velocityCheck = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.started) {
        self.started = true;
        [self determineNewViews:0 and:0];
        
#ifdef STORYBOARD
        [self resetMainView:animated];
#else
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
#endif
    }
#ifndef STORYBOARD
    [_centerController viewWillAppearCall:animated];
#endif
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifndef STORYBOARD
    [_centerController viewDidAppearCall:animated];
#endif
}

-(void)viewWillDisappear:(BOOL)animated {
#ifndef STORYBOARD
    [_centerController viewWillDisappearCall:animated];
#endif
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
#ifndef STORYBOARD
    [_centerController viewDidDisappearCall:animated];
#endif
    [super viewDidDisappear:animated];
}

#pragma mark - Flow Builder Methods

#ifdef STORYBOARD

-(void)addStoryBoardIdentifier:(NSString *)ident withCoordX:(int)theX andY:(int)theY {
    [_identifierCollection setValue:ident forKey:[NSString stringWithFormat:@"%d,%d", theX, theY]];
}

#else

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

#endif

#pragma Flow Movement Methods

-(void)moveCustomPathToX:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        _xCoordinate = [NSNumber numberWithInt:theX];
        _yCoordinate = [NSNumber numberWithInt:theY];
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [self determineNewViews:0 and:0];
            [self resetMainView:NO];
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    [self determineNewViews:theX and:theY];
                    [self resetMainView:NO];
                } completion:^(BOOL finished){
                    if (finished) {
                        [self.parentViewController viewWillAppear:NO];
#ifdef STORYBOARD
                        [self.centerController viewWillAppear:NO];
#else
                        [self.centerController viewWillAppearCall:NO];
#endif
                    }
                }];
            }
        }];
    }
}

#pragma mark - Flow Parsing Methods

-(id)getViewAtCoordX:(int)theX andY:(int)theY {
    if ([self viewExistsAtCoordX:theX andY:theY]) {
        NSString *newIdentifier = [NSString stringWithFormat:@"%d,%d", theX, theY];
#ifndef STORYBOARD
        if ([_liveCollection valueForKey:newIdentifier] != nil) {
            return [_liveCollection valueForKey:newIdentifier];
        }
        
        NSMutableArray *classArray = [_viewCollection valueForKey:newIdentifier];
        Class type = [classArray objectAtIndex:0];
        __strong __typeof__(type) classController = classController = [[type alloc] initWithNibName:[NSString stringWithFormat:@"%@%@", NSStringFromClass(type), _nibIdentifier] bundle:nil];
        
        return classController;
#else
        return [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:[_identifierCollection valueForKey:newIdentifier]];
#endif
    }
    return nil;
}

-(BOOL)viewExistsAtCoordX:(int)theX andY:(int)theY {
    NSString *newIdentifier = [NSString stringWithFormat:@"%d,%d", theX, theY];
#ifndef STORYBOARD
    if ([_liveCollection valueForKey:newIdentifier] != nil) {
        return YES;
    } else if ([_viewCollection valueForKey:newIdentifier] != nil) {
        return YES;
    }
#else
    if ([_identifierCollection valueForKey:newIdentifier] != nil) {
        return YES;
    }
#endif
    return NO;
}

#pragma mark - Flow Information Methods

-(BOOL)viewHasLeft:(UIViewController *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:(viewCoords.x - 1) andY:viewCoords.y];
}

-(BOOL)viewHasRight:(UIViewController *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:(viewCoords.x + 1) andY:viewCoords.y];
}

-(BOOL)viewHasTop:(UIViewController *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:viewCoords.x andY:(viewCoords.y + 1)];
}

-(BOOL)viewHasBottom:(UIViewController *)view {
    CGPoint viewCoords = [self getCoordsForLoadedView:view];
    return [self viewExistsAtCoordX:viewCoords.x andY:(viewCoords.y - 1)];
}

#pragma mark - Flow Search Methods

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

-(CGPoint)getCurrentViewPosition {
    return CGPointMake([_xCoordinate floatValue], [_yCoordinate floatValue]);
}

/*
-(CGPoint)getCoordsForView:(CGPanelView *)view {
    NSString *coords = @"";
    for (NSString *aKey in [_liveCollection allKeys]) {
        if ([[_liveCollection objectForKey:aKey] isEqual:view]) {
            NSLog(@"View Exists In Live Collection");
            coords = aKey;
            break;
        }
    }
    
    for (NSString *aKey in [_viewCollection allKeys]) {
        if ([[_viewCollection objectForKey:aKey] isEqual:view]) {
            NSLog(@"View Exists In View Collection");
            coords = aKey;
            break;
        }
    }
    
    if ([coords isEqualToString:@""]) {
        return CGPointZero;
    }
    
//    NSArray *coordComp = [coords ]
    
    return CGPointZero;
}*/

-(CGPoint)getCoordsForLoadedView:(CGPanelView *)view {
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

#pragma mark - Specific controller helper methods

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

#ifdef STORYBOARD
#pragma mark - Pan Gesture Recognizer singleton

-(UIPanGestureRecognizer*)panGestureRecognizer {
    if (_panGestureRecognizer == nil) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        panRecognizer.delegate = self;
        _panGestureRecognizer = panRecognizer;
        panRecognizer = nil;
    }
    
    return _panGestureRecognizer;
}
#endif

#pragma mark - Panel movement code

-(void)movePanelToOriginalPosition:(BOOL)animated {
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self resetMainView:animated];
        }
    }];
}

-(void)movePanelLeft:(BOOL)animated {
    if (_xMovement) {
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
            _rightController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
#ifndef STORYBOARD
                [_rightController viewDidAppearCall:animated];
                [_centerController viewDidDisappearCall:animated];
#else
                [_rightController viewDidAppear:animated];
                [_centerController viewDidDisappear:animated];
#endif
                [self determineNewViews:1 and:0];
                [self resetMainView:animated];
            }
        }];
    }
}

-(void)movePanelRight:(BOOL)animated {
    if (_xMovement) {
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _leftController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _centerController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
#ifndef STORYBOARD
                [_leftController viewDidAppearCall:animated];
                [_centerController viewDidDisappearCall:animated];
#else
                [_leftController viewDidAppear:animated];
                [_centerController viewDidDisappear:animated];
#endif
                [self determineNewViews:-1 and:0];
                [self resetMainView:YES];
            }
        }];
    }
}

-(void)movePanelUp:(BOOL)animated {
    if (_yMovement) {
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            _bottomController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
#ifndef STORYBOARD
                [_bottomController viewDidAppearCall:animated];
                [_centerController viewDidDisappearCall:animated];
#else
                [_bottomController viewDidAppear:animated];
                [_centerController viewDidDisappear:animated];
#endif
                [self determineNewViews:0 and:-1];
                [self resetMainView:YES];
            }
        }];
    }
}

-(void)movePanelDown:(BOOL)animated {
    if (_yMovement) {
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            _topController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
#ifndef STORYBOARD
                [_topController viewDidAppearCall:animated];
                [_centerController viewDidDisappearCall:animated];
#else
                [_topController viewDidAppear:animated];
                [_centerController viewDidDisappear:animated];
#endif
                [self determineNewViews:0 and:1];
                [self resetMainView:YES];
            }
        }];
    }
}

#pragma mark - View determination and finalizer methods

-(void)determineNewViews:(int)dirRightLeft and:(int)dirUpDown {
    // dirRightLeft: -1 - left, 0 - Neutral, 1 - right
    // dirUpDown: -1 - Down, 0 - no change, 1 - up
    int newX = ([_xCoordinate intValue] + dirRightLeft);
    int newY = ([_yCoordinate intValue] + dirUpDown);
    
    if ([self viewExistsAtCoordX:newX andY:newY]) {
        // Set Center
        // By setting the center in this manner the Center view isn't reloaded
        // This allows custom firing of our own panel loading to force viewWillAppear,
        // viewDidAppear and its disappearing counterparts to fire when we want.
        UIView *tempView = _centerController.view;
        if (dirRightLeft != 0) {
            if (dirRightLeft > 0) {
                _centerController = _rightController;
            } else {
                _centerController = _leftController;
            }
        } else if (dirUpDown != 0) {
            if (dirUpDown > 0) {
                _centerController = _topController;
            } else {
                _centerController = _bottomController;
            }
        } else {
            _centerController = [self getViewAtCoordX:newX andY:newY];
        }
        
        [self.view bringSubviewToFront:_centerController.view];
        [_leftController.view removeFromSuperview];
        [_rightController.view removeFromSuperview];
        [_topController.view removeFromSuperview];
        [_bottomController.view removeFromSuperview];
        
        _leftController = [self getViewAtCoordX:(newX - 1) andY:newY];
        _rightController = [self getViewAtCoordX:(newX + 1) andY:newY];
        _topController = [self getViewAtCoordX:newX andY:(newY + 1)];
        _bottomController = [self getViewAtCoordX:newX andY:(newY - 1)];
        
        _xCoordinate = [NSNumber numberWithInt:newX];
        _yCoordinate = [NSNumber numberWithInt:newY];
        
#ifdef STORYBOARD
        [_centerController.view addGestureRecognizer:[self panGestureRecognizer]];
#else
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
#endif
        
        // This fixes a memory leak where the view being overwritten by centercontroller
        // is never removed from the superview which is a strong reference.
        if (tempView != nil) {
#ifdef STORYBOARD
            [tempView removeGestureRecognizer:[self panGestureRecognizer]];
#endif
            [tempView removeFromSuperview];
            tempView = nil;
        }
    } else {
        [self movePanelToOriginalPosition:YES];
    }
}

-(void)resetMainView:(BOOL)animated {
    self.showingLeftPanel = NO;
    self.showingRightPanel = NO;
    self.showingTopPanel = NO;
    self.showingBottomPanel = NO;
    
    if (_centerController != nil && [_centerController.view superview] == nil) {
        [self.view addSubview:_centerController.view];
        [self.view bringSubviewToFront:_centerController.view];
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
    
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _bottomController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _leftController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _centerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _rightController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        _topController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            if (delegateRespondsTo.endFlow) {
                [delegate endFlowTransition:animated];
            }
        }
    }];
}

#pragma mark - Non pan gesture movement delegate

-(void)showLeftController {
    if ([self hasLeftController]) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _xMovement = YES;
        _yMovement = NO;
#ifndef STORYBOARD
        [_centerController viewWillDisappearCall:YES];
        [_leftController viewWillAppearCall:YES];
#else
        [_centerController viewWillDisappear:YES];
        [_leftController viewWillAppear:YES];
#endif
        [self movePanelRight:YES];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showRightController {
    if ([self hasRightController]) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _xMovement = YES;
        _yMovement = NO;
#ifndef STORYBOARD
        [_centerController viewWillDisappearCall:YES];
        [_rightController viewWillAppearCall:YES];
#else
        [_centerController viewWillDisappear:YES];
        [_rightController viewWillAppear:YES];
#endif
        [self movePanelLeft:YES];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showTopController {
    if ([self hasTopController]) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _yMovement = YES;
        _xMovement = NO;
#ifndef STORYBOARD
        [_centerController viewWillDisappearCall:YES];
        [_topController viewWillAppearCall:YES];
#else
        [_centerController viewWillDisappear:YES];
        [_topController viewWillAppear:YES];
#endif
        [self movePanelDown:YES];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

-(void)showBottomController {
    if ([self hasBottomController]) {
        BOOL xCheck = _xMovement;
        BOOL yCheck = _yMovement;
        
        _yMovement = YES;
        _xMovement = NO;
#ifndef STORYBOARD
        [_centerController viewWillDisappearCall:YES];
        [_bottomController viewWillAppearCall:YES];
#else
        [_centerController viewWillDisappear:YES];
        [_bottomController viewWillAppear:YES];
#endif
        [self movePanelUp:YES];
        _xMovement = xCheck;
        _yMovement = yCheck;
    }
}

#pragma mark - Pan Gesture Delegate

-(void)movePanel:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if (_forceFinish) {
        if (_velocityCheck == 1 && _xMovement) {
            if (!_showPanelX) {
                [self movePanelToOriginalPosition:YES];
            } else {
                if (_showingLeftPanel) {
                    [self movePanelRight:YES];
                }  else if (_showingRightPanel) {
                    [self movePanelLeft:YES];
                }
            }
        } else if (_velocityCheck == 2 && _yMovement) {
            if (!_showPanelY) {
                [self movePanelToOriginalPosition:YES];
            } else {
                if (_showingBottomPanel) {
                    [self movePanelUp:YES];
                }  else if (_showingTopPanel) {
                    [self movePanelDown:YES];
                }
            }
        }
        
        _velocityCheck = 0;
        _forceFinish = false;
    } else {
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            UIView *childView = nil;
            if (delegateRespondsTo.startFlow) {
                [delegate startFlowTransition:YES];
            }
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
#ifndef STORYBOARD
                        [_centerController viewWillDisappearCall:YES];
                        [_leftController viewWillAppearCall:YES];
#else
                        [_centerController viewWillDisappear:YES];
                        [_leftController viewWillAppear:YES];
#endif
                        childView = [self getLeftViewController].view;
                    }
                } else {
                    if (!_showingLeftPanel) {
#ifndef STORYBOARD
                        [_centerController viewWillDisappearCall:YES];
                        [_rightController viewWillAppearCall:YES];
#else
                        [_centerController viewWillDisappear:YES];
                        [_rightController viewWillAppear:YES];
#endif
                        childView = [self getRightViewController].view;
                    }
                }
            } else if (_velocityCheck == 2 && _yMovement) {
                if(velocity.y > 0) {
                    if (!_showingBottomPanel) {
#ifndef STORYBOARD
                        [_centerController viewWillDisappearCall:YES];
                        [_topController viewWillAppearCall:YES];
#else
                        [_centerController viewWillDisappear:YES];
                        [_topController viewWillAppear:YES];
#endif
                        childView = [self getTopViewController].view;
                    }
                } else {
                    if (!_showingTopPanel) {
#ifndef STORYBOARD
                        [_centerController viewWillDisappearCall:YES];
                        [_bottomController viewWillAppearCall:YES];
#else
                        [_centerController viewWillDisappear:YES];
                        [_bottomController viewWillAppear:YES];
#endif
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
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            if (_velocityCheck == 1 && _xMovement) {
                if (!_showPanelX) {
                    [self movePanelToOriginalPosition:YES];
                } else {
                    if (_showingLeftPanel) {
                        [self movePanelRight:YES];
                    }  else if (_showingRightPanel) {
                        [self movePanelLeft:YES];
                    }
                }
            } else if (_velocityCheck == 2 && _yMovement) {
                if (!_showPanelY) {
                    [self movePanelToOriginalPosition:YES];
                } else {
                    if (_showingBottomPanel) {
                        [self movePanelUp:YES];
                    }  else if (_showingTopPanel) {
                        [self movePanelDown:YES];
                    }
                }
            }
            
            _velocityCheck = 0;
        }
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
            if (_velocityCheck == 1 && _xMovement) {
                // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
                _showPanelX = abs([sender view].center.x - [sender view].frame.size.width / 2) > (([sender view].frame.size.width / 2) * PER_COMPLETE_SLIDE_X);
                
                if (_leftController != nil && _rightController != nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if (!((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) > (self.view.frame.size.width / 2) || (_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) < (self.view.frame.size.width / 2))) {
                        _leftController.view.center = CGPointMake(_leftController.view.center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO_X), _leftController.view.center.y);
                        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO_X), [sender view].center.y);
                        _rightController.view.center = CGPointMake(_rightController.view.center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO_X), _rightController.view.center.y);
                    } else if ((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) > (self.view.frame.size.width / 2)) {
                        _leftController.view.center = CGPointMake((self.view.frame.size.width / 2), _leftController.view.center.y);
                        [sender view].center = CGPointMake((self.view.frame.size.width + (self.view.frame.size.width / 2)), [sender view].center.y);
                        _rightController.view.center = CGPointMake(((2 * self.view.frame.size.width) + (self.view.frame.size.width / 2)), _rightController.view.center.y);
                    } else if ((_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) < (self.view.frame.size.width / 2)) {
                        _leftController.view.center = CGPointMake(-(self.view.frame.size.width + (self.view.frame.size.width / 2)), _leftController.view.center.y);
                        [sender view].center = CGPointMake(-(self.view.frame.size.width / 2), [sender view].center.y);
                        _rightController.view.center = CGPointMake((self.view.frame.size.width / 2), _rightController.view.center.y);
                    }
                } else if (_leftController == nil && _rightController == nil) { } else if (_leftController == nil) {
                    // allow dragging only in x coordinates by only updating the x coordinate with translation position
                    if ((([sender view].center.x <= (self.view.frame.size.width / 2)) && velocity.x < 0) || (([sender view].center.x < (self.view.frame.size.width / 2)) && velocity.x > 0)) {
                        if ((_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) <= self.view.center.x) {
                            _rightController.view.center = CGPointMake(self.view.center.x, _rightController.view.center.y);
                            [sender view].center = CGPointMake((self.view.center.x - self.view.frame.size.width), [sender view].center.y);
                        } else {
                            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X), [sender view].center.y);
                            _rightController.view.center = CGPointMake(_rightController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X), _rightController.view.center.y);
                        }
                    } else {
                        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y);
                        _rightController.view.center = CGPointMake(_rightController.view.center.x, _rightController.view.center.y);
                    }
                } else if (_rightController == nil) {
                    if (([sender view].center.x >= (self.view.frame.size.width / 2) && velocity.x > 0) || ([sender view].center.x > (self.view.frame.size.width / 2) && velocity.x < 0)) {
                        if ((_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X)) >= self.view.center.x) {
                            _leftController.view.center = CGPointMake(self.view.center.x, _leftController.view.center.y);
                            [sender view].center = CGPointMake((self.view.center.x + self.view.frame.size.width), [sender view].center.y);
                        } else {
                            _leftController.view.center = CGPointMake(_leftController.view.center.x + translatedPoint.x + ((double)velocity.x * ACCELERATED_SWIPE_RATIO_X), _leftController.view.center.y);
                            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x + (((double)velocity.x) * ACCELERATED_SWIPE_RATIO_X), [sender view].center.y);
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
                    if (!((_bottomController.view.center.y + translatedPoint.y + ((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y) < (self.view.frame.size.height / 2) || (_topController.view.center.y + translatedPoint.y + ((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y) > (self.view.frame.size.height / 2))) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, _bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                        _topController.view.center = CGPointMake(_topController.view.center.x, _topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                    } else if ((_bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y)) < (self.view.frame.size.height / 2)) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, (self.view.frame.size.height / 2));
                        [sender view].center = CGPointMake([sender view].center.x, -(self.view.frame.size.height / 2));
                        _topController.view.center = CGPointMake(_topController.view.center.x, -(self.view.frame.size.height + (self.view.frame.size.height / 2)));
                    } else if ((_topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y)) > (self.view.frame.size.height / 2)) {
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
                        if ((_topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y)) >= self.view.center.y) {
                            [sender view].center = CGPointMake([sender view].center.x, (self.view.center.y + self.view.frame.size.height));
                            _topController.view.center = CGPointMake(_topController.view.center.x, self.view.center.y);
                        } else {
                            [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                            _topController.view.center = CGPointMake(_topController.view.center.x, _topController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                        }
                    }
                } else if (_topController == nil) {
                    if (([sender view].center.y >= (self.view.frame.size.height / 2) && velocity.y > 0) || ([sender view].center.y > (self.view.frame.size.height / 2) && velocity.y < 0)) {
                        _bottomController.view.center = CGPointMake(_bottomController.view.center.x, (self.view.frame.size.height + (self.view.frame.size.height / 2)));
                        [sender view].center = CGPointMake([sender view].center.x, (self.view.frame.size.height / 2));
                    } else {
                        if ((_bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y)) <= self.view.center.y) {
                            [sender view].center = CGPointMake([sender view].center.x, (self.view.center.y - self.view.frame.size.height));
                            _bottomController.view.center = CGPointMake(_bottomController.view.center.x, self.view.center.y);
                        } else {
                            _bottomController.view.center = CGPointMake(_bottomController.view.center.x, _bottomController.view.center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                            [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y + (((double)velocity.y) * ACCELERATED_SWIPE_RATIO_Y));
                        }
                    }
                }
                
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
                _preVelocity = velocity;
            }
        }
    }
}

#pragma mark - Memory Delegate

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#pragma mark - UIViewController(CGFlowController) Category

@implementation UIViewController(CGFlowController)

-(CGFlowController *)flowController {
    UIViewController *parent = self;
    Class flowClass = [CGFlowController class];
    while (nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:flowClass]) {}

    return (id)parent;
}

@end

#pragma mark - CGFlowControllerSegue Class

@implementation CGFlowControllerSegue

-(void)perform {
    if (_performBlock != nil) {
        _performBlock( self, self.sourceViewController, self.destinationViewController );
    }
}

@end

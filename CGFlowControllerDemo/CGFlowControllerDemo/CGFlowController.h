//
//  CGFlowViewController.h
//
//  Created by Chase (Charles) Gorectke on 7/24/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//


#import <UIKit/UIKit.h>
#import "CGPanelView.h"

@protocol CGFlowControllerDelegate <NSObject>
@optional
-(void)startFlowTransition:(BOOL)animated;
-(void)endFlowTransition:(BOOL)animated;
@end

@interface CGFlowController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <CGFlowControllerDelegate> delegate;
@property (nonatomic, assign) BOOL xMovement;
@property (nonatomic, assign) BOOL yMovement;
@property (nonatomic, assign) BOOL xWrapAround;
@property (nonatomic, assign) BOOL yWrapAround;
@property (nonatomic, assign) BOOL forceFinish;

+(CGFlowController *)sharedFlow;
-(void)setDelegate:(id<CGFlowControllerDelegate>)delegate;

#ifndef STORYBOARD
-(void)setNibIdentifier:(NSString *)ident;
#endif

#ifdef STORYBOARD
-(void)addStoryBoardIdentifier:(NSString *)ident withCoordX:(int)theX andY:(int)theY;
#else
-(void)addNonLiveView:(Class)theClass withCoordX:(int)theX andY:(int)theY;
-(void)addLiveView:(UIViewController *)view withCoordX:(int)theX andY:(int)theY;
#endif

-(void)moveCustomPathToX:(int)theX andY:(int)theY;
-(NSString *)whichViewAmI:(UIViewController *)view;
-(CGPoint)getCurrentViewPosition;
-(CGPoint)getCoordsForLoadedView:(UIViewController *)view;

-(BOOL)viewHasLeft:(UIViewController *)view;
-(BOOL)viewHasRight:(UIViewController *)view;
-(BOOL)viewHasTop:(UIViewController *)view;
-(BOOL)viewHasBottom:(UIViewController *)view;

-(BOOL)hasLeftController;
-(BOOL)hasRightController;
-(BOOL)hasTopController;
-(BOOL)hasBottomController;

-(UIViewController *)getLeftViewController;
-(UIViewController *)getRightViewController;
-(UIViewController *)getTopViewController;
-(UIViewController *)getBottomViewController;

#ifdef STORYBOARD
-(UIPanGestureRecognizer*)panGestureRecognizer;
#endif

-(void)showLeftController;
-(void)showRightController;
-(void)showTopController;
-(void)showBottomController;

@end

#pragma mark - UIViewController(CGFlowController) Category

// We add a category of UIViewController to let childViewControllers easily access their parent CGFlowController
@interface UIViewController(CGFlowController)
-(CGFlowController *)flowController;
@end

#pragma mark - CGFlowControllerSegue

@interface CGFlowControllerSegue : UIStoryboardSegue
@property (strong) void(^performBlock)(CGFlowControllerSegue * segue, UIViewController* svc, UIViewController* dvc );
@end

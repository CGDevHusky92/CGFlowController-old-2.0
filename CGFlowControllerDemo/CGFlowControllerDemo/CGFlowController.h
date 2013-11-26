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
-(void)setNibIdentifier:(NSString *)ident;

-(void)addNonLiveView:(Class)theClass withCoordX:(int)theX andY:(int)theY;
-(void)addLiveView:(CGPanelView *)view withCoordX:(int)theX andY:(int)theY;

-(void)moveCustomPathToX:(int)theX andY:(int)theY;
-(NSString *)whichViewAmI:(CGPanelView *)view;
-(CGPoint)getCurrentViewPosition;
-(CGPoint)getCoordsForLoadedView:(CGPanelView *)view;

-(BOOL)viewHasLeft:(CGPanelView *)view;
-(BOOL)viewHasRight:(CGPanelView *)view;
-(BOOL)viewHasTop:(CGPanelView *)view;
-(BOOL)viewHasBottom:(CGPanelView *)view;

-(BOOL)hasLeftController;
-(BOOL)hasRightController;
-(BOOL)hasTopController;
-(BOOL)hasBottomController;

-(CGPanelView *)getLeftViewController;
-(CGPanelView *)getRightViewController;
-(CGPanelView *)getTopViewController;
-(CGPanelView *)getBottomViewController;

-(void)showLeftController;
-(void)showRightController;
-(void)showTopController;
-(void)showBottomController;
@end

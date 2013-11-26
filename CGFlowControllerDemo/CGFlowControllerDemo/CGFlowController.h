//
//  CGFlowViewController.h
//  ThisOrThat
//
//  Created by Charles (Chase) Gorectke on 7/24/13.
//  Copyright Revision Works 2013
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
-(void)addNonLiveView:(Class)theClass withCoordX:(int)theX andY:(int)theY;
-(void)addLiveView:(CGPanelView *)view withCoordX:(int)theX andY:(int)theY;
-(void)moveCustomPathToX:(int)theX andY:(int)theY;

-(BOOL)hasLeftController;
-(BOOL)hasRightController;
-(BOOL)hasTopController;
-(BOOL)hasBottomController;

-(void)showLeftController;
-(void)showRightController;
-(void)showTopController;
-(void)showBottomController;

-(UIViewController *)getLeftViewController;
-(UIViewController *)getRightViewController;
-(UIViewController *)getTopViewController;
-(UIViewController *)getBottomViewController;

-(void)setNibIdentifier:(NSString *)ident;
-(CGPoint)getCurrentView;
-(NSString *)whichViewAmI:(CGPanelView *)view;

-(CGPoint)getCoordsForLoadedView:(CGPanelView *)view;
-(BOOL)viewHasLeft:(CGPanelView *)view;
-(BOOL)viewHasRight:(CGPanelView *)view;
-(BOOL)viewHasTop:(CGPanelView *)view;
-(BOOL)viewHasBottom:(CGPanelView *)view;
@end

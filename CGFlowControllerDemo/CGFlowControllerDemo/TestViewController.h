//
//  TestViewController.h
//  CGFlowControllerDemo
//
//  Created by Chase (Charles) Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//

#import <UIKit/UIKit.h>
#import "CGPanelView.h"

//@class CGFlowViewController;

@interface TestViewController : CGPanelView

#if LIVE_VIEWS
-(id)initWithNib:(NSString *)nibNameOrNil withName:(NSString *)name andCoordX:(int)xCoord andY:(int)yCoord;
#endif

-(IBAction)upPressed:(id)sender;
-(IBAction)downPressed:(id)sender;
-(IBAction)leftPressed:(id)sender;
-(IBAction)rightPressed:(id)sender;

@end

//
//  TestViewController.h
//  FlowControllerTest
//
//  Created by Chase Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
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

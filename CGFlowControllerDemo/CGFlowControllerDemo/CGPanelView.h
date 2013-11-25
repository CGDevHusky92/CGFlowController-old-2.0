//
//  CGPanelView.h
//  FlowControllerTest
//
//  Created by Chase Gorectke on 11/22/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGPanelView : UIViewController
@property (atomic) BOOL allowAppearenceCalls;
+(void)viewWillAppear:(BOOL)animated;
@end

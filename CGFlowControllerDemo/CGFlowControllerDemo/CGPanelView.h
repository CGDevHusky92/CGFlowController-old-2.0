//
//  CGPanelView.h
//
//  Created by Chase (Charles) Gorectke on 11/22/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//

#import <UIKit/UIKit.h>

@interface CGPanelView : UIViewController
@property (atomic) BOOL allowAppearenceCalls;
-(void)viewWillAppearCall:(BOOL)animated;
-(void)viewDidAppearCall:(BOOL)animated;
-(void)viewWillDisappearCall:(BOOL)animated;
-(void)viewDidDisappearCall:(BOOL)animated;
@end

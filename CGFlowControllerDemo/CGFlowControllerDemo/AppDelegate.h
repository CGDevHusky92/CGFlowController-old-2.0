//
//  AppDelegate.h
//  CGFlowControllerDemo
//
//  Created by Chase (Charles) Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//  Engineering A Better World
//

#import <UIKit/UIKit.h>

#ifndef STORYBOARD
@class MainViewController;
#endif
@interface AppDelegate : UIResponder <UIApplicationDelegate>
#ifdef STORYBOARD
@property (strong, nonatomic) UIWindow *window;
#else
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *viewController;
#endif
@end

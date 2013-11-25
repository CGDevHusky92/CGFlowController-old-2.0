//
//  AppDelegate.h
//  FlowControllerTest
//
//  Created by Chase Gorectke on 9/20/13.
//  Copyright (c) 2013 Revision Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *viewController;
@end

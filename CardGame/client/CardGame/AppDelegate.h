//
//  AppDelegate.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "Globals.h"
#import "StartupModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) ViewController *loginViewController;

@property (nonatomic, strong) ViewController *homeViewController;

@property (nonatomic, strong) ViewController *serverErrorController;

@property (strong) StartupModel * startUp;

@end
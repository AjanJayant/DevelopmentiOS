//
//  AppDelegate.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize loginViewController;

@synthesize homeViewController;

@synthesize serverErrorController;

@synthesize startUp;

UIStoryboard *mainStoryboard;

NSTimer * autoTimer;

/**********************************************************
 * didFinishLaunchingWithOptions is the first function loaded.
 * All setup work done here, including the inital PubNub 
 * connect. Note it is vital that the connect be done here,
 * otherwise function will fail.
 ***********************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Variables, storyboard Loading Setup
    
    [[Globals sharedInstance] loadVariables];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    
    BOOL loginIsLoadedAsInitialController = NO;;
    if([[[Globals sharedInstance] udid] isEqualToString: @""]) {
        
        [self loadLoginAsInitialController];
        loginIsLoadedAsInitialController = YES;
    }
    
    // pubNub Setup
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:@"mySecret"]];
    [PubNub connect];
    [PubNub setClientIdentifier: [[Globals sharedInstance] udid]];
    PNChannel *channel_self = [PNChannel channelWithName: [[Globals sharedInstance] udid]];
    [PubNub subscribeOnChannel: channel_self];

    // Startup Setup, if login is not ascertained as inital controller
    if(loginIsLoadedAsInitialController == NO){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotLoaded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ascertainFirstController) name:@"serverRestarted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ascertainFirstController) name:@"serverLoaded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startObservingForServerErrorsAgain) name:@"startObservingForServerErrorsAgain" object:nil];
        autoTimer = [NSTimer scheduledTimerWithTimeInterval:(10.0)
                                                 target:self
                                               selector:@selector(checkIfServerRunning)
                                               userInfo:nil
                                                repeats:YES];

        startUp = [[StartupModel alloc] init];
    }
    
    return YES;
}

/**********************************************************
 * checkIfServerRunning checks if the server is running
 ***********************************************************/
- (void)checkIfServerRunning
{
    
    [[Globals sharedInstance] checkIfHereNow];
}

/**********************************************************
 * ascertainFirstController loads a view controller if it 
 * easily distinguishable, otherwise login or home are loaded.
 ***********************************************************/
- (void)ascertainFirstController
{
    
    NSString * first = [startUp findFirstController];
        
    if([first isEqualToString: @"login"]) {
        
        [self loadLoginAsInitialController];
    }
    else if([first isEqualToString: @"unsure"]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLoginAsInitialController) name:@"loadLoginAsInitialController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHomeAsInitialController) name:@"loadHomeAsInitialController" object:nil];
    }
}

/**********************************************************
 * loadLoginAsInitialController loads login as the first view 
 * controller.
 ***********************************************************/
- (void)loadLoginAsInitialController
{

    loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"login"];
    self.window.rootViewController = loginViewController;
    
    [self.window makeKeyAndVisible];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadLoginAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverNotLoaded" object:nil];
}

/**********************************************************
 * loadHomeAsInitialController loads home as the first view
 * controller.
 ***********************************************************/
- (void)loadHomeAsInitialController
{
    
    homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"home"];
    self.window.rootViewController = homeViewController;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadHomeAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverNotLoaded" object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Auxilliary Functions

/**********************************************************
 * goToServerError loads server eror as the first view controller
 ***********************************************************/
- (void)goToServerError
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverNotLoaded" object:nil];
    
    serverErrorController = [mainStoryboard instantiateViewControllerWithIdentifier:@"serverError"];

    [self.window addSubview:serverErrorController.view];
}
- (void)startObservingForServerErrorsAgain
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotLoaded" object:nil];

}

@end

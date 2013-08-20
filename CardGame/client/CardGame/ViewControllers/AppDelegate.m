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

NSString * reqUUID;

BOOL shouldGoToHome;

UIAlertView * endAlert;

NSTimer * autoTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Variables, storyboard Loading Setup
    
    //[[Globals sharedInstance] loadVariables];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    
    if([[[Globals sharedInstance] udid] isEqualToString: @""]) {
        
        [self loadLoginAsInitialController];
    }
    
    // pubNub Setup
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:@"mySecret"]];
    [PubNub connect];
    [PubNub setClientIdentifier: [[Globals sharedInstance] udid]];
    PNChannel *channel_self = [PNChannel channelWithName: [[Globals sharedInstance] udid]];
    [PubNub subscribeOnChannel: channel_self];

    // Startup Setup
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ascertainFirstController) name:@"serverRestarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ascertainFirstController) name:@"serverLoaded" object:nil];

    autoTimer = [NSTimer scheduledTimerWithTimeInterval:(10.0)
                                                 target:self
                                               selector:@selector(checkIfServerRunning)
                                               userInfo:nil
                                                repeats:YES];

    startUp = [[StartupModel alloc] init];
    
    return YES;
}

-(void) checkIfServerRunning{
    
    [[Globals sharedInstance] checkIfHereNow];
}

-(void) ascertainFirstController{
    
    NSString * first = [startUp findFirstController];
        
    if([first isEqualToString: @"login"]) {
        [self loadLoginAsInitialController];
    }
    else if([first isEqualToString: @"unsure"]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLoginAsInitialController) name:@"loadLoginAsInitialController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHomeAsInitialController) name:@"loadHomeAsInitialController" object:nil];
    }
}

- (void) loadLoginAsInitialController{

    loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"login"];
    self.window.rootViewController = loginViewController;
    
    [self.window makeKeyAndVisible];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadLoginAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];
}

- (void) loadHomeAsInitialController{
    
    homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"home"];
    self.window.rootViewController = homeViewController;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadHomeAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];
}

-(void) handleException: (NSDictionary *) dict {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server Exception Occoured" message: @"Game will exit shortly" delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alert show];
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

// Auxilliary Functions

-(void) goToServerError{
    
    serverErrorController = [mainStoryboard instantiateViewControllerWithIdentifier:@"serverError"];

    [self.window addSubview:serverErrorController.view];
}

@end

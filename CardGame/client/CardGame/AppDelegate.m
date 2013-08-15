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

@synthesize loadViewController;

@synthesize roomViewController;

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
    
    // AppDelegate setup
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Variables, storyboard Loading Setup
    
    [[Globals sharedInstance] loadVariables];
    shouldGoToHome = YES;
    mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHome) name:@"goToHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLoad) name:@"goToLoad" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:@"goToRoom" object:nil];


    autoTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0)
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
    
    [self.window addSubview:loginViewController.view];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadLoginAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];

}

- (void) loadHomeAsInitialController{
    
    homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"home"];
    self.window.rootViewController = homeViewController;
    
    [self.window addSubview:loginViewController.view];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadHomeAsInitialController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverLoaded" object:nil];

}
/*

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    NSString * type = [message.message objectForKey: @"type"];
    
    if([type isEqualToString: @"create-user"])
        [self handleCreateUser: message.message];
    else if([type isEqualToString: @"login"])
        [self handleLogin: message.message];
    else if([type isEqualToString: @"create"])
        [self handleCreate: message.message];
    else if([type isEqualToString: @"joinable"])
        [self handleJoinable: message.message];
    else if([type isEqualToString: @"player-join"])
        [self handlePlayerJoin: message.message];
    else if([type isEqualToString: @"authrequest"])
        [self handleAuthRequest: message.message];
    else if([type isEqualToString: @"authresponse"])
        [self handleAuthResponse: message.message];
    else if([type isEqualToString: @"start"])
        [self handleStart: message.message];
    else if([type isEqualToString: @"update"])
        [self handleUpdate: message.message];
    else if([type isEqualToString: @"take-turn"])
        [self handleTakeTurn: message.message];
    else if([type isEqualToString: @"end"])
        [self handleEnd: message.message];
    else if([type isEqualToString: @"exception"])
        [self handleException: message.message];
}

-(void) handleCreateUser: (NSDictionary *) dict {
    NSString * suc = [dict objectForKey: @"success"];
    NSString * name = [dict objectForKey:@"username"];
    
    if([suc isEqualToString: @"True"]){
        [[Globals sharedInstance] setUserName: name];
    }
    [self handleGenericLogin: dict];
}


-(void) handleLogin: (NSDictionary *) dict {
    [self handleGenericLogin: dict];
}

-(void) handleCreate: (NSDictionary *) dict {
    
    NSString * suc = [dict objectForKey: @"success"];
    NSString * mess = [dict objectForKey: @"message"];
    NSString * chanString = [dict objectForKey: @"channel"];

    if([suc isEqualToString: @"True"]){
        NSLog(@"This works");
        PNChannel * chan = [PNChannel channelWithName:chanString shouldObservePresence:YES];
        [[Globals sharedInstance] setGameChannel: chan];
        //[PubNub subscribeOnChannel: [[Globals sharedInstance] gameChannel]]
        
        loadViewController = [self goToLoad];

    }
    else if([suc isEqualToString: @"False"]){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game did not initialise" message: mess delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void) handleJoinable: (NSDictionary *) dict {
    
    NSString * suc = [dict objectForKey: @"success"];
    NSString * mess = [dict objectForKey: @"message"];
    NSString * chanString = [dict objectForKey: @"channel"];
    
    if([suc isEqualToString: @"True"]){
        PNChannel * chan = [PNChannel channelWithName:chanString shouldObservePresence:YES];
        [[Globals sharedInstance] setGameChannel: chan];
        
        loadViewController = [self goToLoad];
    }
    else if([suc isEqualToString: @"False"]){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Could not join" message: mess delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
        alert.tag = 2;
        [alert show];
    }
}

-(void) handlePlayerJoin: (NSDictionary *) dict {
    
    NSString * name = [dict objectForKey: @"usernames"];
    NSArray * list = [name componentsSeparatedByString:@","];
    NSArray * labelArray = [[NSArray alloc]initWithObjects:
                                                         loadViewController.firstNameLabel
                                                        ,loadViewController.secondNameLabel
                                                        ,loadViewController.thirdnameLabel
                                                        ,loadViewController.fourthNameLabel
                                                        ,loadViewController.fifthNameLabel
                                                        ,loadViewController.sixthNameLabel
                                                        ,loadViewController.seventhNameLabel
                                                        ,loadViewController.eightNameLabel
                                                        ,nil];

    
    int i = 0;
    for(id appelo in list){
        UILabel*  temp = labelArray[i];
        temp.hidden = NO;
        temp.text = appelo;
        
        if(i == 1 && [[Globals sharedInstance] isCreator]){
            [loadViewController setGameButton];
        }
        
        i++;
    }
}

-(void) handleAuthRequest: (NSDictionary *) dict {
    
    NSString * reqName = [dict objectForKey: @"requester-name"];
    reqUUID = [dict objectForKey: @"requester-uuid"];

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: [reqName stringByAppendingString: @" wants to join!"] message: @"You can choose to allow or deny them" delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Allow",  nil];
    alert.tag = 3;
    [alert show];
}

-(void) handleAuthResponse: (NSDictionary *) dict {
    
    NSString * auth = [dict objectForKey: @"auth"];
    NSString * creat = [dict objectForKey: @"creator"];
    
    UIAlertView * alert;
    if([auth isEqualToString: @"deny"]) {
        alert = [[UIAlertView alloc] initWithTitle: [creat stringByAppendingString: @" has denied you access"] message: @"Click below to escape" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        alert.tag = 4;

    }
    else if([auth isEqualToString: @"allow"]) {
        alert = [[UIAlertView alloc] initWithTitle: @"You succesfully joined!" message: @"Your game will start shortly"delegate:self cancelButtonTitle:@"Awesome!" otherButtonTitles: nil];
        alert.tag = 5;
    }
    [alert show];
}

-(void) handleStart: (NSDictionary *) dict {
    NSString * suc = [dict objectForKey: @"success"];
    NSString * card1 = [dict objectForKey: @"card1"];
    NSString * card2 = [dict objectForKey: @"card2"];
    NSString * blind = [dict objectForKey: @"blind"];
    NSString * initialFunds = [dict objectForKey: @"initial-funds"];

    if([suc isEqualToString: @"True"]){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
        ViewController* room = [mainStoryboard instantiateViewControllerWithIdentifier:@"room"];
            
        [self.window addSubview:room.view];
        [room setCards:card1 cardView:room.ownCardOneView];
        [room setCards:card2 cardView:room.ownCardTwoView];
        [room setInitialFunds: initialFunds];

        
        if([blind isEqualToString: @"smallblind"] ||  [blind isEqualToString: @"bigblind"]) {
            [room setBlind: blind];
            room.isBlind = YES;
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.roomViewController = room;
    }
    else if([suc isEqualToString: @"False"]){
        NSString * mess = [dict objectForKey: @"message"];
            
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game did not initialise :(" message: mess delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
            [alert show];
    }
}

-(void) handleUpdate: (NSDictionary *) dict {
    NSString * pot = [dict objectForKey: @"pot"];
    NSString * currBet = [dict objectForKey: @"current-bet"];
    NSString * lastAct = [dict objectForKey: @"last-act"];
    NSString * myFunds = [dict objectForKey: @"my-funds" ];
    NSString * comm = [dict objectForKey: @"community" ];

    [roomViewController setLabels:pot lastAct:lastAct myFunds:myFunds currentBet:currBet];
    
    if(![comm isEqualToString: @""]) {
        NSArray * list = [comm componentsSeparatedByString:@" "];
     
        [roomViewController setCards:list[0] cardView:roomViewController.deckCardOne];
        roomViewController.deckCardOne.hidden = NO;
        [roomViewController setCards:list[1] cardView:roomViewController.deckCard2];
        roomViewController.deckCard2.hidden = NO;
        [roomViewController setCards:list[2] cardView:roomViewController.deckCard3];
        roomViewController.deckCard3.hidden = NO;
        if([list count] > 3) {
            [roomViewController setCards:list[3] cardView:roomViewController.deckCard4];
            roomViewController.deckCard4.hidden = NO;

        }
        if([list count] > 4) {
            [roomViewController setCards:list[4] cardView:roomViewController.deckCard5];
            roomViewController.deckCard5.hidden = NO;
        }
    }
}

-(void) handleTakeTurn: (NSDictionary *) dict {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Your turn playa" message: @"It's now or never" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    
    NSString * minraise = [dict objectForKey: @"min-raise"];
    
    roomViewController.isBlind = NO;
    roomViewController.minRaise = [minraise intValue];
    
    [roomViewController removeBlind];
    roomViewController.raiseTextField.placeholder = [@"Min-raise:" stringByAppendingString: minraise];
    
    [roomViewController enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                                           roomViewController.raiseTextField,
                                                           roomViewController.raiseButton,
                                                           roomViewController.callButton,
                                                           roomViewController.foldButton,
                                                           nil]];
}

-(void) handleEnd: (NSDictionary *) dict {
    NSString * msg = [dict objectForKey: @"message"];
    
    shouldGoToHome = YES;
    endAlert = [[UIAlertView alloc] initWithTitle: msg message: @"Please choose wether to continue or weather to exit" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Continue", nil];
    endAlert.tag = 6;
    [endAlert show];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(goToHome)
                                   userInfo:nil
                                    repeats:NO];
}
*/

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

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if(alertView.tag == 1) {
        if(buttonIndex == 0){
            [homeViewController enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                                                    homeViewController.gameName,
                                                                    homeViewController.joinPrivateGameButton,
                                                                    homeViewController.createGameButton,
                                                                    nil]];
            

            return;
        }
    }
    else if(alertView.tag == 2) {
        if(buttonIndex == 0){
            return;
        }
    }
    else if(alertView.tag == 3) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"" forKey: @"game"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"creator"];
        [dict setObject:@"authresponse" forKey:@"type"];

        if(buttonIndex == 0){
            [dict setObject:@"deny" forKey:@"auth"];
        }
        else if(buttonIndex == 1){
            [dict setObject:@"allow" forKey:@"auth"];
        }
        [PubNub sendMessage:dict toChannel:[PNChannel channelWithName: reqUUID shouldObservePresence:YES]];

    }
    else if(alertView.tag == 4) {
        if(buttonIndex == 0){
            [self goToHome:loadViewController];
        }
    }
    else if(alertView.tag == 5) {
        
        loadViewController = [self goToLoad];
    
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject:@"join" forKey:@"type"];
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];

    }
    else if(alertView.tag == 6) {
        if(buttonIndex == 0){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"false" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];

            [self goToHome: roomViewController];
        }
        else if(buttonIndex == 1) {
            shouldGoToHome = NO;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"true" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
            
            [self goToLoad];

        }
    }
}

-(void) handleGenericLogin: (NSDictionary *) dict{
    
    NSString * suc = [dict objectForKey: @"success"];

    
    if([suc isEqualToString: @"True"]){
        NSString * userName = [dict objectForKey: @"username"];
        [[Globals sharedInstance] setUserName: userName];
        
        [self goToHome: loginViewController];
    }
    else if([suc isEqualToString: @"False"]){
        NSString * mess = [dict objectForKey: @"message"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User unreachable :(" message: mess delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
        [alert show];
        
        [self setInitialViewController: homeViewController];
    }
}

-(ViewController *) goToHome {
    
    if(shouldGoToHome) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject:@"play-again" forKey:@"type"];
        [dict setObject:@"false" forKey:@"yes"];
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
        
        [roomViewController.view removeFromSuperview];
        
        [homeViewController enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects: homeViewController.createGameButton, homeViewController.gameName, homeViewController.joinPrivateGameButton, nil]] ;
        
        [self.window addSubview:homeViewController.view];
        
        [endAlert dismissWithClickedButtonIndex:0 animated:YES];

        return homeViewController;
        
    }
    else
        return nil;
}

-(ViewController *) goToRoom{
    
    roomViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"room"];
    
    [self.window addSubview:roomViewController.view];
    return roomViewController;
}

-(ViewController *) goToHome: (ViewController *)viewController{
    
    homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"home"];
    
    [self.window addSubview:homeViewController.view];
    return homeViewController;
}

-(ViewController *) goToServerError{
    
    serverErrorController = [mainStoryboard instantiateViewControllerWithIdentifier:@"serverError"];

    [self.window addSubview:serverErrorController.view];
    return serverErrorController;
}


-(ViewController *) goToLoad{
        
    loadViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"load"];
    
    [self.window addSubview:loadViewController.view];
    return serverErrorController;
}

-(void) setUIDAndUserName:(NSMutableDictionary *) dict {
    [dict setObject: [[Globals sharedInstance] udid] forKey: @"uuid"];
    [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
}

-(void) setDictionary:(NSMutableDictionary *) dict keys:(NSArray *)keys values:(NSArray *)values{
    if([keys count] != [values count]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The size of the key and value arguement array must be equal"];
    }
    
    for(int i = 0; i < [keys count]; i++) {
        [dict setObject: values[i] forKey: keys[i]];
    }
}

-(void) setInitialViewController:(ViewController *) viewCtrlr {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    self.window.rootViewController = viewCtrlr;
    [self.window makeKeyAndVisible];

}

@end

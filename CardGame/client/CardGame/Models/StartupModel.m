//
//  StartupModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-13.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "StartupModel.h"

@implementation StartupModel

@synthesize serverIsRunning;

BOOL shouldInvokeStartupFunctions;

/**********************************************************
 * The init function initialises the model and adds a
 * PubNub messageObserver to it. This model will handle
 * messages of the type login.
 * It first checks if the server is connected.
 * If the servers is connected, it checks if the uuid and 
 * user name loaded in the plists check out with the ones 
 * in the server.
 **********************************************************/
-(id)init
{
    self = [super init];
    
    if (self != nil) {
        
        shouldInvokeStartupFunctions = YES;
        
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                                                                            
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 
                                                                 if([type isEqualToString: @"login"] &&                                                                  shouldInvokeStartupFunctions == YES)
                                                                     [self processLoginFromServer: message.message];
                                                             }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfNamesLoaded) name:@"serverIsRunning" object:nil];
        
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
}

/**********************************************************
 * goToServerError posts a notification triggering the 
 * creation of a server error controller.
 **********************************************************/
-(void)goToServerError
{
    
    serverIsRunning = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverNotLoaded" object:self];
}

/**********************************************************
 * checkIfNamesLoaded posts a notification that informs the
 * AppDelegate that the sercer is loaded.
 **********************************************************/
-(void)checkIfNamesLoaded
{
    
    serverIsRunning = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverLoaded" object:self];
}

/**********************************************************
 * findFirstController ascertain whether the login is first 
 * controller or not. This is done based by checking user name
 * If this is loaded, a message is sent tot he server asking
 * if the names are correct.
 **********************************************************/
-(NSString *)findFirstController
{
    
    if([[[Globals sharedInstance] userName] isEqualToString: @""] || [[[Globals sharedInstance] udid] isEqualToString: @""]) {
        return @"login";
        shouldInvokeStartupFunctions = NO;
    }
    else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject: [[Globals sharedInstance] udid] forKey:@"uuid"];
        [dict setObject: @"login" forKey:@"type"];
        
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
                
        return @"unsure";
    }
}

/**********************************************************
 * processLoginFromServer checks if the login attempt is
 * succesful. If it is, then home is loaded, otherwise 
 * login is loaded.
 **********************************************************/
-(void)processLoginFromServer:(NSDictionary *)dict
{
    
    NSString * suc = [dict objectForKey: @"success"];
    
    if([suc isEqualToString: @"True"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHomeAsInitialController" object:self];
    }
    else if([suc isEqualToString: @"False"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLoginAsInitialController" object:self];
    }
}

@end
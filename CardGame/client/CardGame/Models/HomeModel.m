//
//  HomeModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel

@synthesize shouldInvokeHomeFunctions;

/**********************************************************
 * The init function initialises the model and adds a 
 * PubNub messageObserver to it. This model will handle
 * messages of the type create and joinable.
 * Server exceptions are also handled. 
 **********************************************************/
-(id)init
{
    
    self = [super init];
    
    if (self != nil) {
        shouldInvokeHomeFunctions = YES;
        
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                           
                                                                 if(shouldInvokeHomeFunctions == YES) {
                                                                     if([type isEqualToString: @"create"])
                                                                         [self handleCreate: message.message];
                                                                     else if([type isEqualToString: @"joinable"])
                                                                         [self handleJoinable: message.message];
                                                                     else if([type isEqualToString:@"exception"])
                                                                         [self handleException:message.message];

                                                                 }
                                                             }];
    }
    
    return self;
}

/**********************************************************
 * handleCreate checks if the the user was succesfully able
 * to create a game, and loads the loading page if he was
 * Otherwise, an error alert is shown.  
 **********************************************************/
-(void) handleCreate:(NSDictionary *)dict
{
             
        NSString * suc = [dict objectForKey: @"success"];
        NSString * mess = [dict objectForKey: @"message"];
        NSString * chanString = [dict objectForKey: @"channel"];
             
        if([suc isEqualToString: @"True"]){
            
            PNChannel * chan = [PNChannel channelWithName:chanString shouldObservePresence:YES];
            [[Globals sharedInstance] setGameChannel: chan];
            [[Globals sharedInstance] setWetherIsFirstGame: YES];
            [[Globals sharedInstance] setIsCreator: YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLoadFromHome" object:self];
        }
        else if([suc isEqualToString: @"False"]){
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game did not initialise" message: mess delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
            alert.tag = 1;
            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableHomeScreenButtons" object:self];
        }
}

/**********************************************************
 * handleJoinable checks if the user tried to join a 
 * joinable game. If he was, it loads the loading page
 * Otherwise, an error alert is shown.
 **********************************************************/
-(void) handleJoinable:(NSDictionary *)dict
{
             
        NSString * suc = [dict objectForKey: @"success"];
        NSString * mess = [dict objectForKey: @"message"];
        NSString * chanString = [dict objectForKey: @"channel"];
             
        if([suc isEqualToString: @"True"]){
            
            PNChannel * chan = [PNChannel channelWithName:chanString shouldObservePresence:YES];
            [[Globals sharedInstance] setGameChannel: chan];
            [[Globals sharedInstance] setWetherIsFirstGame: YES];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLoadFromHome" object:self];
        }
        else if([suc isEqualToString: @"False"]){
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Could not join" message: mess delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
            alert.tag = 2;
            [alert show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableHomeScreenButtons" object:self];
        }
}

/**********************************************************
 * handleException handles server exceptions.
 **********************************************************/
-(void) handleException: (NSDictionary *) dict
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server Exception Occoured" message: @"Please wait while we try to recover" delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alert show];
}

/**********************************************************
 * The following function handles input to alertViews.
 **********************************************************/
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if(alertView.tag == 1) {
        if(buttonIndex == 0){
            
            return;
        }
    }
    else if(alertView.tag == 2) {
        if(buttonIndex == 0){
            return;
        }
    }
}

@end

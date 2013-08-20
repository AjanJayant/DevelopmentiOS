//
//  LoginModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel

@synthesize shouldInvokeLoginFunctions;

/**********************************************************
 * The init function initialises the model and adds a
 * PubNub messageObserver to it. This model will handle
 * messages of the type create-user and login.
 * Server exceptions are also handled.
 **********************************************************/
-(id)init
{
    
    self = [super init];
    
    if (self != nil) {
        
        shouldInvokeLoginFunctions = YES;
        
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 if(shouldInvokeLoginFunctions == YES) {
                                                                     if([type isEqualToString: @"create-user"])
                                                                         [self handleCreateUser: message.message];
                                                                     else if([type isEqualToString: @"login"])
                                                                         [self handleLogin: message.message];
                                                                     else if([type isEqualToString:@"exception"]){
                                                                         [self handleException:message.message];
                                                                     }
                                                                 }
                                                             }];
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
}

/**********************************************************
 * handleCreateUser checks if the attempt to create the user 
 * was succesful, and if it was, sets the user name.
 **********************************************************/
-(void) handleCreateUser: (NSDictionary *) dict
{
    
    NSString * suc = [dict objectForKey: @"success"];
    NSString * name = [dict objectForKey:@"username"];
    
    if([suc isEqualToString: @"True"]){
        [[Globals sharedInstance] setUserName: name];
    }
    [self handleGenericLogin: dict];
}

/**********************************************************
 * handleLogin calls handleGernicLogin.
 **********************************************************/
-(void) handleLogin: (NSDictionary *) dict
{
    
    [self handleGenericLogin: dict];
}

/**********************************************************
 * handleGenericLogin handles whether the attempt was 
 * succesful or not, showing alerts if so.
 **********************************************************/
-(void) handleGenericLogin: (NSDictionary *) dict
{
    
    NSString * suc = [dict objectForKey: @"success"];
    
    if([suc isEqualToString: @"True"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromLogin" object:self];
    }
    else if([suc isEqualToString: @"False"]){
        NSString * mess = [dict objectForKey: @"message"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User unreachable :(" message: mess delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoginProgress" object:self];
    }
}

/**********************************************************
 * handleException handles server exceptions.
 **********************************************************/
-(void) handleException: (NSDictionary *) dict
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server Exception Occoured" message: @"Maybe try login instead" delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alert show];
}

/**********************************************************
 * setupUUIDIfNotPresent sets a unique uuid if not already
 * present.
 **********************************************************/
-(void) setupUUIDIfNotPresent
{

    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;
    [[Globals sharedInstance] setuDID: uid];
}

@end

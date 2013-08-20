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

-(id)init{
    
    self = [super init];
    
    if (self != nil)
    {
        shouldInvokeLoginFunctions = YES;
        
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 if(shouldInvokeLoginFunctions == YES) {
                                                                     if([type isEqualToString: @"create-user"])
                                                                         [self handleCreateUser: message.message];
                                                                     else if([type isEqualToString: @"login"])
                                                                         [self handleLogin: message.message];
                                                                 }
                                                             }];
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
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

-(void) handleGenericLogin: (NSDictionary *) dict{
    
    NSString * suc = [dict objectForKey: @"success"];
    
    if([suc isEqualToString: @"True"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromLogin" object:self];
    }
    else if([suc isEqualToString: @"False"]){
        NSString * mess = [dict objectForKey: @"message"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User unreachable :(" message: mess delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
        [alert show];
    }
}

-(void) setupUUIDIfNotPresent {

    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;
    [[Globals sharedInstance] setuDID: uid];
}

@end

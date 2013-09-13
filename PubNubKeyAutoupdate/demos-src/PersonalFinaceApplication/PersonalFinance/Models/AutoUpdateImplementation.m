//
//  AutoUpdateImplementation.m
//
//  Created by Ajan Jayant on 2013-08-26.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "AutoUpdateImplementation.h"

@implementation AutoUpdateImplementation

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id) object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    NSMutableDictionary *valueUpdateDict = [[NSMutableDictionary alloc] init];
    for(id key in keysToBeUpdated) {
        if([keyPath isEqualToString: key]) {
            @try{
                [valueUpdateDict setObject:@"update" forKey:@"type"];
                [valueUpdateDict setObject:[change objectForKey: NSKeyValueChangeNewKey] forKey:@"value"];
                [valueUpdateDict setObject:key forKey:@"key"];
                [PubNub sendMessage:valueUpdateDict toChannel:serverChannel];
            }
            @catch(NSException *e){
                printFunction();
                [AutoUpdateErrorHandling printErrorForFunction:@"observeValueForKeyPath" forFile:@"AutoUpdateImplementation" withMessage:[@"Internal error: Dictionary-setting error./nException name: " stringByAppendingString: e.name]];

            }
        }
    }
}

- (void)unregisterForChangeNotification:(NSString *) key sender:(id)observedObject{
    
    @try {

        [observedObject removeObserver:self forKeyPath:key];
    }
    @catch(NSException *e)
    {
        printFunction();
        [AutoUpdateErrorHandling printErrorForFunction:@"unregisterForChangeNotification" forFile:@"AutoUpdateImplementation" withMessage:[@"Cannot remove observer for key: key not registered as a observer. Most likey the key sent by other application is not registered during subscribeToChannelWithUpdates./nException name: " stringByAppendingString: e.name]];
    }
}

- (void)subscribeToChannelWithUpdates:(id)sender onChannel:(NSString *)channel forKeys:(NSArray*)keys withErrorCallback:(void (^)(void))f
{
    printFunction = f;
    serverChannel = [PNChannel channelWithName:channel shouldObservePresence:YES];
    [PubNub subscribeOnChannel:serverChannel];
    keysToBeUpdated = [[NSArray alloc] initWithArray: keys];
    sourceOfKeys = sender;
        for(id key in keysToBeUpdated) {
            if ([key rangeOfString:@"text"].location == NSNotFound) {
                [AutoUpdateErrorHandling printWarningForFunction:@"subscribeToChannelWithUpdates" forFile:@"AutoUpdateImplementation" withMessage:[@" .text not found in key " stringByAppendingString: key]];
            }
            [sender addObserver: self
                     forKeyPath:key
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
        }
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             NSDictionary *messageDict = message.message;
                                                                 if([[messageDict objectForKey: @"type"] isEqualToString: @"update"]) {
                                                                     NSString *key = [messageDict objectForKey: @"key"];
                                                                     NSString *value = [messageDict objectForKey:                                                                          @"value"];
                                                                     
                                                                     [self unregisterForChangeNotification:key sender:sender];
                                                                     @try {
                                                                         [sender setValue:value forKeyPath:key];
                                                                     }
                                                                     @catch(NSException *e) {
                                                                         printFunction();
                                                                         [AutoUpdateErrorHandling printErrorForFunction:@"subscribeToChannelWithUpdates" forFile:@"AutoUpdateImplementation" withMessage:[@"Key sent to application is not key-value coding compliant./nException name: " stringByAppendingString: e.name]];

  
                                                                     }
                                                                     @try {
                                                                         [sender addObserver: self
                                                                              forKeyPath:key
                                                                                 options:NSKeyValueObservingOptionNew
                                                                                 context:NULL];
                                                                     }
                                                                     @catch(NSException *e) {
                                                                         printFunction();
                                                                         [AutoUpdateErrorHandling printErrorForFunction:@"subscribeToChannelWithUpdates" forFile:@"AutoUpdateImplementation" withMessage:[@"Add observer received an unknown key./nException name: " stringByAppendingString: e.name]];
                                                                         
                                                                     }

                                                                 }
                                                         }];
}

- (void)unsubscribeFromChannelWithUpdates:(NSString *)channel
{
    @try{
        [PubNub unsubscribeFromChannel:serverChannel];
        for(id key in keysToBeUpdated) {
            [self unregisterForChangeNotification:key sender:sourceOfKeys];
        }
        keysToBeUpdated = [[NSArray alloc] init];
    
        [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    }
    @catch(NSException *e) {
        printFunction();
        [AutoUpdateErrorHandling printErrorForFunction:@"unsubscribeFromChannelWithUpdates" forFile:@"AutoUpdateImplementation" withMessage:[@"Internal error: Unable to unregstir keys and/or  unsubscribe" stringByAppendingString: e.name]];

    }
}

@end

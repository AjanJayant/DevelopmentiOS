//
//  PubNubKeyUpdate.m
//
//  Created by Ajan Jayant on 2013-09-10.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "PubNubKeyUpdate.h"

@implementation PubNubKeyUpdate

AutoUpdateImplementation *a;

NSString *keyChannel;

int i = 0;

+ (void)subscribeToChannelWithUpdates:(id)sender onChannel:(NSString *)channel forKeys:(NSArray*)keys withErrorCallback:(void (^)(void))f
{
    a = [[AutoUpdateImplementation alloc] init];
    keyChannel = [NSString stringWithString: channel];
    if(i == 0) {
        [a subscribeToChannelWithUpdates:sender
                                    onChannel:@"Ajan"
                                 forKeys:keys withErrorCallback:f];
        i++;
    }
    else {
        [AutoUpdateErrorHandling printWarningForFunction:@"subscribeToChannelWithUpdates" forFile:@"PubNubKeyUpdate" withMessage:@"Repeated attempts to subscribe not allowed"];
    }
}

+ (void)unsubscribeFromChannelWithUpdates:(NSString *)channel
{
    if(i == 1) {
        i = 0;
        [a unsubscribeFromChannelWithUpdates:keyChannel];
    }
    else {
        [AutoUpdateErrorHandling printWarningForFunction:@"unsubscribeFromChannelWithUpdates" forFile:@"PubNubKeyUpdate" withMessage:@"Repeated attempts to unsubscribe not allowed"];
    }
}

@end

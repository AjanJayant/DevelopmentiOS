//
//  PubNubKeyUpdate.h
//
//  Created by Ajan Jayant on 2013-09-10.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoUpdateErrorHandling.h"
#import "AutoUpdateImplementation.h"

@interface PubNubKeyUpdate : NSObject

+ (void)subscribeToChannelWithUpdates:(id)sender onChannel:(NSString *)channel forKeys:(NSArray*)keys withErrorCallback:(void (^)(void))f;

+ (void)unsubscribeFromChannelWithUpdates:(NSString *)channel;

@end

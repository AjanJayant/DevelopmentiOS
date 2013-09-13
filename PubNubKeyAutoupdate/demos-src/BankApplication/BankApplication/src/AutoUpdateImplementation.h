//
//  AutoUpdateImplementation
//
//  Created by Ajan Jayant on 2013-08-26.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoUpdateErrorHandling.h"

@interface AutoUpdateImplementation : NSObject
{
    
    NSMutableDictionary *dict;
    
    PNChannel *serverChannel;
    
    NSArray *keysToBeUpdated;
        
    id sourceOfKeys;
    
    void (^printFunction)(void);
}

- (void)subscribeToChannelWithUpdates:(id)sender onChannel:(NSString *)channel forKeys:(NSArray*)keys withErrorCallback:(void (^)(void))f;

- (void)unsubscribeFromChannelWithUpdates:(NSString *)channel;

@end

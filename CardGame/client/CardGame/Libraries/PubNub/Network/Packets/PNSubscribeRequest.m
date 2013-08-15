//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  channel(s) subscription request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNSubscribeRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNChannel+Protected.h"
#import "PubNub+Protected.h"
#import "PNConstants.h"


#pragma mark Private interface methods

@interface PNSubscribeRequest ()


#pragma mark - Properties

// Stores reference on list of channels on which client should subscribe
@property (nonatomic, strong) NSArray *channels;

// Stores reference on list of channels for which presence should be enabled/disabled
@property (nonatomic, strong) NSArray *channelsForPresenceEnabling;
@property (nonatomic, strong) NSArray *channelsForPresenceDisabling;

// Stores recent channels/presence state update time (token)
@property (nonatomic, copy) NSString *updateTimeToken;

// Stores reference on client identifier on the moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;

// Stores whether leave request was sent to subscribe on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;


@end


#pragma mark Public interface methods

@implementation PNSubscribeRequest


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [self subscribeRequestForChannels:@[channel] byUserRequest:isSubscribingByUserRequest];
}

+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [[[self class] alloc] initForChannels:channels byUserRequest:isSubscribingByUserRequest];
}

#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    return [self initForChannels:@[channel] byUserRequest:isSubscribingByUserRequest];
}

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        self.sendingByUserRequest = isSubscribingByUserRequest;
        self.channels = [NSArray arrayWithArray:channels];
        self.clientIdentifier = [PubNub escapedClientIdentifier];

        
        // Retrieve largest update time token from set of channels (sorting to make larger token to be at
        // the end of the list
        self.updateTimeToken = [PNChannel largestTimetokenFromChannels:channels];
    }
    
    
    return self;
}

/**
 * Reloaded to return full list of channels for which client is subscribing
 */
- (NSArray *)channels {

    NSArray *channels = _channels;

    // In case if user specified set of channels for which presence is enabled, add them to the channels list
    if ([self.channelsForPresenceEnabling count] > 0) {

        NSMutableSet *updatedSet = [NSMutableSet setWithArray:channels];
        [updatedSet addObjectsFromArray:self.channelsForPresenceEnabling];

        channels = [updatedSet allObjects];
    }


    return channels;
}

- (BOOL)isInitialSubscription {

    return [self.updateTimeToken isEqualToString:@"0"];
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.subscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.subscriptionCallback;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"%@/subscribe/%@/%@/%@_%@/%@?uuid=%@%@",
            kPNRequestAPIVersionPrefix,
            [PubNub sharedInstance].configuration.subscriptionKey,
            [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
            [self callbackMethodName],
            self.shortIdentifier,
            self.updateTimeToken,
            self.clientIdentifier,
			([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@"")];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"<%@> %p [PATH: %@]", NSStringFromClass([self class]),
                                                             self, [self resourcePath]];
}

#pragma mark -


@end

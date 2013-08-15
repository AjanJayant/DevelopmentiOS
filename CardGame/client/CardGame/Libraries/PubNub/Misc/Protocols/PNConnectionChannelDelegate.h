//
//  PNConnectionChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to
//  organize communication between connection
//  channel management code and PubNub client
//  instance.
//
//
//  Created by Sergey Mamontov on 12/16/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNConnectionChannel, PNError;


#pragma mark - Connection channel observer methods

@protocol PNConnectionChannelDelegate <NSObject>


@required

/**
 * Sent to the PubNub client when connection channel was unable to enable connection
 */
- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel successfully
 * configured and connected to the specified PubNub services origin
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel successfully
 * restored it's operation after connection error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel was unable
 * to establish connection with remote PubNub services because
 * of error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel
     connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error;

/**
 * Sent to the PubNub client when connection channel disconnected
 * from PubNub services
 */
- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host;

/**
 * Sent to the PubNub client when connection channel disconnected
 * from PubNub services because of error
 */
- (void)connectionChannel:(PNConnectionChannel *)channel
    willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error;


#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 * Sent to the PubNub client when connection channel is about to suspend it's operation
 */
- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel suspended
 */
- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel is about to resume it's operation
 */
- (void)connectionChannelWillResume:(PNConnectionChannel *)channel;

/**
 * Sent to the PubNub client when connection channel resumed it's operation
 * and ready to process requests
 */
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel;
#endif

#pragma mark -

@end

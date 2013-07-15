//
//  AppDelegate.m
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Hello");

    // The following line is commented out to allow the first controller
    // to be the initial controller
    // self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    NSLog(@"Hello2");

    [PubNub setDelegate:self];
    

    // Messaging server setup
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                          publishKey:@"pub-c-15eaba1b-1f85-4b28-98c3-52ad653f0747"
                                                          subscribeKey:@"sub-c-4db30200-d92b-11e2-b1b2-02ee2ddab7fe"
                                                           secretKey:@"sec-c-YzRmNTE5M2MtYWYyMC00M2FjLWEyMDctMjMyYzc4YjI1OTgy"]];
    
    [PubNub connect];
    NSLog(@"Hello3");

    // Code for implemnting storing of messages
    
    // Making changes to save to iphone

    [[Globals sharedInstance] loadVariables];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"root view controller"];
    TableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"first"];
    if([[[Globals sharedInstance] userName] isEqualToString: @""] || [[[Globals sharedInstance] userNumber] isEqualToString: @""])
        self.window.rootViewController = viewController;
    else
        self.window.rootViewController = tableViewController;
    return YES;
}

////////////////////////////////////////////////////////////////
// Checks if client has receivedmessage, and stores if he has //
////////////////////////////////////////////////////////////////

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    NSMutableDictionary *groupMessages = [[NSMutableDictionary alloc] init];
    [groupMessages setDictionary: [[Globals sharedInstance] groupMess]];
    
    NSMutableDictionary *nameDict = [[NSMutableDictionary alloc] init];
    [nameDict setDictionary: [[Globals sharedInstance] nameDict]];

    NSMutableString *groupName = [[NSMutableString alloc] init];
    
    NSString* text = [[message.message allKeys] objectAtIndex:0];
    NSString* group = [message.message objectForKey: text];
    NSString* member = @"";   // So we know who sent message
    bool isFound = false;
    
    // When checking, we append the name of the group to the name of
    // the group member, and then compare
    // This is done for added security. See (IBAction) sendButton in
    // ViewController for more details
    for(id key in nameDict) {
        id value = [nameDict objectForKey: key];
        for(id name in value) {
            id num = [[[Globals sharedInstance] nameNumber] objectForKey: name];
            if([group isEqual: [key stringByAppendingString: num]]){
                groupName = [NSMutableString stringWithString: key];
                isFound = true;
                member = name; // So we know who sent message

                break;
            }
        }
    }
    if(!isFound)
        return;
    
    NSString *str = [PNJSONSerialization stringFromJSONObject: text];
    str = [str substringWithRange:NSMakeRange(1, [str length] - 2)];
    //str = [str stringByAppendingString: member]; So we know who sent message No need because now  using dict->array->dict
    
    NSMutableArray *arr = [groupMessages valueForKey: groupName];
    NSArray *dateSender = [[NSArray alloc] initWithObjects: [NSDate dateWithTimeIntervalSinceNow:0], member, nil];
    NSMutableDictionary *msgDate = [[NSMutableDictionary alloc] init];
    [msgDate setObject: dateSender forKey: str];
    [arr addObject: msgDate];
    
    [groupMessages removeObjectForKey: groupName];
    [groupMessages setObject: arr forKey: groupName];
    [[Globals sharedInstance] setGroupMess: groupMessages];
    
    // Save variables
    [[Globals sharedInstance] saveVariables];

}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GMv2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GMv2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

//
//  AutoUpdateErrorHandling.m
//
//  Created by Ajan Jayant on 2013-09-10.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "AutoUpdateErrorHandling.h"

@implementation AutoUpdateErrorHandling

+  (void)printWarningForFunction:(NSString *)f forFile:(NSString *)file withMessage:(NSString *)message
{
    NSLog(@"PubNubKeyUpdate - Warning for function %@ in file %@: %@",f, file, message);
}

+ (void)printErrorForFunction:(NSString *)f forFile:(NSString *)file withMessage:(NSString *)message
{
    NSLog(@"PubNubKeyUpdate - Error for function %@ in file %@: %@",f, file, message);
    NSLog(@"Please note that keys for UI objects represent the objects themselves.\n Eg. For UILabel *label, the key would be label.text.");
}

@end

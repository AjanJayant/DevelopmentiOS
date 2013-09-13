//
//  AutoUpdateErrorHandling.h
//
//  Created by Ajan Jayant on 2013-09-10.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoUpdateErrorHandling : NSObject

+  (void)printWarningForFunction:(NSString *)file forFile:(NSString *)f withMessage:(NSString *)message
;

+ (void)printErrorForFunction:(NSString *)f forFile:(NSString *)file withMessage:(NSString *)message;

@end

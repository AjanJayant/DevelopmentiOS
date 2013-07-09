//
//  TableViewCell.h
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "Constants.h"

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) IBOutlet UILabel *memberNamelabel;

@property (weak, nonatomic) IBOutlet UILabel *memberNumber;

@end

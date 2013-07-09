//
//  TableViewCell.m
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

@synthesize groupName;

@synthesize memberNamelabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if([self tag] != 0)
        [[Globals sharedInstance] setSelectedGroupName: [NSString stringWithString: groupName.text]];
}

@end

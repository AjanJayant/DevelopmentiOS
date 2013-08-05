//
//  TableViewController.h
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import "ViewController.h"
#import "Globals.h"
#import "Constants.h"

@interface TableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *firstNavBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editGroups;

@property (weak, nonatomic) IBOutlet UINavigationBar *deleteGroupsNavBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteGroupsBackButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteGroupsDeleteButton;

- (IBAction)deleteGroupsDeleteButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *deleteTable;

@property (strong, nonatomic) IBOutlet UITableView *groupTable;

@end

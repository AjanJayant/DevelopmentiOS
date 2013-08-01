//
//  TableViewController.m
//  GM
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize firstNavBar;

@synthesize editGroups;

@synthesize deleteGroupsNavBar;

@synthesize deleteGroupsBackButton;

@synthesize deleteGroupsDeleteButton;

@synthesize deleteTable;

@synthesize groupTable;

NSMutableArray * groupsForRemoval;

NSMutableArray * namesToBeAdded;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    groupsForRemoval = [[NSMutableArray alloc] init];
    namesToBeAdded = [[NSMutableArray alloc] init]; 
    
    // Done here because Globals not set at AppDelegate stage
    
    // We listen to name; private, you choose who you want to listen to
    [PubNub subscribeOnChannel:[PNChannel channelWithName: [[Globals sharedInstance] userName]]];
    
    // we listen to phone number; public so you know you've been added
    [PubNub subscribeOnChannel:[PNChannel channelWithName: [[Globals sharedInstance] userNumber]]];
    
    // For first table view controller
    firstNavBar.topItem.title = @"Select a group";
    // editGroups.title = @"Delete";
    // hacky way of hiding button if no groups
    if([[[Globals sharedInstance] groups] count] == 0) {
        editGroups.customView = [[UIView alloc] init];
    }
    // For delete groups
    deleteGroupsBackButton.title = @"Back";
    
    // deleteGroupsDeleteButton.title = @"Delete";
    deleteGroupsNavBar.topItem.title = @"Select to delete";

    [[Globals sharedInstance] setSelectedGroupName: @""];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self.tableView reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reloadTable) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(tableView.tag == 0)
        return ([[[Globals sharedInstance] groups] count]);
    else if(tableView.tag == 1)
        return [[[Globals sharedInstance] groups] count];
    else if(tableView.tag == 2)
        return [[[Globals sharedInstance] nameNumber] allKeys].count;
    else
        return 0;
}

- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // The following if statement allows
    // us to use the table view controller for both
    // first and viewEdit
    // Two different types of cells used, so different identifiers
    TableViewCell *cell;
    NSString *CellIdentifier = [[NSString alloc] init];
    if(tableView.tag == 0) {
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        // Configure the cell...
        cell.nameLabel.text= [[Globals sharedInstance] groups][indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        // Resets names for groups every time
        [[Globals sharedInstance] setNamesForGroup: [[NSMutableArray alloc] init]];
    }
    // Delete groups controller has tag == 1
    else if(tableView.tag == 1){
         NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        cell.accessoryType = UITableViewCellAccessoryNone; // Make sure reloaded data is not selected
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameLabel.text= [[Globals sharedInstance] groups][indexPath.row];
    }
    else {
        NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        // Configure cell
        cell.accessoryType = UITableViewCellAccessoryNone; // Make sure reloaded data is not selected
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[ alloc] initWithNibName<#DetailViewController#>:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    TableViewCell *cell = (TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(tableView.tag == 0) {
        
        [[Globals sharedInstance] setSelectedGroupName: [[Globals sharedInstance] groups][indexPath.row]];
        
        [self performSegueWithIdentifier:@"firstToSend" sender:self];
    }
    else if(tableView.tag == 1) {
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            for(int i = 0; i < [groupsForRemoval count]; i++){
                if([groupsForRemoval[i] isEqualToString: cell.nameLabel.text])
                    [groupsForRemoval removeObject:groupsForRemoval[i]];
            }
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [groupsForRemoval addObject: cell.nameLabel.text];
        }
    }

}

//////
//->//
//////
- (IBAction)deleteGroupsDeleteButton:(id)sender {
    for(id group in groupsForRemoval) {
        [[[Globals sharedInstance] nameDict] removeObjectForKey: group];
        [[[Globals sharedInstance] groups] removeObject: group];
        [[[Globals sharedInstance] groupMess] setValue:nil forKey: group];

    }
    [deleteTable reloadData];
    if([[[Globals sharedInstance] groups] count] == 0) {
        deleteGroupsDeleteButton.customView = [[UIView alloc] init];
    }
    
    // Save variables
    [[Globals sharedInstance] saveVariables];

}

-(void)reloadTable{
    [self.groupTable reloadData];
}

@end

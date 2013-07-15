//
//  ViewController.h
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIPlaceHolderTextView.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "Globals.h"
#import "Constants.h"
#import "TableViewCell.h"

@interface ViewController : UIViewController <UITableViewDataSource,UIBubbleTableViewDataSource,UITextViewDelegate, UITextFieldDelegate,UITableViewDelegate,UISearchDisplayDelegate, UISearchBarDelegate>

////////////////////////////////////////////////////
//  Following ar properties used to add user name //
////////////////////////////////////////////////////

@property (weak, nonatomic) IBOutlet UILabel *adduserNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *addUsernameField;

@property (weak, nonatomic) IBOutlet UIButton *addUsernameButton;

@property (weak, nonatomic) IBOutlet UITextField *addUserNumberField;

- (IBAction)addUserNameButton:(id)sender;

//////////////////////////////////////////////////////////////////////////////////
// Following are properties and buttons for view controller that sends messages //
//////////////////////////////////////////////////////////////////////////////////

@property (weak, nonatomic) IBOutlet UINavigationBar *sendNavBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewEditButton;

@property (strong, nonatomic) IBOutlet UIView *sendView;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *message;

@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;

- (IBAction)sendButton:(id)sender;

- (IBAction)backButton:(id)sender;

///////////////////////////////////////////////////////////////////////////////
// Following are properties and buttons for view controller that adds groups //
///////////////////////////////////////////////////////////////////////////////

@property (weak, nonatomic) IBOutlet UITableView *nameTable;

@property (weak, nonatomic) IBOutlet UINavigationBar *addGroupNavBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGroupBackButton;

@property (weak, nonatomic) IBOutlet UITextField *addGroup;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectContacts;

@property (weak, nonatomic) IBOutlet UITableView *showMembers;

@property (weak, nonatomic) IBOutlet UISearchBar *addContactsSearchBar;

@property (weak, nonatomic) IBOutlet UIButton *addContactsButton;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *addContactsSearchController;

- (IBAction)selectContacts:(id)sender;

- (IBAction)addContactsButton:(id)sender;

////////////////////////////////////////////////////////////////////////////////////////////////////////
// Following are properties and buttons for view controller that allows users to view and edit groups //
////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (weak, nonatomic) IBOutlet UINavigationBar *viewEditNavBar;

@property (weak, nonatomic) IBOutlet UITableView *memberView;


@property (weak, nonatomic) IBOutlet UIButton *addNameButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteNamesButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backToSendButton;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *viewEditSearchController;

- (IBAction)backToSendButton:(id)sender;

@property (weak, nonatomic) IBOutlet UISearchBar *viewGroupSearchBar;

- (IBAction)addNameButton:(id)sender;

- (IBAction)deleteNamesButton:(id)sender;

// BubleData Code

@property (strong, nonatomic) NSMutableArray *bubbleData;

- (void) sanitizeUserNumber;

@end

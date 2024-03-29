//
//  ListViewController.h
//  Things2Do
//
//  Created by Justin Tilley on 5/13/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *taskTable;
    IBOutlet UINavigationItem *listNavTitle;
    NSMutableArray *tasksArray;
    NSMutableDictionary *saveDict;
    NSMutableDictionary *tasksDict;
    NSIndexPath *selectedTask;
    PFUser *current;
    BOOL offline;
}
@property NSString *userTimestamp;
-(IBAction)onClick:(id)sender;

@end

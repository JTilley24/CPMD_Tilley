//
//  ListViewController.m
//  Things2Do
//
//  Created by Justin Tilley on 5/13/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "ListViewController.h"
#import "TaskTableCell.h"
#import "AddItemViewController.h"
@interface ListViewController ()

@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    
    UINib *taskCellNib = [UINib nibWithNibName:@"TaskTableCell" bundle:nil];
    if(taskCellNib != nil){
        [taskTable registerNib:taskCellNib forCellReuseIdentifier:@"CustomCell"];
    }
    [self getTasks];
}
-(void) getTasks
{
    tasksArray = [[NSMutableArray alloc] init];
    PFUser *current = [PFUser currentUser];
    if(current){
        NSString *currentUserName = [[NSString alloc] initWithFormat:@"%@'s List",  current[@"username"]];
        self.title = currentUserName;
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query whereKey:@"User" equalTo:current];
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if(!error){
                for(PFObject *task in tasks){
                    [tasksArray addObject:task];
                }
                [taskTable reloadData];
            }
        }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tasksArray != nil){
        return [tasksArray count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if(cell != nil){
        PFObject *taskObject = [tasksArray objectAtIndex:indexPath.row];
        NSString *name = taskObject[@"Name"];
        cell.taskName = name;
        NSString *date = taskObject[@"Date"];
        cell.taskDate = date;
        NSString *time = taskObject[@"Time"];
        cell.taskTime = time;
        [cell refreshCell];
        return cell;
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedTask = indexPath;
    UIAlertView *editAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Edit", nil];
    [editAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex]){
        [[tasksArray objectAtIndex:selectedTask.row] deleteInBackground];
        [self getTasks];
    }else{
        AddItemViewController *addItem = [self.storyboard instantiateViewControllerWithIdentifier:@"addItem"];
        [addItem setEditObject:[tasksArray  objectAtIndex:selectedTask.row]];
        [self.navigationController pushViewController:addItem animated:YES];
    }
}

-(IBAction)onClick:(id)sender{
    UIBarButtonItem *button = sender;
    if(button.tag == 0){
        
    }else if (button.tag == 1){
        [self performSegueWithIdentifier:@"addItem" sender:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

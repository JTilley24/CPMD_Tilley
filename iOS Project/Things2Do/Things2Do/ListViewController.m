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
#import "Reachability.h"
@interface ListViewController ()

@end

@implementation ListViewController
@synthesize userTimestamp;
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

-(void)viewDidAppear:(BOOL)animate
{
    //Create Custom Table Cell
    UINib *taskCellNib = [UINib nibWithNibName:@"TaskTableCell" bundle:nil];
    if(taskCellNib != nil){
        [taskTable registerNib:taskCellNib forCellReuseIdentifier:@"CustomCell"];
    }
    
    current = [PFUser currentUser];
    tasksArray = [[NSMutableArray alloc] init];
    if(current){
        NSString *currentUserName = [[NSString alloc] initWithFormat:@"%@'s List",  current[@"username"]];
        self.title = currentUserName;
        
        if([self checkConnection]){
            offline = NO;
        }else{
            offline = YES;
        }
        //Begin Loading Process
        [self initDefaults];
    }
}

//Check For Changes in Network and Server
-(void) checkForChange{
    if(offline){
        if([self checkConnection]){
            offline = NO;
            [self initDefaults];
        }
    }else{
        if(![self checkConnection]){
            offline = YES;
            [self initDefaults];
        }
    }
    if([self checkConnection]){
        offline = NO;
        PFQuery  *query = [PFQuery queryWithClassName:@"Changes"];
        [query whereKey:@"User" equalTo: current.username];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if([objects count] > 0){
                NSString *time = [[objects objectAtIndex:0] objectForKey:@"TimeStamp"];
                if(![time isEqualToString:userTimestamp]){
                    [self initDefaults];
                }
            }
        }];
    }else{
        offline = YES;
    }
}


//Display Offline Tasks and Retrieve Tasks from Parse if available
-(void) initDefaults{
    tasksDict = [[NSMutableDictionary alloc] init];
    saveDict = [[NSMutableDictionary alloc] init];
    
    //Get Offline Tasks and Previous Offline Changes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:current.username] objectForKey:@"Tasks"] != nil){
        tasksDict = [[[defaults objectForKey:current.username] objectForKey:@"Tasks"] mutableCopy];
    }
    if([[defaults objectForKey:current.username] objectForKey:@"Save"] != nil){
        saveDict = [[[defaults objectForKey:current.username] objectForKey:@"Save"] mutableCopy];

    }
    //Set Timer
    PFQuery  *query = [PFQuery queryWithClassName:@"Changes"];
    [query whereKey:@"User" equalTo: current.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if([objects count] > 0){
                    userTimestamp = [[objects objectAtIndex:0] objectForKey:@"TimeStamp"];
                }
    }];
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForChange) userInfo:nil repeats:YES];
    //Check for Previous Offline Tasks
    if([self checkConnection]){
        if([saveDict count] != 0){
            [self sendToParse];
        }else{
            [self getTasks];
            
        }
    }
    
    [taskTable reloadData];
}

//Save Offline Tasks to Parse
-(void) sendToParse{
        NSArray *keys = [saveDict allKeys];
        for(NSString *key in keys){
            if([[saveDict objectForKey:key] objectForKey:@"Delete"] != nil){
                PFQuery *query = [PFQuery queryWithClassName:@"Task"];
                [query whereKey:@"User" equalTo:current];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    for (PFObject * object in objects) {
                        if([object.objectId isEqualToString:key]){
                           [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                               if(!error){
                                   
                                   [saveDict removeObjectForKey:key];
                                   [self saveTimeStamp];
                                   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                   NSMutableDictionary *userDict = [[defaults objectForKey:current.username] mutableCopy];
                                   if(userDict == nil){
                                       userDict = [[NSMutableDictionary alloc] init];
                                   }
                                   [userDict setObject:saveDict forKey:@"Save"];
                                   [defaults setObject:userDict forKey:current.username];
                                   [defaults synchronize];
                                   [self getTasks];
                               }
                           }];
                        }
                    }
                }];
               
            }
            if([[saveDict objectForKey:key] objectForKey:@"ObjectId"] == nil){
                NSMutableDictionary *savedTask = [[saveDict objectForKey:key] mutableCopy];
                PFObject *newTask = [PFObject objectWithClassName:@"Task"];
                newTask[@"Name"] = [savedTask objectForKey:@"Name"];
                newTask[@"Date"] = [savedTask objectForKey:@"Date"];
                newTask[@"Time"] = [savedTask objectForKey:@"Time"];
                newTask[@"User"] = current;
                [newTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        [self getTasks];
                    }
                }];
                [saveDict removeObjectForKey:key];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userDict = [[defaults objectForKey:current.username] mutableCopy];
                if(userDict == nil){
                    userDict = [[NSMutableDictionary alloc] init];
                }
                [userDict setObject:saveDict forKey:@"Save"];
                [defaults setObject:userDict forKey:current.username];
                [defaults synchronize];
                
            }else{
                PFQuery *query = [PFQuery queryWithClassName:@"Task"];
                [query whereKey:@"User" equalTo:current];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    for (PFObject * object in objects) {
                        NSMutableDictionary *savedTask = [[saveDict objectForKey:key] mutableCopy];
                        if([object.objectId isEqualToString:[[saveDict objectForKey:key] objectForKey:@"ObjectId"]]){
                            object[@"Name"] = [savedTask objectForKey:@"Name"];
                            object[@"Date"] = [savedTask objectForKey:@"Date"];
                            object[@"Time"] = [savedTask objectForKey:@"Time"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(!error){
                                    [self getTasks];
                                }
                            }];
                        }
                    }
                }];
                [saveDict removeObjectForKey:key];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userDict = [[defaults objectForKey:current.username] mutableCopy];
                if(userDict == nil){
                    userDict = [[NSMutableDictionary alloc] init];
                }
                [userDict setObject:saveDict forKey:@"Save"];
                [defaults setObject:userDict forKey:current.username];
                [defaults synchronize];
            }
        }
        [self saveTimeStamp];
}

//
-(void) getTasks
{
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query whereKey:@"User" equalTo:current];
        query.cachePolicy = kPFCachePolicyNetworkOnly;
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if(!error){
               
                tasksDict = nil;
                tasksDict = [[NSMutableDictionary alloc] init];
                for(PFObject *task in tasks){
                    NSArray *keys = [saveDict allKeys];
                    for(NSString *key in keys){
                        if([key isEqualToString: task.objectId]){
                            NSDictionary *editTask = [saveDict objectForKey:key];
                            task[@"Name"] = [editTask objectForKey:@"Name"];
                            task[@"Date"] = [editTask objectForKey:@"Date"];
                            task[@"Time"] = [editTask objectForKey:@"Time"];
                            [task saveInBackground];
                        }
                    }
                    
                    [self cacheObjects:task];
                    [tasksArray addObject:task];
                    
                }
                [self saveCache];
                if([saveDict count] != 0){
                    [self clearSaves];
                }
            }
        [taskTable reloadData];
        }];
        [taskTable reloadData];
    
}

-(void) clearSaves{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
    if(userDict == nil){
        userDict = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *saves = [[NSMutableDictionary alloc] init];
    [userDict setObject:saves forKey:@"Save"];
    [defaults setObject:userDict forKey:[PFUser currentUser].username];
    [defaults synchronize];
}

-(void) saveCache{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
    if(userDict == nil){
        userDict = [[NSMutableDictionary alloc] init];
    }
    [userDict setObject:tasksDict forKey:@"Tasks"];
    [defaults setObject:userDict forKey:[PFUser currentUser].username];
    [defaults synchronize];
}

-(void)cacheObjects:(PFObject *)task{
    NSArray *keys = [task allKeys];
    NSMutableDictionary *taskDict = [[NSMutableDictionary alloc] init];
    for(NSString *key in keys){
        if([key isEqualToString:@"Date"] || [key isEqualToString:@"Name"] || [key isEqualToString:@"Time"]){
            [taskDict setObject:[task objectForKey:key] forKey:key];
        }
    }
    NSString *objectId = [task objectId];
    if(objectId != nil){
        [taskDict setObject:[task objectId] forKey:@"ObjectId"];
        [tasksDict setObject:taskDict forKey:[task objectId]];
        
    }else{
        [tasksDict setObject:taskDict forKey:[task valueForKey:@"Name"]];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tasksDict != nil){
        return [tasksDict count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if(cell != nil){
        if (tasksDict != nil){
            NSArray *keys = [tasksDict allKeys];
            NSMutableDictionary *taskDict = [tasksDict objectForKey:[keys objectAtIndex:indexPath.row]];
            cell.taskName = [taskDict objectForKey:@"Name"];
            cell.taskDate = [taskDict objectForKey:@"Date"];
            cell.taskTime = [taskDict objectForKey:@"Time"];
            [cell refreshCell];
            return cell;
        }
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
    NSInteger objectIndex = [self findObject:[tasksDict objectForKey:[[tasksDict allKeys] objectAtIndex:selectedTask.row]]];
    if(buttonIndex == [alertView cancelButtonIndex]){
        if(objectIndex != 100){
            if([self checkConnection]){
                [self saveTimeStamp];
                [[tasksArray objectAtIndex:objectIndex] deleteInBackground];
                [tasksArray removeObjectAtIndex:objectIndex];
            }else{
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
                if(userDict == nil){
                    userDict = [[NSMutableDictionary alloc] init];
                }
                NSMutableDictionary *deleteDict = [[userDict objectForKey:@"Save"] mutableCopy];
                if(deleteDict == nil){
                    deleteDict = [[NSMutableDictionary alloc] init];
                }
                NSMutableDictionary *taskDict = [[NSMutableDictionary alloc] init];
                PFObject *temp = [tasksArray objectAtIndex:objectIndex];
                NSArray *keys = [temp allKeys];
                for(NSString *key in keys){
                    if([key isEqualToString:@"Date"] || [key isEqualToString:@"Name"] || [key isEqualToString:@"Time"]){
                        [taskDict setObject:[temp objectForKey:key] forKey:key];
                    }
                }
                [taskDict setObject:@"Delete" forKey:@"Delete"];
                NSString *objectId = [temp objectId];
                [taskDict setObject:objectId forKey:@"ObjectId"];
                [saveDict setObject:taskDict forKey:[temp objectId]];
               
                [userDict setObject:saveDict forKey:@"Save"];
                [defaults setObject:userDict forKey:[PFUser currentUser].username];
                [defaults synchronize];
                [[tasksArray objectAtIndex:objectIndex] deleteEventually];
                [tasksArray removeObjectAtIndex:objectIndex];
                [self saveTimeStamp];
                userTimestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
            }
        }else{
            NSArray *saveKeys = [saveDict allKeys];
            for(NSString *saveKey in saveKeys){
                if([[[tasksDict objectForKey:[[tasksDict allKeys] objectAtIndex:selectedTask.row]] objectForKey:@"Name"] isEqualToValue:[[saveDict objectForKey:saveKey] objectForKey:@"Name"]]){
                    [saveDict removeObjectForKey:saveKey];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
                    if(userDict == nil){
                        userDict = [[NSMutableDictionary alloc] init];
                    }
                    [userDict setObject:saveDict forKey:@"Save"];
                    [defaults setObject:userDict forKey:[PFUser currentUser].username];
                    [defaults synchronize];
                    [self saveTimeStamp];
                }
            }
        }
            NSArray *keys = [tasksDict allKeys];
            tasksDict = [tasksDict mutableCopy];
            [tasksDict removeObjectForKey:[keys objectAtIndex:selectedTask.row]];
            [self saveCache];
        
            [taskTable reloadData];
        
    }else{
        AddItemViewController *addItem = [self.storyboard instantiateViewControllerWithIdentifier:@"addItem"];
        if([self checkConnection]){
            if(objectIndex != 100){
                [addItem setEditObject:[tasksArray objectAtIndex:objectIndex]];
            }else{
                [addItem setOfflineObject:[tasksDict objectForKey:[[tasksDict allKeys] objectAtIndex:selectedTask.row]]];
            }
        }else{
            [addItem setOfflineObject:[tasksDict objectForKey:[[tasksDict allKeys] objectAtIndex:selectedTask.row]]];
        }
        [self.navigationController pushViewController:addItem animated:YES];
    }
}

-(void)saveTimeStamp{
    PFQuery  *query = [PFQuery queryWithClassName:@"Changes"];
    [query whereKey:@"User" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSString *newTimeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];

        if([objects count] > 0){
            PFObject *temp = [objects objectAtIndex:0];
            temp[@"TimeStamp"] = newTimeStamp;
            [temp saveInBackground];
            userTimestamp = newTimeStamp;
        }else{
            PFObject *newTime = [PFObject objectWithClassName:@"Changes"];
            newTime[@"User"] = [PFUser currentUser].username;
            newTime[@"TimeStamp"] = newTimeStamp;
            [newTime saveInBackground];
            userTimestamp = newTimeStamp;
        }
    }];
   
}


-(IBAction)onClick:(id)sender{
    UIBarButtonItem *button = sender;
    if(button.tag == 0){
        [PFUser logOut];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (button.tag == 1){
        [self performSegueWithIdentifier:@"addItem" sender:self];
    }
}

-(NSInteger)findObject:(NSMutableDictionary *) cached{
    for(int i = 0; i<[tasksArray count]; i++){
        PFObject *task = [tasksArray objectAtIndex:i];
        if([task[@"Name"] isEqualToString:[cached objectForKey:@"Name"]]){
            return i;
        }
    }
    return 100;
}

-(BOOL)checkConnection{
    Reachability *network = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus status = [network currentReachabilityStatus];
    if(status == NotReachable){
        return NO;
    }else{
        return YES;
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

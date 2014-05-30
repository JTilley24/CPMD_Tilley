//
//  AddItemViewController.m
//  Things2Do
//
//  Created by Justin Tilley on 5/21/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "AddItemViewController.h"
#import "ListViewController.h"
#import "Reachability.h"
@interface AddItemViewController ()

@end

@implementation AddItemViewController
@synthesize editObject, offlineObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //Setup DatePicker and Check for Editing Task
    NSDate *current = [[NSDate alloc] init];
    [datePicker setMinimumDate:current];
    datePicker.timeZone = [NSTimeZone localTimeZone];
    NSDate *pickerDate = datePicker.date;
    dateFormat = [[NSDateFormatter alloc] init];
    if(dateFormat != nil)
    {
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
    }
    dateString = [dateFormat stringFromDate:pickerDate];
    dateText.text = dateString;
    [dateText setInputView:datePicker];
    [dateText setDelegate:self];
    if([self checkConnection]){
        if(editObject != nil){
            dateText.text = editObject[@"Date"];
            nameText.text = editObject[@"Name"];
            timeText.text = [editObject[@"Time"] stringValue];
        }
    }else{
        if (offlineObject != nil) {
            dateText.text = [offlineObject objectForKey:@"Date"];
            nameText.text = [offlineObject objectForKey:@"Name"];
            timeText.text = [[offlineObject objectForKey:@"Time"] stringValue];
        }
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//OnClick for Cancel and Done Button
-(IBAction)onClick:(id)sender
{
    UIButton *button = sender;
    if(button.tag == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (button.tag == 1){
        //Check Validation
        BOOL checkInput = [self validateInputs];
        if(checkInput){
            [self saveToParse];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            UIAlertView *valAlert = [[UIAlertView alloc] initWithTitle:@"Error" message: alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [valAlert show];
        }
    }
}

//Set Date from DatePicker
-(IBAction)onChange:(id)sender
{
    NSDate *pickerDate = datePicker.date;
    dateString = [dateFormat stringFromDate:pickerDate];
    dateText.text = dateString;
}

//Check for User Click Off of TextField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//Display DatePicker
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1){
        datePicker.hidden = NO;
    }
}

//Check for Selected TextField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0){
        [textField resignFirstResponder];
    }
    else if(textField.tag == 1){
        datePicker.hidden = YES;
    }else if(textField.tag == 2){
        int timeInt = textField.text.integerValue;
        if(timeInt >= 1 && timeInt <= 24){
            
        }else{
            UIAlertView *timeAlert = [[UIAlertView alloc] initWithTitle:@"Hours" message: @"Hours must be between 1 and 24!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeAlert show];
        }
    }
}

//Hide Keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//Validate TextFields
-(BOOL) validateInputs{
    BOOL validate = YES;
    alertString = [[NSMutableString alloc] init];
    if([nameText.text isEqualToString:@""]){
        validate = NO;
        [alertString appendString:[NSString stringWithFormat:@"Please Enter Name. \n"]];
    }
    
    if([timeText.text isEqualToString:@""]){
        validate = NO;
        [alertString appendString:@"Please Enter Time."];
    }
    
    return validate;
}

//Check if Editing Task and Save to Parse or Local Storage
- (void)saveToParse{
    //Save Edited Task to Parse or Local Storage
    if(editObject != nil){
        PFObject *object = editObject;
        object[@"Name"] = nameText.text;
        object[@"Date"] = dateText.text;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeInt = [formatter numberFromString:timeText.text];
        object[@"Time"] = timeInt;
        if([self checkConnection]){
            [object saveInBackground];
            [self saveTimeStamp];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *tasksDict = [[defaults objectForKey:@"Tasks"] mutableCopy];
            if(tasksDict == nil){
                tasksDict = [[NSMutableDictionary alloc] init];
            }
            [self saveObject:object :tasksDict: @"Tasks"];
        }else{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *saveDict = [[[defaults objectForKey:[PFUser currentUser].username] objectForKey:@"Save"] mutableCopy];
            if(saveDict == nil){
                saveDict = [[NSMutableDictionary alloc] init];
            }
            [self saveObject:object :saveDict :@"Save"];
            NSMutableDictionary *tasksDict = [[defaults objectForKey:@"Tasks"] mutableCopy];
            if(tasksDict == nil){
                tasksDict = [[NSMutableDictionary alloc] init];
            }
            [self saveObject:object :tasksDict: @"Tasks"];
        }
    //Save Offline Task to Local Storage
    }else if(offlineObject != nil){
        NSMutableDictionary *object = [offlineObject mutableCopy];
        [object setObject:nameText.text forKey:@"Name"];
        [object setObject:dateText.text forKey:@"Date"];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeInt = [formatter numberFromString:timeText.text];
        [object setObject:timeInt forKey:@"Time"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
        if(userDict == nil){
            userDict = [[NSMutableDictionary alloc] init];
        }
        NSMutableDictionary *saveDict = [[userDict objectForKey:@"Save"] mutableCopy];
        NSMutableDictionary *taskDict = [[userDict objectForKey:@"Tasks"] mutableCopy];
        if(saveDict == nil){
            saveDict = [[NSMutableDictionary alloc] init];
        }
        if(taskDict == nil){
            taskDict = [[NSMutableDictionary alloc] init];
        }
        NSString *objectId = [offlineObject objectForKey:@"ObjectId"];
        if(objectId != nil){
            [saveDict setObject:object forKey:objectId];
            [taskDict setObject:object forKey:objectId];
        }else{
            [saveDict setObject:object forKey:[object objectForKey:@"Name"]];
            [taskDict removeObjectForKey:[offlineObject objectForKey:@"Name"]];
            [taskDict setObject:object forKey:[object objectForKey:@"Name"]];
        }

        [userDict setObject:saveDict forKey:@"Save"];
        [userDict setObject:taskDict forKey:@"Tasks"];
        [defaults setObject:userDict forKey:[PFUser currentUser].username];
        [defaults synchronize];
        
    //Save New Task to Parse or Local Storage
    }else{
        PFObject *object = [PFObject objectWithClassName:@"Task"];
        PFUser *current = [PFUser currentUser];
        object[@"Name"] = nameText.text;
        object[@"Date"] = dateText.text;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeInt = [formatter numberFromString:timeText.text];
        object[@"Time"] = timeInt;
        object[@"User"] = current;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *userDict = [defaults objectForKey:[PFUser currentUser].username];
            if(userDict == nil){
                userDict = [[NSMutableDictionary alloc] init];
            }
        if([self checkConnection]){
            [object saveInBackground];
            [self saveTimeStamp];
        }else{
            NSMutableDictionary *saveDict = [[userDict objectForKey:@"Save"] mutableCopy];
            if(saveDict == nil){
                saveDict = [[NSMutableDictionary alloc] init];
            }
            [self saveObject:object :saveDict :@"Save"];
            
        }
        NSMutableDictionary *tasksDict = [userDict objectForKey:@"Tasks"];
        if(tasksDict == nil){
            tasksDict = [[NSMutableDictionary alloc] init];
        }
        [self saveObject:object :tasksDict: @"Tasks"];
    }
   
    

}

//Save Task to Local Storage
-(void)saveObject:(PFObject *)task :(NSMutableDictionary *)tasksDict :(NSString *)dictKey{
    NSArray *keys = [task allKeys];
    if(tasksDict != nil){
        tasksDict = [tasksDict mutableCopy];
    }else{
        tasksDict = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *taskDict = [[NSMutableDictionary alloc] init];
    for(NSString *key in keys){
        if([key isEqualToString:@"Date"] || [key isEqualToString:@"Name"] || [key isEqualToString:@"Time"]){
            [taskDict setObject:[task objectForKey:key] forKey:key];
        }
    }
    NSString *objectId = [task objectId];
    if(objectId != nil){
        [taskDict setObject:objectId forKey:@"ObjectId"];
        [tasksDict setObject:taskDict forKey:[task objectId]];
        
    }else{
        [tasksDict setObject:taskDict forKey:[task valueForKey:@"Name"]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userDict = [[defaults objectForKey:[PFUser currentUser].username] mutableCopy];
    if(userDict == nil){
        userDict = [[NSMutableDictionary alloc] init];
    }
    [userDict setObject:tasksDict forKey:dictKey];
    [defaults setObject:userDict forKey:[PFUser currentUser].username];
    [defaults synchronize];
}

//Save TimeStamp to Parse
-(void)saveTimeStamp{
    PFQuery  *query = [PFQuery queryWithClassName:@"Changes"];
    [query whereKey:@"User" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0){
            PFObject *temp = [objects objectAtIndex:0];
            temp[@"TimeStamp"] = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
            [temp saveInBackground];
        }else{
            PFObject *newTime = [PFObject objectWithClassName:@"Changes"];
            newTime[@"User"] = [PFUser currentUser].username;
            newTime[@"TimeStamp"] = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
            [newTime saveInBackground];
        }
    }];
}

//Check for Network Connection
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

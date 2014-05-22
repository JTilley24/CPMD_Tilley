//
//  AddItemViewController.m
//  Things2Do
//
//  Created by Justin Tilley on 5/21/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "AddItemViewController.h"
@interface AddItemViewController ()

@end

@implementation AddItemViewController
@synthesize editObject;
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
    if(editObject != nil){
        dateText.text = editObject[@"Date"];
        nameText.text = editObject[@"Name"];
        timeText.text = [editObject[@"Time"] stringValue];
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onClick:(id)sender
{
    UIButton *button = sender;
    if(button.tag == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (button.tag == 1){
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

-(IBAction)onChange:(id)sender
{
    NSDate *pickerDate = datePicker.date;
    dateString = [dateFormat stringFromDate:pickerDate];
    dateText.text = dateString;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1){
        datePicker.hidden = NO;
    }
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

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

- (void)saveToParse{
    
    if(editObject != nil){
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query getObjectInBackgroundWithId:[editObject objectId] block:^(PFObject *object, NSError *error) {
            if(error == nil){
                object[@"Name"] = nameText.text;
                object[@"Date"] = dateText.text;
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *timeInt = [formatter numberFromString:timeText.text];
                object[@"Time"] = timeInt;
                [object saveInBackground];
            }
        }];
    }else{
        PFObject *object = [PFObject objectWithClassName:@"Task"];
        object[@"Name"] = nameText.text;
        object[@"Date"] = dateText.text;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeInt = [formatter numberFromString:timeText.text];
        object[@"Time"] = timeInt;
        object[@"User"] = [PFUser currentUser];
        object.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [object saveInBackground];
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

//
//  ViewController.m
//  Things2Do
//
//  Created by Justin Tilley on 5/8/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    PFUser *current = [PFUser currentUser];
    if(current != nil){
        ListViewController *list = [self.storyboard instantiateViewControllerWithIdentifier:@"taskList"];
        [self.navigationController pushViewController:list animated:YES];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onClick:(id)sender
{
    UIButton *button = (UIButton*) sender;
    if(button.tag == 0){
        NSString *userName = userText.text;
        NSString *password = passText.text;
        [PFUser logInWithUsernameInBackground:userName password:password block:
         ^(PFUser *user, NSError *error) {
             if(user){
                 [self performSegueWithIdentifier:@"listSegue" sender:self];
             }else{
                 NSLog(@"Error");
             }
         }];
    }else if (button.tag == 1){
        if(loginButton.hidden == false){
            loginButton.hidden = true;
            emailText.hidden = false;
            emailLabel.hidden = false;
            cancelButton.hidden = false;
        }else{
            BOOL validate = true;
            PFUser *user = [PFUser user];
            NSString *username = userText.text;
            NSString *password = passText.text;
            NSString *email = emailText.text;
            if([username isEqualToString:@""]){
                validate = false;
            }
            if([password isEqualToString:@""]){
                validate = false;
            }
            if([email isEqualToString:@""]){
                validate = false;
            }
            if(validate == true){
                if([self validatePasssword]){
                    user.username = username;
                    user.password = password;
                    user.email = email;
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(!error){
                            ListViewController *list = [self.storyboard     instantiateViewControllerWithIdentifier:@"list"];
                            [self performSegueWithIdentifier:@"listSegue" sender:list];
                        }else{
                            NSString *errorText = @"";
                            if(error.code == kPFErrorAccountAlreadyLinked){
                                errorText = @"Account Already Linked.";
                            }else if (error.code == kPFErrorInvalidEmailAddress){
                                errorText = @"Email is Invalid.";
                            }else if(error.code == kPFErrorUsernameTaken){
                                errorText = @"Username Already Taken.";
                            }
                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [errorAlert show];
                        }
                    }];
                }else{
                    UIAlertView *passAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password must contain letters and number and 6 to 20 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [passAlert show];
                }
            }
            
        }
    }else if (button.tag == 2){
        loginButton.hidden = false;
        emailText.hidden = true;
        emailLabel.hidden = true;
        cancelButton.hidden = true;
    }
}

-(BOOL)validatePasssword{
   NSString *pattern = @"((?=.*\\d)(?=.*[a-z]).{6,20})";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if([predicate evaluateWithObject:passText.text]){
        return YES;
    }
    return NO;
}

-(IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

@end

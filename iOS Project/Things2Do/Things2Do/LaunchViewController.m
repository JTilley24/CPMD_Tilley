//
//  LaunchViewController.m
//  Things2Do
//
//  Created by Justin Tilley on 5/19/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "LaunchViewController.h"
#import "ListViewController.h"
@interface LaunchViewController ()

@end

@implementation LaunchViewController

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
    
    [super viewDidLoad];
    PFUser *current = [PFUser currentUser];
    if(current != nil){
        ListViewController *list = [self.storyboard instantiateViewControllerWithIdentifier:@"taskList"];
        [self.navigationController pushViewController:list animated:YES];
    }else{
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  LRContactListViewController.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRCRMListViewController.h"
#import "LRContactListViewController.h"
#import "LRContactListTableViewCell.h"
#import "LRMainClientPageViewController.h"
#import "LRAboutUSViewController.h"


@interface LRCRMListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *crmListTableView;
@property (strong, nonatomic) NSMutableArray *crmListArray;
@end

@implementation LRCRMListViewController

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
    self.crmListArray = [[NSMutableArray alloc] initWithObjects:@"Accounts",@"Covered Companies",@"Contacts",@"Document Library",@"@leerink", nil];
    [self.crmListTableView reloadData];
    self.crmListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Do any additional setup after loading the view.
    
    // do the navigation bar settings
    //self.navigationItem.title = @"Equity Research";

}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.crmListArray.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [tableView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];
    
    NSString *CellIdentifier = NSStringFromClass([LRContactListTableViewCell class]);
    LRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 0];
    }
    [cell fillDataForContactCellwithName:[self.crmListArray objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 2) {
        LRContactListViewController *aContactListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRContactListViewController class])];
        aContactListViewController.titleHeader = [self.crmListArray objectAtIndex:indexPath.row];
        //aMainClientListViewController.titleHeader = [self.crmListArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:aContactListViewController animated:TRUE];
        
    }
    else if(indexPath.row == 3) {
        
        LRMainClientPageViewController *aMainClientListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRMainClientPageViewController class])];
        //aMainClientListViewController.titleHeader = [self.crmListArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:aMainClientListViewController animated:TRUE];
    }
    else if(indexPath.row == 4) {
        LRAboutUSViewController *aAboutUsVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRAboutUSViewController class])];
        aAboutUsVC.tabBarItem.title = @"About Us";
        [self.navigationController pushViewController:aAboutUsVC animated:TRUE];
    }
       [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a [LRAppDelegate myStoryBoard]-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

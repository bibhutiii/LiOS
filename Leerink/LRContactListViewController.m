//
//  LRContactListViewController.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRContactListViewController.h"
#import "LRContactDetailViewController.h"
#import "LRContactListTableViewCell.h"

@interface LRContactListViewController ()
{
    NSArray *searchResults;
    CGSize tableContentSize;
}
@property (weak, nonatomic) IBOutlet UITableView *contactListTableView;
@property (strong, nonatomic) NSMutableArray *contactListArray;
@end

@implementation LRContactListViewController

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
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.titleHeader;
    // set the data source for contact list array
    self.contactListArray = [[NSMutableArray alloc] initWithObjects:@"Fidelity Management & Research",@"Putnam Investment Managemen",@"Loomis Sayles & Company",@"Granahan Investment Management",@"Frontier Capital Management",@"Gayland Partners",@"Harvard Management Co",@"Wellington Management Company",@"Janus Capital Group",@"Invesco Funds Group",@"Berger Associates",@"Denver Investment Advisors",@"David L. Babson & Co", nil];
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.contactListTableView.rowHeight];
    self.contactListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.contactListTableView.bounces = TRUE;
    [self.contactListTableView reloadData];
    tableContentSize = self.contactListTableView.contentSize;
    tableContentSize.height = tableContentSize.height + 350.0;
    
}
#pragma mark - search display controller delegate methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    searchResults = [self.contactListArray filteredArrayUsingPredicate:resultPredicate];
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        if(self.contactListTableView.hidden == TRUE) {
            self.contactListTableView.hidden = FALSE;
        }
    }
    else
    {
        self.contactListTableView.hidden = TRUE;
    }
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView = [[self searchDisplayController] searchResultsTableView];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    // tableView.contentSize = tableContentSize;
    
    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height - 44);
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:111.0/255.0 blue:140.0/255.0 alpha:1.0];
    
    
}
- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    if([controller.searchBar.text length] > 0) {
        UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
        
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height + 44);
    }
   
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.contactListTableView.hidden = FALSE;
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return self.contactListArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [tableView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];
    
    NSString *CellIdentifier = NSStringFromClass([LRContactListTableViewCell class]);
    
    LRContactListTableViewCell *cell = [self.contactListTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 0];
    }
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        [cell fillDataForContactCellwithName:[searchResults objectAtIndex:indexPath.row]];
    }
    else {
        [cell fillDataForContactCellwithName:[self.contactListArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LRContactDetailViewController *aContactDetailViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRContactDetailViewController class])];
    aContactDetailViewController.titleHeader = [self.contactListArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:aContactDetailViewController animated:TRUE];
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

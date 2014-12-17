//
//  LRdocumentTypeListViewController.m
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRSubMenuListController.h"
#import "LRContactListTableViewCell.h"
#import "LRAnalyst.h"
#import "LRSymbol.h"
#import "LRSector.h"
#import "LRDocumentTypeTableViewCell.h"
#import "LRDocumentListViewController.h"
#import "LRWebEngine.h"
#import "LRAuthorBioInfoViewController.h"

@interface LRSubMenuListController ()
{
    NSArray *searchResults;
    CGSize tableContentSize;
}
@property (weak, nonatomic) IBOutlet UITableView *analystsListTableView;

@property (nonatomic, assign) BOOL isSearchResultEmpty;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation LRSubMenuListController

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
    //
    self.isSearchResultEmpty = FALSE;
    self.isSearching = FALSE;
    // Do any additional setup after loading the view.
    self.delegate = [LRWebEngine defaultWebEngine];
    
    self.navigationItem.title = self.titleHeader;
    
    [self didLoadData];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:9.0/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
}
#pragma mark - Load the data into the table
- (void)didLoadData
{
    self.analystsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.analystsListTableView.rowHeight];
    self.analystsListTableView.bounces = TRUE;
    //
    [self.analystsListTableView reloadData];
    tableContentSize = self.analystsListTableView.contentSize;
    tableContentSize.height = tableContentSize.height + 350.0;
}
#pragma mark - search display controller delegate methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = nil;
    
    resultPredicate = [NSPredicate predicateWithFormat:@"DisplayName contains[c] %@", searchText];
    
    searchResults = [self.subMenuItemsArray filteredArrayUsingPredicate:resultPredicate];
    
    if([searchResults count] == 0)
    {
        self.isSearchResultEmpty = TRUE;
    }
    else {
        self.isSearchResultEmpty = FALSE;
    }
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.isSearching = TRUE;
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        if(self.analystsListTableView.hidden == TRUE) {
            self.analystsListTableView.hidden = FALSE;
        }
    }
    else
    {
        self.analystsListTableView.hidden = TRUE;
    }
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView = [[self searchDisplayController] searchResultsTableView];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    // tableView.contentSize = tableContentSize;
    
    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height);
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
    
    
}
- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    if([controller.searchBar.text length] > 0) {
        UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
        
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height + 44);
        
        tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
    }
    
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.analystsListTableView.hidden = FALSE;
    self.isSearching = FALSE;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.analystsListTableView.hidden = FALSE;
    self.isSearching = FALSE;
    [self.analystsListTableView reloadData];
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching == TRUE) {
        if(self.isSearchResultEmpty == TRUE)
            return 1;
        return [searchResults count];
        
    } else {
        return self.subMenuItemsArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRContactListTableViewCell class]);
    
    LRContactListTableViewCell *cell = [self.analystsListTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 1];
        cell.tag = indexPath.row;
        cell.delegate = self;
    }
    if (self.isSearching && self.isSearchResultEmpty == TRUE) {
        static NSString *cleanCellIdent = @"cleanCell";
        UITableViewCell *ccell = [tableView dequeueReusableCellWithIdentifier:cleanCellIdent];
        if (ccell == nil) {
            ccell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cleanCellIdent];
            ccell.textLabel.textColor = [UIColor whiteColor];
            ccell.userInteractionEnabled = NO;
        }
        ccell.textLabel.text = @"No Results";
        ccell.contentView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
        return ccell;
    }
    NSDictionary *aSubMenuDetailsDictionary = nil;
    if(self.isSearching) {
        aSubMenuDetailsDictionary = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        aSubMenuDetailsDictionary = [self.subMenuItemsArray objectAtIndex:indexPath.row];
    }
    NSString *aDocumentEncodedString = [aSubMenuDetailsDictionary objectForKey:@"IconByte"];
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];

    //NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:0];
    
    UIImage *iconImage = [UIImage imageWithData:data];

    [cell fillDataForMenuCellWithDisplayName:[aSubMenuDetailsDictionary objectForKey:@"DisplayName"] andIconImage:iconImage];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    NSDictionary *aMainMenuItemsDetailsDictionary = nil;
    if(self.isSearching) {
        aMainMenuItemsDetailsDictionary  = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        aMainMenuItemsDetailsDictionary  = [self.subMenuItemsArray objectAtIndex:indexPath.row];
    }
    
    NSMutableDictionary *aRequestDictionary = [NSMutableDictionary new];
    [aRequestDictionary setObject:[aMainMenuItemsDetailsDictionary objectForKey:@"MenuItemId"] forKey:@"MenuItemId"];
    [aRequestDictionary setObject:[aMainMenuItemsDetailsDictionary objectForKey:@"ParentMenuId"] forKey:@"ParentMenuId"];
    [aRequestDictionary setObject:@"50" forKey:@"TopCount"];
    
    if([self.returnTypeForMenu isEqualToString:@"SUBMENU"]) {
        [[LRWebEngine defaultWebEngine] sendRequestToGetSubMenuItemsWithContextInfo:aRequestDictionary forResponseBlock:^(NSDictionary *responseDictionary) {
            if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                if(![[responseDictionary objectForKey:@"Data"] isKindOfClass:([NSNull class])]) {
                    if(![[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isKindOfClass:([NSNull class])]) {
                        if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"SUBMENU"]) {
                            LRSubMenuListController *documentTypeListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRSubMenuListController class])];
                            documentTypeListViewController.subMenuItemsArray = [[responseDictionary objectForKey:@"Data"] objectForKey:@"SubMenus"];
                            documentTypeListViewController.titleHeader = [aMainMenuItemsDetailsDictionary objectForKey:@"DisplayName"];
                            documentTypeListViewController.returnTypeForMenu = [[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"];
                            [self.navigationController pushViewController:documentTypeListViewController animated:TRUE];
                        }
                        else if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"DOCLIST"]){
                            LRDocumentListViewController *documentListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentListViewController class])];
                            documentListViewController.isDocumentsFetchedForList = TRUE;
                            documentListViewController.returnTypeForMenu = [[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"];
                            documentListViewController.menuItemId = [aMainMenuItemsDetailsDictionary objectForKey:@"MenuItemId"];
                            documentListViewController.parentMenuItemId = [aMainMenuItemsDetailsDictionary objectForKey:@"ParentMenuId"];
                            
                            if ([[[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"] count] > 0) {
                                documentListViewController.documentsListArray = [[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"];
                            }
                            [self.navigationController pushViewController:documentListViewController animated:TRUE];
                        }
                    }
                }
                [LRUtility stopActivityIndicatorFromView:self.view];
            }
            else {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *aLogOutAlertView = nil;
                NSString *aMsgStr = nil;
                if(![[responseDictionary objectForKey:@"Message"] isKindOfClass:([NSNull class])]) {
                    aMsgStr = [responseDictionary objectForKey:@"Message"];
                }
                
                if(![[responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
                    aMsgStr = [responseDictionary objectForKey:@"Error"];
                }
                aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                              message:aMsgStr
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                    otherButtonTitles:nil, nil];
                
                [aLogOutAlertView show];
            }
            
        } errorHandler:^(NSError *errorString) {
            [LRUtility stopActivityIndicatorFromView:self.view];
            UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                       message:[errorString localizedDescription]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                             otherButtonTitles:nil, nil];
            [aLogOutAlertView show];
            
        }];
    }
    else if([self.returnTypeForMenu isEqualToString:@"DOCLIST"]) {
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - Show Bio information for Analyst
- (void)showBioInformationForSelectedAnalystwithTag:(int)iTag
{
    NSDictionary *aSubMenuDetailsDictionary = nil;
    if(self.isSearching) {
        aSubMenuDetailsDictionary = [searchResults objectAtIndex:iTag];
    }
    else {
        aSubMenuDetailsDictionary = [self.subMenuItemsArray objectAtIndex:iTag];
    }
    LRAuthorBioInfoViewController *authorBioInfoViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRAuthorBioInfoViewController class])];
    authorBioInfoViewController.authorInfo = [aSubMenuDetailsDictionary objectForKey:@"IconContent"];
    NSLog(@"%@",authorBioInfoViewController.authorInfo);
    [self.navigationController pushViewController:authorBioInfoViewController animated:TRUE];
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if([self.delegate respondsToSelector:@selector(cancelaNetWorkOperation)]) {
        [self.delegate cancelaNetWorkOperation];
    }
    [super viewWillDisappear:TRUE];
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

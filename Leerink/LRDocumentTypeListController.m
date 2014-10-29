//
//  LRdocumentTypeListViewController.m
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRDocumentTypeListController.h"
#import "LRGetAnalystService.h"
#import "LRContactListTableViewCell.h"
#import "LRAnalyst.h"
#import "LRGetSymbolService.h"
#import "LRSymbol.h"
#import "LRGetSectorService.h"
#import "LRSector.h"
#import "LRDocumentTypeTableViewCell.h"
#import "LRDocumentListViewController.h"
#import "LRWebEngine.h"

@interface LRDocumentTypeListController ()
{
    NSArray *searchResults;
    CGSize tableContentSize;
}
@property (weak, nonatomic) IBOutlet UITableView *analystsListTableView;
@property (strong, nonatomic) NSMutableArray *analystsListArray;

@end

@implementation LRDocumentTypeListController

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
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    // Do any additional setup after loading the view.
    self.delegate = [LRWebEngine defaultWebEngine];

    self.navigationItem.title = self.titleHeader;
    
    switch (self.eDocumentType)
    {
        case eLRDocumentAnalyst:
        {
            [[LRWebEngine defaultWebEngine] sendRequestToGetAnalystsWithResponseDataBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    [self didLoadData];
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[responseDictionary objectForKey:@"Error"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                }
                
            } errorHandler:^(NSError *error) {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                         message:[error description]
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               otherButtonTitles:nil, nil];
                [errorAlertView show];

                DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                     [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                
            }];
        }
            break;
        case eLRDocumentSector:
        {
            [[LRWebEngine defaultWebEngine] sendRequestToGetSectorsWithResponseDataBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    [self didLoadData];
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[responseDictionary objectForKey:@"Error"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                }
                
            } errorHandler:^(NSError *error) {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                         message:[error description]
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               otherButtonTitles:nil, nil];
                [errorAlertView show];

                DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                     [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                
            }];
        }
            break;
        case eLRDocumentSymbol:
        {
            [[LRWebEngine defaultWebEngine] sendRequestToGetSymbolsWithResponseDataBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    [self didLoadData];
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[responseDictionary objectForKey:@"Error"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];

                }
                
            } errorHandler:^(NSError *error) {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                         message:[error description]
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               otherButtonTitles:nil, nil];
                [errorAlertView show];

                DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                     [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                
            }];
            
        }
            break;
            
        default:
            break;
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
}
#pragma mark - Load the data into the table
- (void)didLoadData
{
        switch (self.eDocumentType)
        {
            case eLRDocumentAnalyst:
            {
                self.analystsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRAnalyst" withPredicate:nil, nil];
                
                NSSortDescriptor *zoneSegmentsDescriptor = [[NSSortDescriptor alloc]
                                                            initWithKey:@"lastName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                NSArray *sortDescriptors = @[zoneSegmentsDescriptor];
                
                self.analystsListArray = (NSMutableArray *)[self.analystsListArray sortedArrayUsingDescriptors:sortDescriptors];
                
            }
                break;
            case eLRDocumentSector:
            {
                self.analystsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSector" withPredicate:nil, nil];
                
                NSSortDescriptor *zoneSegmentsDescriptor = [[NSSortDescriptor alloc]
                                                            initWithKey:@"sectorName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                NSArray *sortDescriptors = @[zoneSegmentsDescriptor];
                
                self.analystsListArray = (NSMutableArray *)[self.analystsListArray sortedArrayUsingDescriptors:sortDescriptors];
                
            }
                break;
            case eLRDocumentSymbol:
            {
                self.analystsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSymbol" withPredicate:nil, nil];
                
                NSSortDescriptor *zoneSegmentsDescriptor = [[NSSortDescriptor alloc]
                                                            initWithKey:@"NameSymbol" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                NSArray *sortDescriptors = @[zoneSegmentsDescriptor];
                
                self.analystsListArray = (NSMutableArray *)[self.analystsListArray sortedArrayUsingDescriptors:sortDescriptors];
                
                
            }
                break;
                
            default:
                break;
        }
        
        
      //  [LRUtility stopActivityIndicatorFromView:self.view];
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
    switch (self.eDocumentType)
    {
        case eLRDocumentAnalyst:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"lastName contains[c] %@", searchText];
        }
            break;
        case eLRDocumentSector:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"sectorName contains[c] %@", searchText];
        }
            break;
        case eLRDocumentSymbol:
        {
            resultPredicate = [NSPredicate predicateWithFormat:@"NameSymbol contains[c] %@", searchText];
        }
            break;
            
        default:
            break;
    }
    searchResults = [self.analystsListArray filteredArrayUsingPredicate:resultPredicate];
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
    self.analystsListTableView.hidden = FALSE;
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
        return self.analystsListArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{    
    NSString *CellIdentifier = NSStringFromClass([LRContactListTableViewCell class]);
    
    LRContactListTableViewCell *cell = [self.analystsListTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 0];
    }
    
    switch (self.eDocumentType)
    {
        case eLRDocumentAnalyst:
        {
            LRAnalyst *analyst = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                analyst = [searchResults objectAtIndex:indexPath.row];
            }
            else {
                analyst = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            [cell fillDataForContactCellwithName:[analyst.lastName stringByAppendingString:[NSString stringWithFormat:@", %@",analyst.firstName]]];
        }
            break;
        case eLRDocumentSector:
        {
            LRSector *aSector = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                aSector = [searchResults objectAtIndex:indexPath.row];
                
            }
            else {
                aSector = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            [cell fillDataForContactCellwithName:aSector.sectorName];
        }
            break;
        case eLRDocumentSymbol:
        {
            LRSymbol *aSymbol = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                aSymbol = [searchResults objectAtIndex:indexPath.row];
                
            }
            else {
                aSymbol = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            [cell fillDataForContactCellwithName:aSymbol.nameSymbol];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LRDocumentListViewController *documentListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentListViewController class])];
    documentListViewController.documentType = self.eDocumentType;
    switch (self.eDocumentType)
    {
        case eLRDocumentAnalyst:
        {
            LRAnalyst *analyst = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                analyst = [searchResults objectAtIndex:indexPath.row];
            }
            else {
                analyst = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            documentListViewController.contextInfo = analyst;
            documentListViewController.documentTypeId = [analyst.userId intValue];
            documentListViewController.documentListType = eLRDocumentListAnalyst;

        }
            break;
        case eLRDocumentSector:
        {
            LRSector *aSector = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                aSector = [searchResults objectAtIndex:indexPath.row];
                
            }
            else {
                aSector = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            documentListViewController.documentTypeId = [aSector.researchID intValue];
            documentListViewController.contextInfo = aSector;
            documentListViewController.documentListType = eLRDocumentListSector;

        }
            break;
        case eLRDocumentSymbol:
        {
            LRSymbol *aSymbol = nil;
            if(tableView == self.searchDisplayController.searchResultsTableView) {
                aSymbol = [searchResults objectAtIndex:indexPath.row];
                
            }
            else {
                aSymbol = [self.analystsListArray objectAtIndex:indexPath.row];
            }
            documentListViewController.documentTypeId = [aSymbol.tickerID intValue];
            documentListViewController.contextInfo = aSymbol;
            documentListViewController.documentListType = eLRDocumentListSymbol;
        }
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:documentListViewController animated:TRUE];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if([self.delegate respondsToSelector:@selector(cancelaNetWorkOperation)]) {
        [self.delegate cancelaNetWorkOperation];
    }
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

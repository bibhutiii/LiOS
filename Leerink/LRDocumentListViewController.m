//
//  LRDocumentListViewController.m
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRDocumentListViewController.h"
#import "LRLoginViewController.h"
#import "LRDocumentTypeTableViewCell.h"
#import "LRGetDocumentListService.h"
#import "LRDocument.h"
#import "LRDocumentViewController.h"
#import "LRWebEngine.h"

@interface LRDocumentListViewController ()
{
    CGSize tableContentSize;
}
@property (weak, nonatomic) IBOutlet UITableView *documentsListTable;
@property (strong, nonatomic) NSMutableArray *documentsListArray;
@property (strong, nonatomic) NSMutableArray *selectedDocumentsArray;
@property (strong, nonatomic) NSMutableArray *existingDocIdsArray;
@end

@implementation LRDocumentListViewController

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
    NSMutableDictionary *aContextInfoDictionary = [NSMutableDictionary new];
    self.selectedDocumentsArray = [NSMutableArray new];
    
    // fetch the existing docIds from plist
    self.existingDocIdsArray = [NSMutableArray arrayWithArray:[LRAppDelegate fetchDataFromPlist]];
    
    // do the navigation bar settings
    self.navigationItem.title = @"Documents";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    self.delegate = [LRWebEngine defaultWebEngine];
    if(self.isDocumentsFetchedForList == TRUE) {
        
        [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentListForListWithwithContextInfo:self.contextInfo forResponseDataBlock:^(NSDictionary *responseDictionary) {
            if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                [LRUtility stopActivityIndicatorFromView:self.view];
                self.documentsListArray = [NSMutableArray new];
                NSArray *listOfDocuments = [responseDictionary objectForKey:@"DataList"];
                    for (NSDictionary *aDocumentDictionary in listOfDocuments) {
                        [self.documentsListArray addObject:aDocumentDictionary];
                    }
                    self.documentsListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                    [self.searchDisplayController.searchResultsTableView setRowHeight:self.documentsListTable.rowHeight];
                    self.documentsListTable.bounces = TRUE;
                    //
                    [self.documentsListTable reloadData];
                    tableContentSize = self.documentsListTable.contentSize;
                    tableContentSize.height = tableContentSize.height + 150.0;
                
                
                }
            else {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *emptyDataAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[responseDictionary objectForKey:@"Error"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                [emptyDataAlertView show];

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
    else {
        
        switch (self.documentType) {
            case eLRDocumentAnalyst:
            {
                [aContextInfoDictionary setObject:self.contextInfo forKey:@"AnalystDocumentList"];
                [aContextInfoDictionary setObject:[NSNumber numberWithInt:self.documentListType] forKey:@"DocumentTypeList"];
                [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentListWithwithContextInfo:aContextInfoDictionary forResponseDataBlock:^(NSDictionary *responseDictionary) {
                    if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                        [LRUtility stopActivityIndicatorFromView:self.view];
                        [self didLoadData];
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
                [aContextInfoDictionary setObject:self.contextInfo forKey:@"SectorDocumentList"];
                [aContextInfoDictionary setObject:[NSNumber numberWithInt:self.documentListType] forKey:@"DocumentTypeList"];
                
                [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentListWithwithContextInfo:aContextInfoDictionary forResponseDataBlock:^(NSDictionary *responseDictionary) {
                    if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                        [LRUtility stopActivityIndicatorFromView:self.view];
                        [self didLoadData];
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
                [aContextInfoDictionary setObject:self.contextInfo forKey:@"SymbolDocumentList"];
                [aContextInfoDictionary setObject:[NSNumber numberWithInt:self.documentListType] forKey:@"DocumentTypeList"];
                
                [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentListWithwithContextInfo:aContextInfoDictionary forResponseDataBlock:^(NSDictionary *responseDictionary) {
                    if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                        [LRUtility stopActivityIndicatorFromView:self.view];
                        [self didLoadData];
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
    }
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - Load the data into the table
- (void)didLoadData
{
    
    switch (self.documentType)
    {
        case eLRDocumentAnalyst:
        {
            self.documentsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"analyst.userId == %d",self.documentTypeId, nil];
        }
            break;
        case eLRDocumentSector:
        {
            self.documentsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"sector.researchID == %d",self.documentTypeId, nil];
        }
            break;
        case eLRDocumentSymbol:
        {
            self.documentsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"symbol.tickerID == %d",self.documentTypeId, nil];
        }
            break;
            
        default:
            break;
    }
    
    //   NSSortDescriptor *zoneSegmentsDescriptor = [[NSSortDescriptor alloc]
    //                                         initWithKey:@"documentTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    //  NSArray *sortDescriptors = @[zoneSegmentsDescriptor];
    
    //  self.documentsListArray = (NSMutableArray *)[self.documentsListArray sortedArrayUsingDescriptors:sortDescriptors];
    
    [LRUtility stopActivityIndicatorFromView:self.view];
    self.documentsListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.documentsListTable.rowHeight];
    self.documentsListTable.bounces = TRUE;
    //
    [self.documentsListTable reloadData];
    tableContentSize = self.documentsListTable.contentSize;
    tableContentSize.height = tableContentSize.height + 150.0;
    
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"row count--%d",(unsigned)self.documentsListArray.count);
    return self.documentsListArray.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRDocumentTypeTableViewCell class]);
    LRDocumentTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRDocumentTypeTableViewCell *)[bundle objectAtIndex: 0];
    }
    if(self.isDocumentsFetchedForList == TRUE) {
        
        NSDictionary *aDocumentDetailsDictionary = [self.documentsListArray objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        // check if the document hsa been selected and reload the table accordingly.
        if([self.selectedDocumentsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:@"02-Sep-2014" andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE];
        }
        else {
            if([self.existingDocIdsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:@"02-Sep-2014" andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE];
            }
            else {
                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:@"02-Sep-2014" andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:FALSE];
            }
        }
    }
    else {
        LRDocument *aDocument = (LRDocument *)[self.documentsListArray objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        // check if the document hsa been selected and reload the table accordingly.
        if([self.selectedDocumentsArray containsObject:aDocument.documentID]) {
            [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor andisDocumentSelected:TRUE];
            
        }
        else {
            if([self.existingDocIdsArray containsObject:aDocument.documentID]) {
                [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor andisDocumentSelected:TRUE];
            }
            else {
                [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor andisDocumentSelected:FALSE];
            }
            //   [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor andisDocumentSelected:FALSE];
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRDocumentViewController *documentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
    
    if(self.isDocumentsFetchedForList == TRUE) {
        NSDictionary *aDocumentDetailsDictionary = [self.documentsListArray objectAtIndex:indexPath.row];
        documentViewController.documentId = [aDocumentDetailsDictionary objectForKey:@"DocumentID"];
    }
    else {
        LRDocument *aDocument = (LRDocument *)[self.documentsListArray objectAtIndex:indexPath.row];
        //documentViewController.documentPath = @"D:\\Release\\test.txt";
        documentViewController.documentTitleToBeSavedAsPdf = aDocument.documentTitle;
        documentViewController.documentId = aDocument.documentID;
    }
    [self.navigationController pushViewController:documentViewController animated:TRUE];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
- (void)selectDocumentForRowWithIndex:(int )index
{
    if(self.isDocumentsFetchedForList == TRUE) {
        NSDictionary *aDocumentDetailsDictionary = [self.documentsListArray objectAtIndex:index];
        if([self.selectedDocumentsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
            [self.selectedDocumentsArray removeObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]];
        }
        else {
            if([self.existingDocIdsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
                [self.existingDocIdsArray removeObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]];
            }
            else {
                [self.selectedDocumentsArray addObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]];
            }
        }
    }
    else {
        LRDocument *aDocument = [self.documentsListArray objectAtIndex:index];
        if([self.selectedDocumentsArray containsObject:aDocument.documentID]) {
            [self.selectedDocumentsArray removeObject:aDocument.documentID];
        }
        else {
            if([self.existingDocIdsArray containsObject:aDocument.documentID]) {
                [self.existingDocIdsArray removeObject:aDocument.documentID];
            }
            else {
                [self.selectedDocumentsArray addObject:aDocument.documentID];
            }
        }
    }
    if([self.selectedDocumentsArray count] > 0) {
        SEL addToCartButton = sel_registerName("AddToCart");
        UIBarButtonItem *cartButton = [[UIBarButtonItem alloc] initWithImage:nil style:0 target:self action:addToCartButton];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
        cartButton.title = @"Add to Cart";
        self.navigationItem.rightBarButtonItem = cartButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:[LRAppDelegate fetchPathOfCustomPlist]];
        
        //here add elements to data file and write data to file
        [data setObject:self.existingDocIdsArray forKey:@"docIds"];
        
        [data writeToFile:[LRAppDelegate fetchPathOfCustomPlist] atomically:YES];
    }
    [self.documentsListTable reloadData];
}
- (void)AddToCart
{
    UIAlertView *itemsAddedToCartAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                             message:@"Items Added to Cart. Please Return to Home Screen to Send Cart to Yourself"
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles:nil, nil];
    itemsAddedToCartAlertView.tag = 500;
    
    [itemsAddedToCartAlertView show];
    
    //
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 500){
        if(buttonIndex == 0) {
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: [LRAppDelegate fetchPathOfCustomPlist]];
            
            if(self.existingDocIdsArray.count > 0) {
                [self.selectedDocumentsArray addObjectsFromArray:self.existingDocIdsArray];
            }
            //here add elements to data file and write data to file
            [data setObject:self.selectedDocumentsArray forKey:@"docIds"];
            
            [data writeToFile:[LRAppDelegate fetchPathOfCustomPlist] atomically:YES];
            
            for (NSString *docId in self.existingDocIdsArray) {
                if([self.selectedDocumentsArray containsObject:docId]) {
                    [self.selectedDocumentsArray removeObject:docId];
                }
            }
        }
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

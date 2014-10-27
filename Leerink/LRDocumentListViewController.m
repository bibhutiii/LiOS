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
    // do the navigation bar settings
    self.navigationItem.title = @"Documents";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    self.delegate = [LRWebEngine defaultWebEngine];

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
    // Do any additional setup after loading the view.
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
    
    LRDocument *aDocument = (LRDocument *)[self.documentsListArray objectAtIndex:indexPath.row];
    [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRDocument *aDocument = (LRDocument *)[self.documentsListArray objectAtIndex:indexPath.row];
    
    LRDocumentViewController *documentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
    //documentViewController.documentPath = @"D:\\Release\\test.txt";
    documentViewController.documentTitleToBeSavedAsPdf = aDocument.documentTitle;
    documentViewController.documentPath = aDocument.documentPath;
    
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

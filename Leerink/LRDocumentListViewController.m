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
#import "LRGetDocumentService.h"
#import "LRDocument.h"

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
    // do the navigation bar settings
    self.navigationItem.title = @"Documents";
    LRGetDocumentService *aGetDocumentService = nil;
    aGetDocumentService = [[LRGetDocumentService alloc] initWithURL:[NSURL URLWithString:@"http://10.0.100.40:8081/iOS_QA/Service1.svc?singleWsdl"]];
    aGetDocumentService.delegate = self;
    aGetDocumentService.documentType = self.documentType;
    aGetDocumentService.documentTypeId = self.documentTypeId;
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    switch (self.documentType) {
        case eLRDocumentAnalyst:
        {
            [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
                
            } withDocumentType:@"AnalystID" andId:self.documentTypeId];
        }
            break;
        case eLRDocumentSector:
        {
            [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
                
            } withDocumentType:@"researchID" andId:self.documentTypeId];
        }
            break;
        case eLRDocumentSymbol:
        {
            [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
                
            } withDocumentType:@"tickerID" andId:self.documentTypeId];
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
    
    NSSortDescriptor *zoneSegmentsDescriptor = [[NSSortDescriptor alloc]
                                                initWithKey:@"documentTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[zoneSegmentsDescriptor];
    
    self.documentsListArray = (NSMutableArray *)[self.documentsListArray sortedArrayUsingDescriptors:sortDescriptors];

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
    return self.documentsListArray.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [tableView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];

    
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
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone?@"Main_iPhone":@"Main_iPad" bundle:nil];
    //LRLoginViewController *aAboutUsVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
   // [self.navigationController pushViewController:aAboutUsVC animated:TRUE];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
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

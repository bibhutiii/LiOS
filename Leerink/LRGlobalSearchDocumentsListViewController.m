//
//  LRGlobalSearchDocumentsListViewController.m
//  Leerink
//
//  Created by Ashish on 17/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRGlobalSearchDocumentsListViewController.h"
#import "LRDocumentTypeTableViewCell.h"
#import "LRDocumentViewController.h"
#import "LRWebEngine.h"
#import "FPPopoverController.h"
#import "LROpenLinksInWebViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface LRGlobalSearchDocumentsListViewController ()
{
    NSArray *searchResults;
    CGSize tableContentSize;
}

@property (weak, nonatomic) IBOutlet UITableView *globalSearchDocumentListTable;
@property (strong, nonatomic) NSMutableArray *selectedDocumentsArray;
@property (strong, nonatomic) NSMutableArray *existingDocIdsArray;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) int documentsFetchCount;
@property (strong, nonatomic) FPPopoverController *popover;
@property (assign, nonatomic) BOOL isSearchResultEmpty;
@property (assign, nonatomic) BOOL showMoreOption;

@end


@implementation LRGlobalSearchDocumentsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isSearching = FALSE;
    self.isSearchResultEmpty = FALSE;
    self.documentsFetchCount = 50;
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
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:9.0/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self didLoadData];
}
#pragma mark - Load the data into the table
- (void)didLoadData
{
    [LRUtility stopActivityIndicatorFromView:self.view];
    if(self.globalSearchDocumentsListArray.count == 0) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:@"No Documents available"
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];
        
    }
    else {
        if(self.documentsFetchCount > self.globalSearchDocumentsListArray.count)
            self.showMoreOption = FALSE;
        else
            self.showMoreOption = TRUE;
        
        self.globalSearchDocumentListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.searchDisplayController.searchResultsTableView setRowHeight:self.globalSearchDocumentListTable.rowHeight];
        self.globalSearchDocumentListTable.bounces = TRUE;
        //
        [self.globalSearchDocumentListTable reloadData];
        tableContentSize = self.globalSearchDocumentListTable.contentSize;
        tableContentSize.height = tableContentSize.height + 50.0;
    }
    
}

#pragma mark - search display controller delegate methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.globalSearchDocumentListTable.hidden = FALSE;
    self.isSearching = FALSE;
    [self.globalSearchDocumentListTable reloadData];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = nil;
    resultPredicate = [NSPredicate predicateWithFormat:@"DocumentTitle contains[c] %@", searchText];
    searchResults = [self.globalSearchDocumentsListArray filteredArrayUsingPredicate:resultPredicate];
    if(searchResults.count == 0){
        self.isSearchResultEmpty = TRUE;
    }
    else
        self.isSearchResultEmpty = FALSE;
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.isSearching = TRUE;
    [self filterContentForSearchText:searchString
                               scope:nil];
    
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        if(self.globalSearchDocumentListTable.hidden == TRUE) {
            self.globalSearchDocumentListTable.hidden = FALSE;
        }
    }
    else
    {
        self.globalSearchDocumentListTable.hidden = TRUE;
    }
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
    //  tableView.frame = CGRectMake(tableView.frame.origin.x, self.globalSearchDocumentListTable.frame.origin.y - 44, tableView.frame.size.width, self.globalSearchDocumentListTable.frame.size.height - 44);
}
- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    
    tableView.frame = CGRectMake(tableView.frame.origin.x, self.globalSearchDocumentListTable.frame.origin.y - 44, tableView.frame.size.width, self.globalSearchDocumentListTable.frame.size.height);
    tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [tableView setContentInset:UIEdgeInsetsZero];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.globalSearchDocumentListTable.hidden = FALSE;
    self.isSearching = FALSE;
    [self.globalSearchDocumentListTable reloadData];
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        NSLog(@"row count--%d",(unsigned)searchResults.count);
        
        if(self.isSearchResultEmpty == TRUE) {
            return 1;
        }
        return [searchResults count];
        
    } else {
        NSLog(@"row count--%d",(unsigned)self.globalSearchDocumentsListArray.count);
        
        if(self.showMoreOption == TRUE)
            return self.globalSearchDocumentsListArray.count + 1;
        return self.globalSearchDocumentsListArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRDocumentTypeTableViewCell class]);
    LRDocumentTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        if(indexPath.row == self.globalSearchDocumentsListArray.count && self.isSearching == FALSE) {
            cell = (LRDocumentTypeTableViewCell *)[bundle objectAtIndex: 1];
        }
        else {
            cell = (LRDocumentTypeTableViewCell *)[bundle objectAtIndex: 0];
        }
    }
    if(self.isSearching) {
        
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
        NSDictionary *aDocumentDetailsDictionary = [searchResults objectAtIndex:indexPath.row];
        NSString *pdfURL = [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
        BOOL showTextOnlyIcon = ([pdfURL isEqualToString:@"pdf"]) ? TRUE : FALSE;
        
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        // check if the document hsa been selected and reload the table accordingly.
        NSArray *dateArray = [[aDocumentDetailsDictionary objectForKey:@"UpdateDate"] componentsSeparatedByString:@"T"];
        NSString *dateString = nil;
        if(dateArray.count > 0) {
            dateString = [dateArray objectAtIndex:0];
        }
        else {
            dateString = @" ";
        }
        CFStringRef fileExtension = (__bridge CFStringRef) [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        BOOL isFileTypeAudio = FALSE;
        if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) {
            NSLog(@"It's Audio");
            isFileTypeAudio = TRUE;
        }

        // check if the document hsa been selected and reload the table accordingly.
        if([self.selectedDocumentsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
            if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                    if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                        [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                    }
                    else {
                        [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:TRUE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                    }
                }
                
            }
            else {
                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
            }
            
        }
        else {
            if([self.existingDocIdsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
                if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                    if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                        if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                        else {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:TRUE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                    }
                }
                else {
                    [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                }
            }
            else {
                if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                    if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                        if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:FALSE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                        else {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:FALSE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                    }
                }
                else {
                    [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:FALSE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                }
            }
            //   [cell fillDataForDocumentCellwithTitle:aDocument.documentTitle andDateTime:@"02-Sep-2014" andAuthor:aDocument.documentAuthor andisDocumentSelected:FALSE];
        }
    }
    else {
        if(indexPath.row != self.globalSearchDocumentsListArray.count) {
            NSDictionary *aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:indexPath.row];
            NSString *pdfURL = [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
            BOOL showTextOnlyIcon = ([pdfURL isEqualToString:@"pdf"]) ? TRUE : FALSE;
            NSArray *dateArray = [[aDocumentDetailsDictionary objectForKey:@"UpdateDate"] componentsSeparatedByString:@"T"];
            NSString *dateString = nil;
            if(dateArray.count > 0) {
                dateString = [dateArray objectAtIndex:0];
            }
            else {
                dateString = @" ";
            }
            cell.delegate = self;
            cell.tag = indexPath.row;
            CFStringRef fileExtension = (__bridge CFStringRef) [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            BOOL isFileTypeAudio = FALSE;
            if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) {
                NSLog(@"It's Audio");
                isFileTypeAudio = TRUE;
            }
            // check if the document hsa been selected and reload the table accordingly.
            if([self.selectedDocumentsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
                if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                    if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                        if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                        else {
                            [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:TRUE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                        }
                    }
                    
                }
                else {
                    [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                }
                
            }
            else {
                if([self.existingDocIdsArray containsObject:[aDocumentDetailsDictionary objectForKey:@"DocumentID"]]) {
                    if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                        if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                            if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                            }
                            else {
                                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:TRUE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                            }
                        }
                    }
                    else {
                        [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:TRUE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                    }
                }
                else {
                    if(![[aDocumentDetailsDictionary objectForKey:@"Authors"] isKindOfClass:([NSNull class])]) {
                        if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] > 0) {
                            if([[aDocumentDetailsDictionary objectForKey:@"Authors"] count] == 1) {
                                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[[[aDocumentDetailsDictionary objectForKey:@"Authors"] objectAtIndex:0] objectForKey:@"AuthorName"] andisDocumentSelected:FALSE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                            }
                            else {
                                [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:@"" andisDocumentSelected:FALSE hasMultipleAuthors:TRUE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                            }
                        }
                    }
                    else {
                        [cell fillDataForDocumentCellwithTitle:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] andDateTime:dateString andAuthor:[aDocumentDetailsDictionary objectForKey:@"Author"] andisDocumentSelected:FALSE hasMultipleAuthors:FALSE showTextOnlyIcon:showTextOnlyIcon isFileTypeAudio:isFileTypeAudio];
                    }
                }
            }
        }
    }
    
    
    return cell;
}
- (void)infoForAuthorsSelected:(id)sender withTag:(int)iTag
{
    CGFloat scrollViewContentSize = 0.0;
    UIViewController *aPopController = [[UIViewController alloc] init];
    aPopController.view.frame = CGRectMake(0, 0, 300, 100);
    aPopController.view.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:111.0/255.0 blue:140.0/255.0 alpha:1.0];
    
    
    UIScrollView *aSCrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, aPopController.view.frame.size.width, 75)];
    aSCrolView.scrollEnabled = TRUE;
    aSCrolView.backgroundColor = [UIColor clearColor];
    
    self.popover = [[FPPopoverController alloc] initWithViewController:aPopController];
    self.popover.arrowDirection = FPPopoverArrowDirectionRight;
    self.popover.contentSize = CGSizeMake(300,120);
    self.popover.arrowDirection = FPPopoverArrowDirectionDown;
    
    UILabel *aTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 200, 21)];
    aTitleLabel.text = @"Authors";
    aTitleLabel.textColor = [UIColor whiteColor];
    [aSCrolView addSubview:aTitleLabel];
    scrollViewContentSize = scrollViewContentSize + aTitleLabel.frame.size.height;
    
    NSDictionary *aDocumentDetailsDictionary = nil;
    if(self.isSearching) {
        aDocumentDetailsDictionary = [searchResults objectAtIndex:iTag];
    }
    else {
        aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:iTag];
    }
    NSArray *authorsArray = [aDocumentDetailsDictionary objectForKey:@"Authors"];
    
    CGFloat height = aTitleLabel.frame.size.height;
    if([authorsArray count] > 0) {
        for (NSDictionary *authorDetails in authorsArray) {
            
            UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 10, 200, 21)];
            authorLabel.text = [authorDetails objectForKey:@"AuthorName"];
            authorLabel.textColor = [UIColor whiteColor];
            [aSCrolView addSubview:authorLabel];
            height = height + authorLabel.frame.size.height;
            scrollViewContentSize = scrollViewContentSize + authorLabel.frame.size.height + 5;
            //[authorDetails objectForKey:@"AuthorName"];
        }
        aSCrolView.contentSize = CGSizeMake(300, scrollViewContentSize);
        [aPopController.view addSubview:aSCrolView];
    }
    //the popover will be presented from the okButton view
    [self.popover presentPopoverFromView:sender];
    
}
- (void)showTextOnlyVersionOfTheDocumentWithTag:(int)iTag {
    LROpenLinksInWebViewController *aOpenLinksInWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LROpenLinksInWebViewController class])];
    NSDictionary *aDocumentDetailsDictionary = nil;
    
    if(self.isSearching) {
        aDocumentDetailsDictionary = [searchResults objectAtIndex:iTag];
    }
    else {
        aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:iTag];
    }
    aOpenLinksInWebViewController.linkURL = [aDocumentDetailsDictionary objectForKey:@"PlainTextURL"];
    aOpenLinksInWebViewController.isLinkFromLogin = FALSE;
    [self.navigationController pushViewController:aOpenLinksInWebViewController animated:TRUE];
    
}
- (void)showPDFOnlyVersionOfTheDocumentWithTag:(int)iTag {
    LROpenLinksInWebViewController *aOpenLinksInWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LROpenLinksInWebViewController class])];
    NSDictionary *aDocumentDetailsDictionary = nil;
    if(self.isSearching) {
        aDocumentDetailsDictionary = [searchResults objectAtIndex:iTag];
    }
    else {
        aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:iTag];
    }
    aOpenLinksInWebViewController.linkURL = [aDocumentDetailsDictionary objectForKey:@"PdfURL"];
    aOpenLinksInWebViewController.isLinkFromLogin = FALSE;
    [self.navigationController pushViewController:aOpenLinksInWebViewController animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isSearching) {
        if([searchResults count] == 0)
            return 44;
        NSDictionary *aDocumentDetailsDictionary = [searchResults objectAtIndex:indexPath.row];
        
        return [LRGlobalSearchDocumentsListViewController heightOfCellWithIngredientLine:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] withSuperviewWidth:320.0];
    }
    else {
        if(indexPath.row == self.globalSearchDocumentsListArray.count && self.isSearching == FALSE) {
            return 44;
        }
        NSDictionary *aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:indexPath.row];
        
        return [LRGlobalSearchDocumentsListViewController heightOfCellWithIngredientLine:[aDocumentDetailsDictionary objectForKey:@"DocumentTitle"] withSuperviewWidth:320.0];
    }
}
+ (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
                       withSuperviewWidth:(CGFloat)superviewWidth
{
    UIFont *drawingFont = [UIFont systemFontOfSize:16.0];
    NSDictionary *attributes = @{NSFontAttributeName : drawingFont, NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    
    CGFloat labelWidth                  = superviewWidth - 120.0f;
    //    use the known label width with a maximum height of 100 points
    CGSize labelContraints              = CGSizeMake(labelWidth, INT16_MAX);
    
    NSStringDrawingContext *context     = [[NSStringDrawingContext alloc] init];
    
    CGRect labelRect                    = [ingredientLine boundingRectWithSize:labelContraints
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:attributes
                                                                       context:context];
    
    
    
    //    return the calculated required height of the cell considering the label
    return labelRect.size.height + 50;
}
#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRDocumentViewController *documentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
    NSString *aFileTypeExtension = nil;
    
    if(self.isSearching == TRUE) {
        NSDictionary *aDocumentDetailsDictionary = [searchResults objectAtIndex:indexPath.row];
        
        aFileTypeExtension = [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
        //documentViewController.documentPath = @"D:\\Release\\test.txt";
        documentViewController.documentTitleToBeSavedAsPdf = [aDocumentDetailsDictionary objectForKey:@"DocumentTitle"];
        documentViewController.documentId = [aDocumentDetailsDictionary objectForKey:@"DocumentID"];
        documentViewController.isAudioFilePlayed = FALSE;
        [self.navigationController pushViewController:documentViewController animated:TRUE];
        /*if([aFileTypeExtension isEqualToString:@"pdf"]) {
         documentViewController.isAudioFilePlayed = FALSE;
         [self.navigationController pushViewController:documentViewController animated:TRUE];
         }
         else if ([aFileTypeExtension isEqualToString:@"WAV"]) {
         documentViewController.isAudioFilePlayed = TRUE;
         [self.navigationController pushViewController:documentViewController animated:TRUE];
         }
         else {
         UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
         message:@"Please email the link to Self"
         delegate:self
         cancelButtonTitle:NSLocalizedString(@"OK", @"")
         otherButtonTitles:nil, nil];
         [errorAlertView show];
         
         }*/
        
    }
    else {
        if(indexPath.row == self.globalSearchDocumentsListArray.count) {
            self.documentsFetchCount = self.documentsFetchCount + 20;
            [self fetchMoreDocumentsWithDocumentCount:self.documentsFetchCount];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        NSDictionary *aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:indexPath.row];
        
        aFileTypeExtension = [[aDocumentDetailsDictionary objectForKey:@"Path"] pathExtension];
        //documentViewController.documentPath = @"D:\\Release\\test.txt";
        documentViewController.documentTitleToBeSavedAsPdf = [aDocumentDetailsDictionary objectForKey:@"DocumentTitle"];
        documentViewController.documentId = [aDocumentDetailsDictionary objectForKey:@"DocumentID"];
        documentViewController.isAudioFilePlayed = FALSE;
        documentViewController.documentType = aFileTypeExtension;
        [self.navigationController pushViewController:documentViewController animated:TRUE];
        /*if([aFileTypeExtension isEqualToString:@"pdf"]) {
         documentViewController.isAudioFilePlayed = FALSE;
         [self.navigationController pushViewController:documentViewController animated:TRUE];
         }
         else if ([aFileTypeExtension isEqualToString:@"WAV"]) {
         documentViewController.isAudioFilePlayed = TRUE;
         [self.navigationController pushViewController:documentViewController animated:TRUE];
         }
         else {
         UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
         message:@"This type of Document cannot be viewed in iOS. Please Email it to yourself to view."
         delegate:self
         cancelButtonTitle:NSLocalizedString(@"OK", @"")
         otherButtonTitles:nil, nil];
         [errorAlertView show];
         
         }*/
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)fetchMoreDocumentsWithDocumentCount:(int )documentFetchCount{
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    NSMutableDictionary *aRequestDictionary = [NSMutableDictionary new];
    [aRequestDictionary setObject:[NSString stringWithFormat:@"%d",self.documentsFetchCount] forKey:@"TopCount"];
    [aRequestDictionary setObject:self.searchKeyWordsString forKey:@"SearchKeyword"];
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    self.delegate = [LRWebEngine defaultWebEngine];
    
    [[LRWebEngine defaultWebEngine] sendRequestToSearchForDocumentsForKeyWordsWithContextInfo:aRequestDictionary forResponseBlock:^(NSDictionary *responseDictionary) {
        if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            
            if(![[responseDictionary objectForKey:@"Data"]  isKindOfClass:([NSNull class])]) {
                if ([[[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"] count] > 0) {
                    self.globalSearchDocumentsListArray = [[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"];
                    [self.globalSearchDocumentListTable reloadData];
                }
                else {
                    UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                               message:@"No Results"
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                     otherButtonTitles:nil, nil];
                    
                    [aLogOutAlertView show];
                }
                [LRUtility stopActivityIndicatorFromView:self.view];
            }
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
    if(self.isSearching == TRUE) {
        NSDictionary *aDocumentDetailsDictionary = [searchResults objectAtIndex:index];
        
        
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
        [[[self searchDisplayController] searchResultsTableView] reloadData];
    }
    else {
        NSDictionary *aDocumentDetailsDictionary = [self.globalSearchDocumentsListArray objectAtIndex:index];
        
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
        [self.globalSearchDocumentListTable reloadData];
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

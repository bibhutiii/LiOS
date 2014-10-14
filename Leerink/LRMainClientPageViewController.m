//
//  LRMainClientPageViewController.m
//  Leerink
//
//  Created by Ashish on 19/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRMainClientPageViewController.h"
#import "LRContactListTableViewCell.h"
#import "LRDocumentTypeListController.h"
#import "LRTwitterListsViewController.h"
#import "STTwitter.h"
#import "LRTwitterList.h"
#import "LRTwitterListTweetsViewController.h"
#import "LRTweets.h"

@interface LRMainClientPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mainClientTable;
@property (strong, nonatomic) NSMutableArray *aMainClientListArray;
@property (weak, nonatomic) IBOutlet UILabel *aUserNameLabel;
- (void)saveTwitterListDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray;
- (void)saveTweetDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray;
@end

@implementation LRMainClientPageViewController

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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    self.title = @"Document Library";
    NSArray *user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] componentsSeparatedByString:@"@"];
    self.aUserNameLabel.text = [user objectAtIndex:0];
    NSLog(@"%@",[user objectAtIndex:0]);
    
    // since the landing page has a static list of items add them into the array for the tableview's data source.
    
    self.aMainClientListArray = [[NSMutableArray alloc] initWithObjects:@"Today's Research",@"Symbol",@"Sector",@"Analyst", nil];
    [self.mainClientTable reloadData];
    self.mainClientTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
- (IBAction)fetchListsForTwitter:(id)sender {
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"f8KKQr7cJVlbeIcuL2z20h7Vw"
                                                            consumerSecret:@"9JkMLP6qKG3z0o8VWSxs5Xkr3TlYO35d3jG9JQ4o75BuxixUZk"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getListsSubscribedByUsername:@"LeerPortal" orUserID:nil reverse:0 successBlock:^(NSArray *lists) {
            
            [self saveTwitterListDetailsToCoreDataForArray:lists];
            
            if(lists.count <= 1) {
                if(lists.count == 0) {
                     [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:@"No lists available"
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                }
                else {
                    NSArray *twitterLists = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRTwitterList" withPredicate:nil, nil];
                    if(twitterLists && twitterLists.count > 0) {
                        LRTwitterList *aTwitterList = (LRTwitterList *)[twitterLists objectAtIndex:0];
                        
                        [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
                            
                            [twitter getListsStatusesForSlug:aTwitterList.listSlug screenName:aTwitterList.listScreenName ownerID:aTwitterList.listOwnerId sinceID:nil maxID:nil count:@"15" includeEntities:[NSNumber numberWithBool:1] includeRetweets:[NSNumber numberWithBool:1] successBlock:^(NSArray *statuses) {
                                [self saveTweetDetailsToCoreDataForArray:statuses];
                                LRTwitterListTweetsViewController *aTweetsListController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:(NSStringFromClass([LRTwitterListTweetsViewController class]))];
                                aTweetsListController.isTwitterListCountMoreThanOne = FALSE;
                                aTweetsListController.aTwitterList = aTwitterList;
                                [self.navigationController pushViewController:aTweetsListController animated:TRUE];
                                [LRUtility stopActivityIndicatorFromView:self.view];
                                
                            } errorBlock:^(NSError *error) {
                                
                                [LRUtility stopActivityIndicatorFromView:self.view];
                                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                                         message:[error description]
                                                                                        delegate:self
                                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                               otherButtonTitles:nil, nil];
                                [errorAlertView show];
                                
                            }];
                            
                        } errorBlock:^(NSError *error) {
                            // ...
                            [LRUtility stopActivityIndicatorFromView:self.view];
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                                     message:[error description]
                                                                                    delegate:self
                                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                           otherButtonTitles:nil, nil];
                            [errorAlertView show];
                        }];
                    }
                    ///
                }
            }
            else {
                LRTwitterListsViewController *twitterListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRTwitterListsViewController class])];
                [self.navigationController pushViewController:twitterListViewController animated:TRUE];
                [LRUtility stopActivityIndicatorFromView:self.view];
                
            }
        } errorBlock:^(NSError *error) {
             [LRUtility stopActivityIndicatorFromView:self.view];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[error description]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }];
        
    } errorBlock:^(NSError *error) {
        // ...
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[error description]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];
    }];
}
#pragma mark - Save twitter list data to core data
- (void)saveTwitterListDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray
{
    LRTwitterList *aTweetList = nil;
    NSArray *twitterLists = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRTwitterList" withPredicate:nil, nil];
    if(twitterLists.count > 0) {
        for (LRTwitterList *twitterListObj in twitterLists) {
            [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:twitterListObj];
            
            [[LRCoreDataHelper sharedStorageManager] saveContext];
        }
    }
    if(iTweetDetailsArray && iTweetDetailsArray.count > 0) {
        
        for (NSDictionary *aTweetDetailsDictionary in iTweetDetailsArray) {
            
            NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
            
            aTweetList = (LRTwitterList *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRTwitterList" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
            aTweetList.listName = [aTweetDetailsDictionary objectForKey:@"name"];
            aTweetList.listOwnerId = [[aUserDetailsDictionary objectForKey:@"id"] stringValue];
            aTweetList.listScreenName = [aUserDetailsDictionary objectForKey:@"name"];
            aTweetList.listImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aUserDetailsDictionary objectForKey:@"profile_image_url"]]]];
            aTweetList.listSlug = [aTweetDetailsDictionary objectForKey:@"slug"];
            
            [[LRCoreDataHelper sharedStorageManager] saveContext];
        }
    }
}
- (void)saveTweetDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray
{
    NSArray *tweetsForUser = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRTweets" withPredicate:nil, nil];
    if(tweetsForUser.count > 0) {
        for (LRTweets *tweetObj in tweetsForUser) {
            [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:tweetObj];
        }
        [[LRCoreDataHelper sharedStorageManager] saveContext];
        
    }
    if(iTweetDetailsArray && iTweetDetailsArray.count > 0) {
        
        for (NSDictionary *aTweetDetailsDictionary in iTweetDetailsArray) {
            NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
            
            LRTweets *aTweetList = (LRTweets *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRTweets" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
            aTweetList.tweet = [aTweetDetailsDictionary objectForKey:@"text"];
            aTweetList.memberImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aUserDetailsDictionary objectForKey:@"profile_image_url"]]]];
            
            [[LRCoreDataHelper sharedStorageManager] saveContext];
        }
    }
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aMainClientListArray.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRContactListTableViewCell class]);
    LRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 0];
    }
    [cell fillDataForContactCellwithName:[self.aMainClientListArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // based on the type of document selected, navigate to the documents list screen.
    
    LRDocumentTypeListController *documentTypeListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentTypeListController class])];
    
    switch (indexPath.row) {
        case 0:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
            break;
        case 1:
            documentTypeListViewController.eDocumentType = eLRDocumentSymbol;
            break;
        case 2:
            documentTypeListViewController.eDocumentType = eLRDocumentSector;
            break;
        case 3:
            documentTypeListViewController.eDocumentType = eLRDocumentAnalyst;
            break;
            
        default:
            break;
    }
    documentTypeListViewController.titleHeader = [self.aMainClientListArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:documentTypeListViewController animated:TRUE];
    
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

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
#import "LRWebEngine.h"
#import "LRLoginViewController.h"
#import "LRDocumentListViewController.h"
#import "UIView+MGBadgeView.h"

@interface LRMainClientPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mainClientTable;
@property (strong, nonatomic) NSMutableArray *aMainClientListArray;
@property (weak, nonatomic) IBOutlet UILabel *aUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendCartButton;
- (IBAction)sendDocumentIdsFromCartToService:(id)sender;
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Leerink-White_320x64"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:9/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"] length] > 0){
        self.aUserNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"];
    }
    else {
        // split the user email and fetch the first name and last name of the user.
        NSArray *user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"] componentsSeparatedByString:@"@"];
        if(user.count > 0) {
            NSArray *splitUserFirstNameArray = [[user objectAtIndex:0] componentsSeparatedByString:@"."];
            if(splitUserFirstNameArray.count > 0) {
                self.aUserNameLabel.text = [splitUserFirstNameArray objectAtIndex:0];
            }
            else {
                self.aUserNameLabel.text = [user objectAtIndex:0];
            }
        }
        else {
            self.aUserNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"];
        }
    }
    
    // add the logout button on the right side of the navigation bar
    SEL aLogoutButtonSelector = sel_registerName("logOut");
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithImage:nil style:0 target:self action:aLogoutButtonSelector];
    logOutButton.title = @"Logout";
    self.navigationItem.rightBarButtonItem = logOutButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    // since the landing page has a static list of items add them into the array for the tableview's data source.
    NSArray *docListArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"DocList"];
    self.aMainClientListArray = [NSMutableArray new];
    
    [self.aMainClientListArray addObjectsFromArray:docListArray];
    [self.aMainClientListArray addObject:@"Analyst"];
    [self.aMainClientListArray addObject:@"Symbol"];
    [self.aMainClientListArray addObject:@"Sector"];
    
    [self.mainClientTable reloadData];
    self.mainClientTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // fetch all the docids saved in the plsit to be sent to the cart.
    NSArray *arr = [LRAppDelegate fetchDataFromPlist];
    self.sendCartButton.hidden = TRUE;
    if(arr.count > 0) {
        self.sendCartButton.hidden = FALSE;
        [self.sendCartButton.badgeView setPosition:MGBadgePositionTopRight];
        [self.sendCartButton.badgeView setBadgeValue:arr.count];
        [self.sendCartButton.badgeView setBadgeColor:[UIColor redColor]];
    }
    
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
- (void)logOut
{
    UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                               message:[NSString stringWithFormat:@"Are you sure you want to logout?"]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"No", @"")
                                                     otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [aLogOutAlertView setTag:200];
    [aLogOutAlertView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200) {
        if(buttonIndex == 1) {
            [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
            [[LRWebEngine defaultWebEngine] sendRequestToLogOutWithwithContextInfo:nil forResponseBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SessionId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrimaryRoleID"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstName"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastName"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocList"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsInternalUser"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone?@"Main_iPhone":@"Main_iPad" bundle:nil];
                    LRLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
                    [[LRAppDelegate myAppdelegate].window setRootViewController:loginVC];
                    [[LRAppDelegate myAppdelegate].aBaseNavigationController popToRootViewControllerAnimated:FALSE];
                    
                    
                }
                
            } errorHandler:^(NSError *errorString) {
                [LRUtility stopActivityIndicatorFromView:self.view];
                UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                           message:[errorString description]
                                                                          delegate:self
                                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                 otherButtonTitles:nil, nil];
                [aLogOutAlertView show];
                
            }];
        }
    }
    if(alertView.tag == 111) {
        if(buttonIndex == 0) {
            NSMutableDictionary *savedDocids = [[NSMutableDictionary alloc] initWithContentsOfFile:[LRAppDelegate fetchPathOfCustomPlist]];
            NSArray *arr = [LRAppDelegate fetchDataFromPlist];
            self.sendCartButton.hidden = TRUE;
            NSArray *aEmptyArray = [NSArray new];
            NSLog(@"%@",arr);
            
            [savedDocids setObject:aEmptyArray forKey:@"docIds"];
            [savedDocids writeToFile:[LRAppDelegate fetchPathOfCustomPlist] atomically:TRUE];

        }
    }
}
#pragma mark - Save twitter list data to core data
- (IBAction)sendDocumentIdsFromCartToService:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil otherButtonTitles: @"Email Cart to Me",@"Clear Cart", nil, nil];
    
    [actionSheet showInView:self.view];


}
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            NSMutableDictionary *savedDocids = [[NSMutableDictionary alloc] initWithContentsOfFile:[LRAppDelegate fetchPathOfCustomPlist]];
            
            NSArray *arr = [LRAppDelegate fetchDataFromPlist];
            if(arr.count > 0) {
                ///
                NSMutableString *aDocIdsString = (NSMutableString *)[arr componentsJoinedByString:@","];
                
                [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
                NSMutableDictionary *aRequestDictionary = [NSMutableDictionary new];
                [aRequestDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] forKey:@"UserId"];
                [aRequestDictionary setObject:aDocIdsString forKey:@"DocumentIds"];
                [[LRWebEngine defaultWebEngine] sendRequestToSendCartWithDocIdswithContextInfo:aRequestDictionary forResponseBlock:^(NSDictionary *responseDictionary) {
                    if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                        
                        [LRUtility stopActivityIndicatorFromView:self.view];
                        self.sendCartButton.hidden = TRUE;
                        NSArray *aEmptyArray = [NSArray new];
                        NSLog(@"%@",arr);
                        
                        [savedDocids setObject:aEmptyArray forKey:@"docIds"];
                        [savedDocids writeToFile:[LRAppDelegate fetchPathOfCustomPlist] atomically:TRUE];
                        
                        UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                                   message:@"Cart sent successfully"
                                                                                  delegate:self
                                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                         otherButtonTitles:nil, nil];
                        [aLogOutAlertView show];
                    }
                    
                } errorHandler:^(NSError *errorString) {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                               message:[errorString description]
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                     otherButtonTitles:nil, nil];
                    [aLogOutAlertView show];
                    
                }];
            }
        }
            break;
            case 1:
        {
            UIAlertView *aCleartCartAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                           message:@"Items from the Cart will be cleared. Do you wish to continue?"
                                                                          delegate:self
                                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                 otherButtonTitles:@"Cancel", nil];
            
            aCleartCartAlertView.tag = 111;
            [aCleartCartAlertView show];
        }
            break;
    }
    
}

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
           // aTweetList.listCreatedDate = [aTweetDetailsDictionary objectForKey:@"created_at"];
            NSDateFormatter *aDateFormatterObj = [[NSDateFormatter alloc] init];
            
            
            //Mon Oct 20 00:20:36 +0000 2014
            // [aDateFormatterObj setDateFormat:@"EE LLLL d HH:mm:ss Z yyyy"];
            [aDateFormatterObj setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
            
            // "Tue, 25 May 2010 12:53:58 +0000";
            //    [aDateFormatterObj setDateFormat:@"EE, d LLLL yyyy HH:mm:ss Z"];
            
            NSDate *aDateObj = [aDateFormatterObj dateFromString:[aTweetDetailsDictionary objectForKey:@"created_at"]];
            //  NSLog(@"date--%@",aDateObj);
            
            [aDateFormatterObj setDateFormat:@"yyyy-MMM-dd HH:mm"];
            //2014-10-19 23:00:15 +0000
            aTweetList.listCreatedDate = [aDateFormatterObj stringFromDate:aDateObj];
            aTweetList.listDate = aDateObj;
            
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
            aTweetList.tweetScreenName = [aUserDetailsDictionary objectForKey:@"screen_name"];
            aTweetList.tweetDate = [aTweetDetailsDictionary objectForKey:@"created_at"];
            
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
    if(indexPath.row >= self.aMainClientListArray.count - 3) {
        [cell fillDataForContactCellwithName:[self.aMainClientListArray objectAtIndex:indexPath.row]];
    }
    else {
        [cell fillDataForContactCellwithName:[[self.aMainClientListArray objectAtIndex:indexPath.row] objectForKey:@"ListDesc"]];
        
    }
    
    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // based on the type of document selected, navigate to the documents list screen.
    
    if(indexPath.row >= self.aMainClientListArray.count - 3) {
        
        LRDocumentTypeListController *documentTypeListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentTypeListController class])];
        
        if(indexPath.row == self.aMainClientListArray.count - 3)
        {
            documentTypeListViewController.eDocumentType = eLRDocumentAnalyst;
        }
        if(indexPath.row == self.aMainClientListArray.count - 2)
        {
            documentTypeListViewController.eDocumentType = eLRDocumentSymbol;
            
        } if(indexPath.row == self.aMainClientListArray.count - 1)
        {
            documentTypeListViewController.eDocumentType = eLRDocumentSector;
        }
        documentTypeListViewController.titleHeader = [self.aMainClientListArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:documentTypeListViewController animated:TRUE];
    }
    //Send the list id to fetch the list of documents
    else {
        LRDocumentListViewController *documentListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentListViewController class])];
        documentListViewController.isDocumentsFetchedForList = TRUE;
        documentListViewController.contextInfo = [[self.aMainClientListArray objectAtIndex:indexPath.row] objectForKey:@"ListId"];
        [self.navigationController pushViewController:documentListViewController animated:TRUE];
    }
    
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

-(void)didReceiveMemoryWarning
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

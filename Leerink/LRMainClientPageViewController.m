
//
//  LRMainClientPageViewController.m
//  Leerink
//
//  Created by Ashish on 19/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRMainClientPageViewController.h"
#import "LRContactListTableViewCell.h"
#import "LRSubMenuListController.h"
#import "LRTwitterListsViewController.h"
#import "STTwitter.h"
#import "LRTwitterList.h"
#import "LRTwitterListTweetsViewController.h"
#import "LRTweets.h"
#import "LRWebEngine.h"
#import "LRLoginViewController.h"
#import "LRDocumentListViewController.h"
#import "UIView+MGBadgeView.h"
#import "LRAuthorBioInfoViewController.h"
#import "LROpenLinksInWebViewController.h"
#import "FPPopoverController.h"

@interface LRMainClientPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mainClientTable;
@property (strong, nonatomic) NSMutableArray *aMainClientListArray;
@property (weak, nonatomic) IBOutlet UILabel *aUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendCartButton;
@property (strong, nonatomic) FPPopoverController *popover;
@property (strong, nonatomic) UIButton *globalSearchButton;

@property (weak, nonatomic) IBOutlet UIButton *slideOutSearchOkButton;
@property (nonatomic, readwrite, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, readwrite, assign) NSUInteger reloads;
@property (strong, nonatomic) IBOutlet NSObject *topBar;
@property (strong, nonatomic) UIView *globalSearchSlideoutView;
@property (strong, nonatomic) UITextField *aSearchTextField;

- (IBAction)sendDocumentIdsFromCartToService:(id)sender;
- (void)saveTwitterListDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray;
- (void)saveTweetDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray;
- (void)fetchMainMenuItems;
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
    
    // add the logout button on the right side of the navigation bar
     SEL aGlobalSearchButton = sel_registerName("globalSearch:");
     
     self.globalSearchButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
     [self.globalSearchButton setBackgroundImage:[UIImage imageNamed:@"Search-32"] forState:UIControlStateNormal];
     [self.globalSearchButton addTarget:self action:aGlobalSearchButton
     forControlEvents:UIControlEventTouchUpInside];
     [self.globalSearchButton setShowsTouchWhenHighlighted:YES];
     
     UIBarButtonItem *globalSearchBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:self.globalSearchButton];
     self.navigationItem.leftBarButtonItem = globalSearchBarButtonItem;
    
    
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
    
    // fetch all the docids saved in the plsit to be sent to the cart.
    NSArray *arr = [LRAppDelegate fetchDataFromPlist];
    self.sendCartButton.hidden = TRUE;
    if(arr.count > 0) {
        self.sendCartButton.hidden = FALSE;
        [self.sendCartButton.badgeView setPosition:MGBadgePositionTopRight];
        [self.sendCartButton.badgeView setBadgeValue:arr.count];
        [self.sendCartButton.badgeView setBadgeColor:[UIColor redColor]];
    }
    
    
    // add the search animating view
    if(self.globalSearchSlideoutView) {
        self.globalSearchSlideoutView.frame = CGRectMake(-320, 10, 300, 80);
    }
    else {
        self.globalSearchSlideoutView = [[UIView alloc] initWithFrame:CGRectMake(-320, 10, 300, 90)];
        self.globalSearchSlideoutView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:141.0/255.0 blue:192.0/255.0 alpha:1.0];
        self.globalSearchSlideoutView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.globalSearchSlideoutView.layer.borderWidth = 2.0f;
        self.globalSearchSlideoutView.layer.cornerRadius = 2.0f;
        
        // add a textfield to search
        self.aSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10.0, 280.0, 32.0)] ;
        self.aSearchTextField.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
        self.aSearchTextField.layer.cornerRadius = 3.0;
        self.aSearchTextField.backgroundColor = [UIColor whiteColor];
        self.aSearchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.aSearchTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.aSearchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.aSearchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.aSearchTextField.delegate = self;
        [self.aSearchTextField setTintColor:[UIColor blackColor]];
        self.aSearchTextField.placeholder = @"Please enter keywords to search";
        
        [self.globalSearchSlideoutView addSubview:self.aSearchTextField];
        
        // add the ok cancel button to the view
        UIButton *aOKButton = [UIButton buttonWithType:UIButtonTypeSystem];
        aOKButton.frame = CGRectMake(80, 48, 32, 32);
        SEL aGlobalSearchButton = sel_registerName("globalSearchText");
        [aOKButton addTarget:self action:aGlobalSearchButton forControlEvents:UIControlEventTouchUpInside];
        [aOKButton setImage:[UIImage imageNamed:@"Ok-32"] forState:UIControlStateNormal];

        [self.globalSearchSlideoutView addSubview:aOKButton];
        
        UIButton *aCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        aCancelButton.frame = CGRectMake(180, 48, 32, 32);
        [aCancelButton setImage:[UIImage imageNamed:@"Cancel-32"] forState:UIControlStateNormal];
        SEL aGlobalSearchCancelButton = sel_registerName("globalSearchTextCancel");
        [aCancelButton addTarget:self action:aGlobalSearchCancelButton forControlEvents:UIControlEventTouchUpInside];

        [self.globalSearchSlideoutView addSubview:aCancelButton];
    }
    [self.view addSubview:self.globalSearchSlideoutView];
    [self fetchMainMenuItems];
}
- (void)globalSearchText {
    
    [self.aSearchTextField resignFirstResponder];

    NSMutableDictionary *aRequestDictionary = [NSMutableDictionary new];
    [aRequestDictionary setObject:self.aSearchTextField.text forKey:@"SearchKeyword"];
    [aRequestDictionary setObject:@"50" forKey:@"TopCount"];

    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToSearchForDocumentsForKeyWordsWithContextInfo:aRequestDictionary forResponseBlock:^(NSDictionary *responseDictionary) {
        if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            
            
            LRDocumentListViewController *documentListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentListViewController class])];
            documentListViewController.isDocumentsFetchedForList = TRUE;
            documentListViewController.showMoreForSearchResults = FALSE;
         //   documentListViewController.parentMenuItemId = [aMainMenuItemsDetailsDictionary objectForKey:@"ParentMenuId"];
            if(![[responseDictionary objectForKey:@"DataList"]  isKindOfClass:([NSNull class])]) {
                if ([[responseDictionary objectForKey:@"DataList"] count] > 0) {
                    documentListViewController.documentsListArray = [responseDictionary objectForKey:@"DataList"];
                    [self.navigationController pushViewController:documentListViewController animated:TRUE];
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
- (void)globalSearchTextCancel {
    [self.aSearchTextField resignFirstResponder];
    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.globalSearchSlideoutView.frame = CGRectMake(-320, 10, 300, 90);
    } completion:^(BOOL finished) {
        NSLog(@"done animating");
        
    }];}
- (void)globalSearch:(id)sender {
    
    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.globalSearchSlideoutView.frame = CGRectMake(10, self.globalSearchSlideoutView.frame.origin.y, self.globalSearchSlideoutView.frame.size.width, self.globalSearchSlideoutView.frame.size.height);
        [self.view bringSubviewToFront:self.globalSearchSlideoutView];

    } completion:^(BOOL finished) {
        NSLog(@"done animating");
        [self.aSearchTextField becomeFirstResponder];
    }];
}
- (void)fetchMainMenuItems
{
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    [[LRWebEngine defaultWebEngine] sendRequestToGetMainMenuItemsWithResponseDataBlock:^(NSDictionary *responseDictionary) {
        if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            self.aMainClientListArray = [responseDictionary objectForKey:@"DataList"];
            [self.mainClientTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            
            self.mainClientTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            
            /* _pullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f
             tableView:self.mainClientTable
             withClient:self];
             */
            
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
        
    } errorHandler:^(NSError *error) {
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[error localizedDescription]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];
        
        DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
             [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
        
    }];
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
                                                                                         message:[error localizedDescription]
                                                                                        delegate:self
                                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                               otherButtonTitles:nil, nil];
                                [errorAlertView show];
                                
                            }];
                            
                        } errorBlock:^(NSError *error) {
                            // ...
                            [LRUtility stopActivityIndicatorFromView:self.view];
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                                     message:[error localizedDescription]
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
                                                                     message:[error localizedDescription]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }];
        
    } errorBlock:^(NSError *error) {
        // ...
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[error localizedDescription]
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
                                                                           message:[errorString localizedDescription]
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
                                                                               message:[errorString localizedDescription]
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
        cell = (LRContactListTableViewCell *)[bundle objectAtIndex: 1];
    }
    NSDictionary *aMainMenuItemsDetailsDictionary = [self.aMainClientListArray objectAtIndex:indexPath.row];
    NSString *aDocumentEncodedString = [aMainMenuItemsDetailsDictionary objectForKey:@"IconByte"];
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    UIImage *iconImage = [UIImage imageWithData:decodedData];
    
    cell.delegate = self;
    cell.tag = indexPath.row;
    [cell fillDataForMenuCellWithDisplayName:[aMainMenuItemsDetailsDictionary objectForKey:@"DisplayName"] andIconImage:iconImage];
    
    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // based on the type of document selected, navigate to the documents list screen.
    NSDictionary *aMainMenuItemsDetailsDictionary = [self.aMainClientListArray objectAtIndex:indexPath.row];
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    NSMutableDictionary *aRequestDictionary = [NSMutableDictionary new];
    [aRequestDictionary setObject:[aMainMenuItemsDetailsDictionary objectForKey:@"MenuItemId"] forKey:@"MenuItemId"];
    [aRequestDictionary setObject:[aMainMenuItemsDetailsDictionary objectForKey:@"ParentMenuId"] forKey:@"ParentMenuId"];
    [aRequestDictionary setObject:@"50" forKey:@"TopCount"];
    [[LRWebEngine defaultWebEngine] sendRequestToGetSubMenuItemsWithContextInfo:aRequestDictionary forResponseBlock:^(NSDictionary *responseDictionary) {
        if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            if(![[responseDictionary objectForKey:@"Data"] isKindOfClass:([NSNull class])]) {
                if(![[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isKindOfClass:([NSNull class])]) {
                    if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"SUBMENU"]) {
                        LRSubMenuListController *documentTypeListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRSubMenuListController class])];
                        if (![[[responseDictionary objectForKey:@"Data"] objectForKey:@"SubMenus"] isKindOfClass:([NSNull class])]) {
                            if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"SubMenus"] count] > 0) {
                                documentTypeListViewController.subMenuItemsArray = [[responseDictionary objectForKey:@"Data"] objectForKey:@"SubMenus"];
                            }
                        }
                        documentTypeListViewController.titleHeader = [aMainMenuItemsDetailsDictionary objectForKey:@"DisplayName"];
                        documentTypeListViewController.returnTypeForMenu = [[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"];
                        [self.navigationController pushViewController:documentTypeListViewController animated:TRUE];
                    }
                    else if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"DOCLIST"]){
                        LRDocumentListViewController *documentListViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentListViewController class])];
                        documentListViewController.isDocumentsFetchedForList = TRUE;
                        documentListViewController.contextInfo = [[self.aMainClientListArray objectAtIndex:indexPath.row] objectForKey:@"ListId"];
                        documentListViewController.returnTypeForMenu = [[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"];
                        documentListViewController.menuItemId = [aMainMenuItemsDetailsDictionary objectForKey:@"MenuItemId"];
                        documentListViewController.parentMenuItemId = [aMainMenuItemsDetailsDictionary objectForKey:@"ParentMenuId"];
                        if(![[[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"] isKindOfClass:([NSNull class])]) {
                            if ([[[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"] count] > 0) {
                                documentListViewController.documentsListArray = [[responseDictionary objectForKey:@"Data"] objectForKey:@"DocLists"];
                            }
                        }
                        [self.navigationController pushViewController:documentListViewController animated:TRUE];
                    }
                    else if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"URL"]){
                        LROpenLinksInWebViewController *aOpenLinksInWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LROpenLinksInWebViewController class])];
                        aOpenLinksInWebViewController.linkURL = [[responseDictionary objectForKey:@"Data"] objectForKey:@"URL"];
                        aOpenLinksInWebViewController.isLinkFromLogin = FALSE;
                        aOpenLinksInWebViewController.isHtmlStringLoaded = FALSE;
                        [self.navigationController pushViewController:aOpenLinksInWebViewController animated:TRUE];
                    }
                    else if([[[responseDictionary objectForKey:@"Data"] objectForKey:@"ReturnType"] isEqualToString:@"HTML"]){
                        LROpenLinksInWebViewController *aOpenLinksInWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LROpenLinksInWebViewController class])];
                        aOpenLinksInWebViewController.linkURL = [[responseDictionary objectForKey:@"Data"] objectForKey:@"HTML"];
                        aOpenLinksInWebViewController.isLinkFromLogin = FALSE;
                        aOpenLinksInWebViewController.isHtmlStringLoaded = TRUE;
                        [self.navigationController pushViewController:aOpenLinksInWebViewController animated:TRUE];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - Show Bio information for Analyst
- (void)showBioInformationForSelectedAnalystwithTag:(int)iTag
{
    LRAuthorBioInfoViewController *authorBioInfoViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRAuthorBioInfoViewController class])];
    authorBioInfoViewController.authorInfo = [[self.aMainClientListArray objectAtIndex:iTag] objectForKey:@"IconContent"];
    NSLog(@"%@",authorBioInfoViewController.authorInfo);
    [self.navigationController pushViewController:authorBioInfoViewController animated:TRUE];
}
#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient
- (void)loadTable {
    
    [self fetchMainMenuItems];
}
/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_pullToRefreshManager tableViewScrolled];
}

/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_pullToRefreshManager tableViewReleased];
}

/**
 * Tells client that refresh has been triggered
 * After reloading is completed must call [MNMPullToRefreshManager tableViewReloadFinishedAnimated:]
 *
 * @param manager PTR manager
 */
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager {
    
    _reloads++;
    
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
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

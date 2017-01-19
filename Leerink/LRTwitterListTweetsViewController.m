//
//  LRTwitterListTweetsViewController.m
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRTwitterListTweetsViewController.h"
#import "STTwitter.h"
#import "LROpenLinksInWebViewController.h"
#import "LRUserTimeLineTwitterViewController.h"

@interface LRTwitterListTweetsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tweetsListViewTable;
- (void)fetchTweetsForSpecifiedListCount:(NSString *)iCount;
@property (assign, nonatomic) int tweetCount;
@property (nonatomic, readwrite, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, readwrite, assign) NSUInteger reloads;
@property (strong, nonatomic) IBOutlet NSObject *topBar;
@property (strong, nonatomic) NSMutableArray *aMemberImagesArray;


@end

@implementation LRTwitterListTweetsViewController
@synthesize pullToRefreshManager = pullToRefreshManager_;
@synthesize reloads = reloads_;


- (void)viewDidLoad {
    [super viewDidLoad];
    
       self.tweetCount = 15;
    if(self.isTwitterListCountMoreThanOne == TRUE) {
        [self fetchTweetsForSpecifiedListCount:[NSString stringWithFormat:@"%d",self.tweetCount]];
    }
    else {
        
        self.aMemberImagesArray = [NSMutableArray new];

        for (int i = 0; i < self.tweetsListArray.count; i++) {
            NSDictionary *aTweetDetailsDictionary = [self.tweetsListArray objectAtIndex:i];
            NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
            UIImage *aMemberImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aUserDetailsDictionary objectForKey:@"profile_image_url"]]]];
            [self.aMemberImagesArray addObject:aMemberImage];
        }
        
        [self.tweetsListViewTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        pullToRefreshManager_ = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f
                                                                                       tableView:self.tweetsListViewTable
                                                                                      withClient:self];

        [LRUtility stopActivityIndicatorFromView:self.view];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    // Do any additional setup after loading the view.
    self.title = @"Tweets";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];

}

- (void)fetchTweetsForSpecifiedListCount:(NSString *)iCount
{
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"f8KKQr7cJVlbeIcuL2z20h7Vw"
                                                            consumerSecret:@"9JkMLP6qKG3z0o8VWSxs5Xkr3TlYO35d3jG9JQ4o75BuxixUZk"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getListsStatusesForSlug:self.aTwitterListSlug screenName:self.aTwitterListScreenName ownerID:self.aTwitterListOwnerId sinceID:nil maxID:nil count:iCount includeEntities:[NSNumber numberWithBool:1] includeRetweets:[NSNumber numberWithBool:1] successBlock:^(NSArray *statuses) {
            
            self.tweetsListArray = [NSMutableArray arrayWithArray:statuses];
            self.aMemberImagesArray = [NSMutableArray new];
            for (int i = 0; i < self.tweetsListArray.count; i++) {
                NSDictionary *aTweetDetailsDictionary = [self.tweetsListArray objectAtIndex:i];
                NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
                UIImage *aMemberImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aUserDetailsDictionary objectForKey:@"profile_image_url"]]]];
                [self.aMemberImagesArray addObject:aMemberImage];
            }
            
            [self.tweetsListViewTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

            pullToRefreshManager_ = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f
                                                                                           tableView:self.tweetsListViewTable
                                                                                          withClient:self];

            [LRUtility stopActivityIndicatorFromView:self.view];
            [pullToRefreshManager_ tableViewReloadFinishedAnimated:YES];
            
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

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweetsListArray.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRTwitterListTableViewCell class]);
    
    LRTwitterListTableViewCell *cell = [self.tweetsListViewTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        if(indexPath.row == self.tweetsListArray.count) {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex:2];
        }
        else {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex: 1];
        }
    }
    if(indexPath.row != self.tweetsListArray.count) {
        
        NSDictionary *aTweetDetailsDictionary = [self.tweetsListArray objectAtIndex:indexPath.row];
        NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell fillDataForTweetCellWithTweet:[aTweetDetailsDictionary objectForKey:@"text"] andMemberImage:[self.aMemberImagesArray objectAtIndex:indexPath.row] andDate:[aTweetDetailsDictionary objectForKey:@"created_at"] andUserName:[aUserDetailsDictionary objectForKey:@"screen_name"]];
        
    }
    
    return cell;
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
    if(indexPath.row != self.tweetsListArray.count) {
        
        NSDictionary *aTweetDetailsDictionary = [self.tweetsListArray objectAtIndex:indexPath.row];
        CGSize constrainedSize = CGSizeMake(249  , 9999);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"HelveticaNeue" size:13.0], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[aTweetDetailsDictionary objectForKey:@"text"] attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return requiredHeight.size.height + 80.0;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.tweetsListArray.count) {
        
        if(self.tweetCount >= 100) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:@"Maximum number of Tweets fetched"
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        else {
            self.tweetCount = self.tweetCount + 15;
            [self fetchTweetsForSpecifiedListCount:[NSString stringWithFormat:@"%d",self.tweetCount]];
            
        }
    }
    else {
        LRUserTimeLineTwitterViewController *aUserTimeLineViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:@"LRUserTimeLineTwitterViewController"];
        NSDictionary *aTweetDetailsDictionary = [self.tweetsListArray objectAtIndex:indexPath.row];
        NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
        aUserTimeLineViewController.tweetUserName = [aUserDetailsDictionary objectForKey:@"screen_name"];
        [self.navigationController pushViewController:aUserTimeLineViewController animated:TRUE];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient
- (void)loadTable {
    
    [self fetchTweetsForSpecifiedListCount:[NSString stringWithFormat:@"%d",self.tweetCount]];
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
    
    [pullToRefreshManager_ tableViewScrolled];
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
    
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that refresh has been triggered
 * After reloading is completed must call [MNMPullToRefreshManager tableViewReloadFinishedAnimated:]
 *
 * @param manager PTR manager
 */
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager {
    
    reloads_++;
    
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
}
- (void)loadWebViewWithURL:(NSString *)url
{
    LROpenLinksInWebViewController *aOpenLinkInsideWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:@"LROpenLinksInWebViewController"];
    aOpenLinkInsideWebViewController.linkURL = url;
    aOpenLinkInsideWebViewController.isLinkFromLogin = FALSE;
    [self.navigationController pushViewController:aOpenLinkInsideWebViewController animated:TRUE];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

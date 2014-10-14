//
//  LRTwitterListTweetsViewController.m
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRTwitterListTweetsViewController.h"
#import "LRTwitterListTableViewCell.h"
#import "STTwitter.h"
#import "LRTweets.h"

@interface LRTwitterListTweetsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tweetsListViewTable;
@property (strong, nonatomic) NSMutableArray *tweetsListArray;
- (void)saveTweetDetailsToCoreDataForArray:(NSArray *)iTweetDetailsArray;
- (void)fetchTweetsForSpecifiedListCount:(NSString *)iCount;
@property (assign, nonatomic) int tweetCount;
@end

@implementation LRTwitterListTweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Tweets";
    self.tweetCount = 15;
    if(self.isTwitterListCountMoreThanOne == TRUE) {
        [self fetchTweetsForSpecifiedListCount:[NSString stringWithFormat:@"%d",self.tweetCount]];
    }
    else {
        self.tweetsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRTweets" withPredicate:nil, nil];
        [self.tweetsListViewTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [LRUtility stopActivityIndicatorFromView:self.view];
    }
    
}
- (void)fetchTweetsForSpecifiedListCount:(NSString *)iCount
{
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"f8KKQr7cJVlbeIcuL2z20h7Vw"
                                                            consumerSecret:@"9JkMLP6qKG3z0o8VWSxs5Xkr3TlYO35d3jG9JQ4o75BuxixUZk"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getListsStatusesForSlug:self.aTwitterList.listSlug screenName:self.aTwitterList.listScreenName ownerID:self.aTwitterList.listOwnerId sinceID:nil maxID:nil count:iCount includeEntities:[NSNumber numberWithBool:1] includeRetweets:[NSNumber numberWithBool:1] successBlock:^(NSArray *statuses) {
            [self saveTweetDetailsToCoreDataForArray:statuses];
            
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
    self.tweetsListArray = (NSMutableArray *)[[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRTweets" withPredicate:nil, nil];
    [self.tweetsListViewTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [LRUtility stopActivityIndicatorFromView:self.view];
    
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweetsListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRTwitterListTableViewCell class]);
    
    LRTwitterListTableViewCell *cell = [self.tweetsListViewTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        if(indexPath.row == self.tweetsListArray.count - 1) {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex:2];
        }
        else {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex: 1];
        }
    }
    if(indexPath.row != self.tweetsListArray.count - 1) {
        
        LRTweets *aTweetObj = (LRTweets *)[self.tweetsListArray objectAtIndex:indexPath.row];
        
        [cell fillDataForTweetCellWithTweet:aTweetObj.tweet andMemberImage:aTweetObj.memberImage];
        
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
    if(indexPath.row != self.tweetsListArray.count - 1) {
        
        return 120;
        
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.tweetsListArray.count - 1) {
        
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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

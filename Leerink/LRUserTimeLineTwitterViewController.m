//
//  LRUserTimeLineTwitterViewController.m
//  Leerink
//
//  Created by Ashish on 20/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRUserTimeLineTwitterViewController.h"
#import "STTwitter.h"
#import "LROpenLinksInWebViewController.h"

@interface LRUserTimeLineTwitterViewController ()
@property (weak, nonatomic) IBOutlet UITableView *userTweetsListViewTable;
@property (strong, nonatomic) NSMutableArray *userTweetsListArray;
@property (assign, nonatomic) int userTweetCount;
@property (strong, nonatomic) NSMutableDictionary *aTweetDetailsDictionary;
@property (strong, nonatomic) NSArray *oneTimeTweetsArray;
- (void)fetchTweetsForSpecifiedListCount:(int )iCount;
@end

@implementation LRUserTimeLineTwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aTweetDetailsDictionary = [NSMutableDictionary new];
    self.oneTimeTweetsArray = [NSArray new];
    self.userTweetsListArray = [NSMutableArray new];
    [self fetchTweetsForSpecifiedListCount:15];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userTweetsListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = NSStringFromClass([LRTwitterListTableViewCell class]);
    
    LRTwitterListTableViewCell *cell = [self.userTweetsListViewTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        if(indexPath.row == self.userTweetsListArray.count - 1) {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex:2];
        }
        else {
            cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex: 1];
        }
    }
    if(indexPath.row != self.userTweetsListArray.count - 1) {
        
        NSDictionary *aUserTweetDictinary = [self.userTweetsListArray objectAtIndex:indexPath.row];
        NSDictionary *aUSerDetailsDictionary = [aUserTweetDictinary objectForKey:@"user"];
        cell.delegate = self;
        if(aUserTweetDictinary != (NSDictionary *)[NSNull class] || aUserTweetDictinary != nil) {
            [cell fillDataForTweetCellWithTweet:[aUserTweetDictinary objectForKey:@"text"] andMemberImage:[self.aTweetDetailsDictionary objectForKey:@"aUserImage"] andDate:[aUserTweetDictinary objectForKey:@"created_at"] andUserName:[aUSerDetailsDictionary objectForKey:@"name"]];
        }
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
    if(indexPath.row != self.userTweetsListArray.count - 1) {
        
        NSDictionary *aUserTweetDictinary = [self.userTweetsListArray objectAtIndex:indexPath.row];

        CGSize constrainedSize = CGSizeMake(249  , 9999);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"HelveticaNeue" size:13.0], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[aUserTweetDictinary objectForKey:@"text"] attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return requiredHeight.size.height + 80.0;
        
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.userTweetsListArray.count - 1) {
        
        if(self.userTweetCount >= 100) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:@"Maximum number of Tweets fetched"
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        else {
            self.userTweetCount = self.userTweetCount + 15;
            [self fetchTweetsForSpecifiedListCount:self.userTweetCount];
            
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (void)fetchTweetsForSpecifiedListCount:(int )iCount
{
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"f8KKQr7cJVlbeIcuL2z20h7Vw"
                                                            consumerSecret:@"9JkMLP6qKG3z0o8VWSxs5Xkr3TlYO35d3jG9JQ4o75BuxixUZk"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getUserTimelineWithScreenName:self.tweetUserName count:iCount successBlock:^(NSArray *statuses) {
            [self.userTweetsListArray addObjectsFromArray:statuses];
            
            for (NSDictionary *aTweetDetailsDictionary in statuses) {
                NSDictionary *aUserDetailsDictionary = [aTweetDetailsDictionary objectForKey:@"user"];
                
                UIImage *aUserImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aUserDetailsDictionary objectForKey:@"profile_image_url"]]]];
                [self.aTweetDetailsDictionary setObject:aUserImage forKey:@"aUserImage"];
            }
            
            /////
            [self.userTweetsListViewTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            NSLog(@"total tweets--%lu",(unsigned long)self.userTweetsListArray.count);
            //NSLog(@"array--%@",statuses);
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
- (void)loadWebViewWithURL:(NSString *)url
{
    LROpenLinksInWebViewController *aOpenLinkInsideWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:@"LROpenLinksInWebViewController"];
    aOpenLinkInsideWebViewController.linkURL = url;
    [self.navigationController pushViewController:aOpenLinkInsideWebViewController animated:TRUE];
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

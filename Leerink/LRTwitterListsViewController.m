//
//  LRTwitterListsViewController.m
//  Leerink
//
//  Created by Ashish on 26/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRTwitterListsViewController.h"
#import "STTwitter.h"
#import "LRTwitterListTableViewCell.h"

@interface LRTwitterListsViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSArray *twitterListsArray;
@property (weak, nonatomic) IBOutlet UITableView *twitterListsTableView;

@end

@implementation LRTwitterListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    self.twitterListsArray = [NSArray new];
    self.twitterListsTableView.delegate = self;
    self.twitterListsTableView.dataSource = self;
     self.twitterListsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.title = @"Lists";
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    [STTwitterAPI twitterAPIWithOAuthConsumerName:@""
                                      consumerKey:@"f8KKQr7cJVlbeIcuL2z20h7Vw"
                                   consumerSecret:@"9JkMLP6qKG3z0o8VWSxs5Xkr3TlYO35d3jG9JQ4o75BuxixUZk"
                                         username:@"Leerportal"
                                         password:@"leerDev14sep"];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        NSLog(@"Access granted for %@", username);
        
        [_twitter getListsSubscribedByUsername:@"Leerportal" orUserID:nil reverse:0 successBlock:^(NSArray *lists) {
            self.twitterListsArray = lists;
            NSLog(@"-- statuses: %@",self.twitterListsArray);
            [self.twitterListsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [LRUtility stopActivityIndicatorFromView:self.view];
        } errorBlock:^(NSError *error) {
            
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
    }];
    
    //[self.twitterListsTableView reloadData];

}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.twitterListsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
   // [tableView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];
    
    NSString *CellIdentifier = NSStringFromClass([LRTwitterListTableViewCell class]);
    
    LRTwitterListTableViewCell *cell = [self.twitterListsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (LRTwitterListTableViewCell *)[bundle objectAtIndex: 0];
    }
    
    NSDictionary *aTwitterListDetailsDictionary = [self.twitterListsArray objectAtIndex:indexPath.row];
    [cell fillDataForDocumentCellwithTwitterListMemberName:[aTwitterListDetailsDictionary objectForKey:@"name"]];
    
    return cell;
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

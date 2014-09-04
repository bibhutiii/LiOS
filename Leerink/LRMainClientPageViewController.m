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

@interface LRMainClientPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mainClientTable;
@property (strong, nonatomic) NSMutableArray *aMainClientListArray;

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
    self.title = @"Document Library";
    self.aMainClientListArray = [[NSMutableArray alloc] initWithObjects:@"Today's Research",@"Symbol",@"Sector",@"Analyst", nil];
    [self.mainClientTable reloadData];
    self.mainClientTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

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
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [tableView setContentInset:UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)];
    
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone?@"Main_iPhone":@"Main_iPad" bundle:nil];
    LRDocumentTypeListController *documentTypeListViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentTypeListController class])];

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

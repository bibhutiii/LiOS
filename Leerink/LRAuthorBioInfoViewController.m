//
//  LRAuthorBioInfoViewController.m
//  Leerink
//
//  Created by Ashish on 1/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRAuthorBioInfoViewController.h"

@interface LRAuthorBioInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *authorInfoTextView;

@end

@implementation LRAuthorBioInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.authorInfoTextView.text = self.authorInfo;
    // Do any additional setup after loading the view.
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

//
//  LRTwitterListTableViewCell.m
//  Leerink
//
//  Created by Ashish on 26/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRTwitterListTableViewCell.h"

@interface LRTwitterListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *listUserNameLabel;

@end

@implementation LRTwitterListTableViewCell
- (void)fillDataForDocumentCellwithTwitterListMemberName:(NSString *)memberName
{
    self.listUserNameLabel.text = memberName;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

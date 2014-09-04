//
//  LRContactListTableViewCell.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRContactListTableViewCell.h"
@interface LRContactListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@end
@implementation LRContactListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)fillDataForContactCellwithName:(NSString *)contactName
{
    self.contactNameLabel.text = contactName;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

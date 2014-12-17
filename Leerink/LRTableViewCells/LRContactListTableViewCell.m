//
//  LRContactListTableViewCell.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRContactListTableViewCell.h"
@interface LRContactListTableViewCell ()
- (IBAction)author_Info_button_Clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
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
- (void)fillDataForMenuCellWithDisplayName:(NSString *)displayName andIconImage:(UIImage *)image
{
    self.contactNameLabel.text = displayName;
    self.iconImageView.image = image;
    if(image || ![[image CIImage] isKindOfClass:([NSNull class])]) {
        
    }
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

- (IBAction)author_Info_button_Clicked:(id)sender {
    if(self.iconImageView.image) {
        if([self.delegate respondsToSelector:@selector(showBioInformationForSelectedAnalystwithTag:)]) {
            [self.delegate showBioInformationForSelectedAnalystwithTag:(int)self.tag];
        }
    }
    NSLog(@"No image available");
}
@end

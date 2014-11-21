//
//  LRDocumentTypeTableViewCell.m
//  Leerink
//
//  Created by Ashish on 13/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRDocumentTypeTableViewCell.h"
@interface LRDocumentTypeTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *documentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectDocumentImage;
@property (weak, nonatomic) IBOutlet UIButton *infoForAuthorsButton;
@property (weak, nonatomic) IBOutlet UILabel *authorTitleLabel;
@end
@implementation LRDocumentTypeTableViewCell
- (IBAction)select_unselectDocument:(id)sender {
    
    NSLog(@"selected document tag %ld",(long)self.tag);
    if([self.delegate respondsToSelector:@selector(selectDocumentForRowWithIndex:)]) {
        [self.delegate selectDocumentForRowWithIndex:(int)self.tag];
    }
}
- (IBAction)infoForAuthorClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(infoForAuthorsSelected:withTag:)]) {
        [self.delegate infoForAuthorsSelected:sender withTag:(int)self.tag];
    }
}

- (void)fillDataForDocumentCellwithTitle:(NSString *)title andDateTime:(NSString *)date andAuthor:(NSString *)author andisDocumentSelected:(BOOL)isSelected hasMultipleAuthors:(BOOL)hasMultipleAuthors
{
    self.documentTitleLabel.text = title;
    self.dateLabel.text = date;
    self.authorTitleLabel.text = author;    
    
    self.documentTitleLabel.numberOfLines = 0;
    self.documentTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.documentTitleLabel.preferredMaxLayoutWidth = 230;
    
    if(isSelected) {
        self.selectDocumentImage.image = [UIImage imageNamed:@"checkbox"];
    }
    else {
        self.selectDocumentImage.image = [UIImage imageNamed:@"uncheckbox"];
    }

    CGFloat heightForImage = self.frame.size.height/2;
    self.selectDocumentImage.frame = CGRectMake(8, heightForImage, 22.0, 20.0);
    
    if(hasMultipleAuthors == FALSE) {
        self.infoForAuthorsButton.hidden = TRUE;
    }
    else {
        self.infoForAuthorsButton.hidden = FALSE;
    }
}

@end

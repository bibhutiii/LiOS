//
//  LRDocumentTypeTableViewCell.m
//  Leerink
//
//  Created by Ashish on 13/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRDocumentTypeTableViewCell.h"
@interface LRDocumentTypeTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *pdf_Only_button;
@property (weak, nonatomic) IBOutlet UILabel *documentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectDocumentImage;
@property (weak, nonatomic) IBOutlet UIButton *infoForAuthorsButton;
@property (weak, nonatomic) IBOutlet UILabel *authorTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *text_only_Button;
- (IBAction)show_text_only_version_of_document:(id)sender;
- (IBAction)show_pdf_for_text_only:(id)sender;
- (IBAction)slideMenuOut:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *slideOutMenuView;
@property (weak, nonatomic) IBOutlet UIButton *slideOutButton;
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
- (IBAction)slideMenuIn:(id)sender {
    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.slideOutMenuView.frame = CGRectMake(self.frame.size.width + self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.origin.y, self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.size.height);
        
    } completion:^(BOOL finished) {
        NSLog(@"done animating");
        
    }];

}

- (void)fillDataForDocumentCellwithTitle:(NSString *)title andDateTime:(NSString *)date andAuthor:(NSString *)author andisDocumentSelected:(BOOL)isSelected hasMultipleAuthors:(BOOL)hasMultipleAuthors showTextOnlyIcon:(BOOL)showTextOnlyIcon
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
    if(showTextOnlyIcon == FALSE) {
        
        self.text_only_Button.hidden = TRUE;
        self.pdf_Only_button.hidden = TRUE;
        self.slideOutButton.hidden = TRUE;
    }
    else {
        
        self.text_only_Button.hidden = FALSE;
        self.pdf_Only_button.hidden = FALSE;
        self.slideOutButton.hidden = FALSE;
        self.slideOutMenuView.frame = CGRectMake(self.frame.size.width + self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.origin.y, self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.size.height);
    }
}

- (IBAction)show_text_only_version_of_document:(id)sender {
    if([self.delegate respondsToSelector:@selector(showTextOnlyVersionOfTheDocumentWithTag:)]) {
        [self.delegate showTextOnlyVersionOfTheDocumentWithTag:(int)self.tag];
    }
}

- (IBAction)show_pdf_for_text_only:(id)sender {
    if([self.delegate respondsToSelector:@selector(showPDFOnlyVersionOfTheDocumentWithTag:)]) {
        [self.delegate showPDFOnlyVersionOfTheDocumentWithTag:(int)self.tag];
    }
}

- (IBAction)slideMenuOut:(id)sender {
    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.slideOutMenuView.frame = CGRectMake(self.frame.size.width - self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.origin.y, self.slideOutMenuView.frame.size.width, self.slideOutMenuView.frame.size.height);
        [self bringSubviewToFront:self.slideOutMenuView];
        
    } completion:^(BOOL finished) {
        NSLog(@"done animating");
        
    }];
}
@end

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
@property (weak, nonatomic) IBOutlet UIImageView *twitterListImageView;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation LRTwitterListTableViewCell
- (void)fillDataForDocumentCellwithTwitterListMemberName:(NSString *)memberName andMemberImage:(id )image
{
    self.listUserNameLabel.text = memberName;
    self.twitterListImageView.image = image;
}
- (void)fillDataForTweetCellWithTweet:(NSString *)iTweet andMemberImage:(id )image
{
    self.tweetTextView.text = iTweet;
    self.twitterListImageView.image = image;
    //self.tweetTextView.frame = CGRectMake(self.tweetTextView.frame.origin.x, self.tweetTextView.frame.origin.y, self.tweetTextView.frame.size.width, [self measureHeightOfUITextView:self.tweetTextView]);
}
- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        CGRect frame = textView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

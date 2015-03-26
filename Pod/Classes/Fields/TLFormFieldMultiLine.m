//
//  TLFormFieldMultiLine.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldMultiLine.h"
#import "TLFormField+Protected.h"



@interface TLFormFieldMultiLine () <UITextViewDelegate>

@end


@implementation TLFormFieldMultiLine {
    UITextView *textView;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        UILabel *titleLabel = (UILabel *) [titleView viewWithTag:TLFormFieldTitleLabelTag];
        titleLabel.textColor = [UIColor grayColor];
    }
    
    textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:12];
    textView.scrollEnabled = NO;
    textView.editable = editing;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.delegate = self;
    [self addSubview:textView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView, textView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-bp-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[textView]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-np-[titleView][textView]-sp-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    
    [self setValue:self.defautValue];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    for (UIView *subview in self.subviews) {
        width += subview.intrinsicContentSize.width;
        height += subview.intrinsicContentSize.height;
    }
    
    return CGSizeMake(width, height);
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    textView.text = fieldValue;
}

- (id)getValue {
    return textView.text;
}

//UITextFieldDelegate

- (void)textViewDidBeginEditing:(UITextView *)_textView {
    [self.formDelegate didSelectField:self];
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newValue = nil;
    if (text.length > 0)
        newValue = [_textView.text stringByAppendingString:text];
    else
        newValue = [_textView.text substringToIndex:_textView.text.length - 1];
    
    [self.formDelegate didChangeValueForField:self newValue:newValue];
    return YES;
}

@end

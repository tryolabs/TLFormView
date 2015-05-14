//
//  TLFormFieldSingleLine.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldSingleLine.h"
#import "TLFormField+Protected.h"


@interface TLFormFieldSingleLine () <UITextFieldDelegate>
@end


@implementation TLFormFieldSingleLine {
    UITextField *textField;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        
        UILabel *titleLabel = (UILabel *) [titleView viewWithTag:TLFormFieldTitleLabelTag];
        titleLabel.textColor = [UIColor grayColor];
        [self setupFieldForEditing];
        
    } else {
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.tag = TLFormFieldValueLabelTag;
        valueLabel.numberOfLines = 1;
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:valueLabel];
        
        //Adjust the compression resistance for each view so the labels resize always in the same way when the size of the container change. Without this set explicitly
        //the behavior is inconsistent
        [titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [valueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleView, valueLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-bp-[valueLabel]-bp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[valueLabel]-sp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
    
    [self setValue:self.defautValue];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    for (UIView *subview in self.subviews) {
        width += subview.intrinsicContentSize.width;
        //Don't acumulte the height, use the maximum
        height = MAX(height, subview.intrinsicContentSize.height);
    }
    
    return CGSizeMake(width, height);
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    NSString *stringValue;
    if ([fieldValue isKindOfClass:[NSString class]] == NO)
        stringValue = [fieldValue stringValue];
    else
        stringValue = fieldValue;
    
    if (textField)
        textField.text = stringValue;
    else
        self.valueViewText = stringValue;
}

- (id)getValue {
    if (textField)
        return textField.text;
    else
        return self.valueViewText;
}

//UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.formDelegate didSelectField:self];
    return YES;
}

- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    id newValue = nil;
    
    if (string.length > 0)
        newValue = [_textField.text stringByAppendingString:string];
    else
        newValue = [_textField.text substringToIndex:_textField.text.length - 1];
    
    [self.formDelegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

@end


@implementation TLFormFieldSingleLine (Protected)

- (NSString *)valueViewText {
    return [[self viewWithTag:TLFormFieldValueLabelTag] performSelector:@selector(text)];
}

- (void)setValueViewText:(NSString *)valueViewText {
    [[self viewWithTag:TLFormFieldValueLabelTag] performSelector:@selector(setText:) withObject:valueViewText];
}

- (UITextField *)textField {
    return textField;
}

- (void)setupFieldForEditing {
    
    textField = [[UITextField alloc] init];
    textField.textAlignment = NSTextAlignmentRight;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.borderStyle = UITextBorderStyleNone;
    textField.delegate = self;
    [self addSubview:textField];
    
    UIView *titleView = [self titleView];
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView, textField);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-np-[textField]-bp-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
}

@end
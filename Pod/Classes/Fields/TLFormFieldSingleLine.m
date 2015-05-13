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


@implementation TLFormFieldSingleLine

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

- (void)setupFieldForEditing {
    
    UITextField *textField = [[UITextField alloc] init];
    textField.tag = TLFormFieldValueLabelTag;
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
    
    
    id valueView = [self viewWithTag:TLFormFieldValueLabelTag];
    
    if ([valueView respondsToSelector:@selector(setText:)])
        [valueView performSelector:@selector(setText:) withObject:stringValue];
}

- (id)getValue {
    id valueView = [self viewWithTag:TLFormFieldValueLabelTag];
    
    if ([valueView respondsToSelector:@selector(text)]) {
        NSString *stringValue = [valueView performSelector:@selector(text)];
        return stringValue;
    }
    return nil;
}

//UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.formDelegate didSelectField:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    id newValue = nil;
    
    if (string.length > 0)
        newValue = [textField.text stringByAppendingString:string];
    else
        newValue = [textField.text substringToIndex:textField.text.length - 1];
    
    [self.formDelegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

@end


@implementation TLFormFieldSingleLine (Protected)

- (UITextField *)textField {
    return (UITextField *) [self viewWithTag:TLFormFieldValueLabelTag];
}

@end
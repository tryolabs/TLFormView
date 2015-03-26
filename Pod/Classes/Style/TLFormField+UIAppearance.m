//
//  TLFormField+UIApearance.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/26/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField+UIAppearance.h"
#import "TLFormField+Protected.h"
#import "TLFormAllFields.h"


int const TLFormFieldTitleLabelTag = 42001;
int const TLFormFieldValueLabelTag = 42002;


@implementation TLFormField (UIAppearance)

#pragma mark - Title label accessors

- (UILabel *)titleLabel {
    return (UILabel *) [self viewWithTag:TLFormFieldTitleLabelTag];
}

- (void)setTitleFont:(UIFont *)titleFont {
    [[self titleLabel] setFont:titleFont];
}

- (void)setTitleTextColor:(UIColor *)color {
    [[self titleLabel] setTextColor:color];
}

- (void)setTitleBackgroundColor:(UIColor *)color {
    [[self titleLabel] setBackgroundColor:color];
}

#pragma mark - Value label accessors

- (UILabel *)valueLabel {
    return (UILabel *) [self viewWithTag:TLFormFieldValueLabelTag];
}

- (void)setValueFont:(UIFont *)font {
    [[self valueLabel] setFont:font];
}

- (void)setValueTextColor:(UIColor *)color {
    [[self valueLabel] setTextColor:color];
}

- (void)setValueBackgroundColor:(UIColor *)color {
    [[self valueLabel] setBackgroundColor:color];
}

#pragma mark - Border Style

- (void)setBorderStyleMask:(TLFormBorderStyleMask)borderMask {
    self.borderStyle = borderMask;
}

#pragma mark - Appearance getters

+ (UIButton<UIAppearance> *)helpButtonAppearance {
    return [UIButton appearanceWhenContainedIn:[TLFormField class], nil];
}

+ (UIButton<UIAppearance> *)addButtonAppearance {
    return [UIButton appearanceWhenContainedIn:[TLFormFieldList class], nil];
}

+ (UISegmentedControl<UIAppearance> *)segmentedAppearance {
    return [UISegmentedControl appearanceWhenContainedIn:[TLFormFieldSingleLine class], nil];
}

+ (UISwitch<UIAppearance> *)switchAppearance {
    return [UISwitch appearanceWhenContainedIn:[TLFormFieldSingleLine class], nil];
}

+ (UITextField<UIAppearance> *)textFieldAppearance {
    return [UITextField appearanceWhenContainedIn:[TLFormFieldSingleLine class], nil];
}

@end

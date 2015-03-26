//
//  TLFormField+UIApearance.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/26/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"


@interface TLFormField (UIAppearance)

- (void)setTitleFont:(UIFont *)font UI_APPEARANCE_SELECTOR;
- (void)setTitleTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleBackgroundColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)setValueFont:(UIFont *)font UI_APPEARANCE_SELECTOR;
- (void)setValueTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setValueBackgroundColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)setBorderStyleMask:(TLFormBorderStyleMask)borderMask UI_APPEARANCE_SELECTOR;


+ (UIButton <UIAppearance> *) helpButtonAppearance;

+ (UIButton <UIAppearance> *) addButtonAppearance;

+ (UISegmentedControl <UIAppearance> *) segmentedAppearance;

+ (UISwitch <UIAppearance> *) switchAppearance;

+ (UITextField <UIAppearance> *) textFieldAppearance;

@end


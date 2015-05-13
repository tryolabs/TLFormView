//
//  TLFormFieldYesNo.m
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldYesNo.h"
#import "TLFormField+Protected.h"


@implementation TLFormFieldYesNo {
    UISwitch *yesNoSelect;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    if (editing) {
        yesNoSelect = [[UISwitch alloc] init];
        yesNoSelect.tag = TLFormFieldValueLabelTag;
        yesNoSelect.translatesAutoresizingMaskIntoConstraints = NO;
        [yesNoSelect addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:yesNoSelect];
        
        UIView *titleView = [self titleView];
        NSDictionary *views = NSDictionaryOfVariableBindings(titleView, yesNoSelect);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-bp-[yesNoSelect]-bp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        //The vertical constraints needs to be set with explicit contraints because the visual format language can't express this rules.
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:yesNoSelect
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:titleView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:0.0],
                               ]];
    }
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    if ([fieldValue isKindOfClass:[NSNumber class]]) {
        NSNumber *value = (NSNumber *) fieldValue;
        
        if (yesNoSelect)
            yesNoSelect.on = [value boolValue];
        else
            self.textField.text = [value boolValue] ? @"Yes" : @"No";
        
    } else
        [NSException raise:@"Invalid field value" format:@"TLFormFieldYesNo only accept fields of type NSNumber (boolean). Suplied value: %@", fieldValue];
}

- (id)getValue {
    if (yesNoSelect)
        return @(yesNoSelect.on);
    else
        return @([self.textField.text boolValue]);
}

- (void)controlValueChange {
    [self.formDelegate didChangeValueForField:self newValue:[self getValue]];
}

@end

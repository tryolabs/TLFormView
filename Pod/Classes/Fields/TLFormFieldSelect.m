//
//  TLFormFieldSelect.m
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldSelect.h"
#import "TLFormField+Protected.h"



@implementation TLFormFieldSelect {
    UISegmentedControl *segmented;
}

- (void)setupFieldForEditing {
    
    segmented = [[UISegmentedControl alloc] init];
    segmented.tag = TLFormFieldValueLabelTag;
    segmented.translatesAutoresizingMaskIntoConstraints = NO;
    [segmented addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
    
    for (NSString *choice in self.choicesValues)
        [segmented insertSegmentWithTitle:choice atIndex:[self.choicesValues indexOfObject:choice] animated:NO];
    
    [self addSubview:segmented];
    
    UIView *titleView = [self titleView];
    NSDictionary *views = NSDictionaryOfVariableBindings(titleView, segmented);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-[segmented]-np-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-bp-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[segmented]-bp-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    if ([fieldValue isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *) fieldValue;
        
        if (segmented) {
            for (int i = 0; i < [segmented numberOfSegments]; i++) {
                if ([stringValue isEqualToString:[segmented titleForSegmentAtIndex:i]]) {
                    segmented.selectedSegmentIndex = i;
                    break;
                }
            }
        } else
            self.textField.text = stringValue;
        
    } else
        [NSException raise:@"Invalid field value" format:@"TLFormFieldSelect only accept fields of type NSString. Suplied value: %@", fieldValue];
}

- (id)getValue {
    if (segmented)
        return [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    else
        return self.textField.text;
}

//UISegmented value change

- (void)controlValueChange {
    [self.formDelegate didChangeValueForField:self newValue:[self getValue]];
}

@end

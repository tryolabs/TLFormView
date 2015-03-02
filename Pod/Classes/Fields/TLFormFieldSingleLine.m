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

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        
        //This is needed to properly adjust the title when the text has more than one line
        [titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        switch (inputType) {
                
            case TLFormFieldInputTypeCustom:
            case TLFormFieldInputTypeNumeric:
            case TLFormFieldInputTypeDefault: {
                
                UITextField *textField = [[UITextField alloc] init];
                textField.tag = TLFormFieldValueLabelTag;
                textField.textAlignment = NSTextAlignmentRight;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                textField.delegate = self;
                
                [self addSubview:textField];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, textField);
                
                if (inputType == TLFormFieldInputTypeNumeric)
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-[textField]-sp-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[textField]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                
                break;
            }
                
            case TLFormFieldInputTypeInlineSelect: {
                
                UISegmentedControl *segmented = [[UISegmentedControl alloc] init];
                segmented.tag = TLFormFieldValueLabelTag;
                segmented.translatesAutoresizingMaskIntoConstraints = NO;
                [segmented addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
                
                for (NSString *choice in self.choicesValues)
                    [segmented insertSegmentWithTitle:choice atIndex:[self.choicesValues indexOfObject:choice] animated:NO];
                
                [self addSubview:segmented];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, segmented);
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView]-3.0-[segmented]-3.0-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[segmented]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                break;
            }
                
            case TLFormFieldInputTypeInlineYesNo: {
                
                UISwitch *yesNoSelect = [[UISwitch alloc] init];
                yesNoSelect.tag = TLFormFieldValueLabelTag;
                yesNoSelect.translatesAutoresizingMaskIntoConstraints = NO;
                [yesNoSelect addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
                
                [self addSubview:yesNoSelect];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, yesNoSelect);
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-bp-[yesNoSelect]-bp-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[yesNoSelect]-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                break;
            }
            default:
                break;
        }
        
        
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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-bp-[valueLabel]-np-|"
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
    
    
    id valueView = [self viewWithTag:TLFormFieldValueLabelTag];
    
    if ([valueView respondsToSelector:@selector(setText:)])
        [valueView performSelector:@selector(setText:) withObject:stringValue];
    
    else if ([valueView isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmented = (UISegmentedControl *)valueView;
        
        for (int i = 0; i < [segmented numberOfSegments]; i++) {
            if ([stringValue isEqualToString:[segmented titleForSegmentAtIndex:i]]) {
                segmented.selectedSegmentIndex = i;
                break;
            }
        }
    }
    
    else if ([valueView isKindOfClass:[UISwitch class]]) {
        UISwitch *yesNoSelect = (UISwitch *)valueView;
        yesNoSelect.on = [fieldValue boolValue];
    }
}

- (id)getValue {
    id valueView = [self viewWithTag:TLFormFieldValueLabelTag];
    
    if ([valueView respondsToSelector:@selector(text)])
        return [valueView performSelector:@selector(text)];
    
    else if ([valueView isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmented = (UISegmentedControl *)valueView;
        return [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    }
    
    else if ([valueView isKindOfClass:[UISwitch class]]) {
        UISwitch *yesNoSelect = (UISwitch *)valueView;
        return [NSNumber numberWithBool:yesNoSelect.on];
    }
    
    return nil;
}

//UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.delegate didSelectField:self];
    
    BOOL shouleEdit = self.inputType != TLFormFieldInputTypeCustom;
    [textField setShowGlow:shouleEdit withColor:self.highlightColor];
    
    [self.delegate didSelectField:self];
    
    return shouleEdit;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setShowGlow:NO withColor:self.highlightColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    id newValue = nil;
    if (string.length > 0)
        if (self.inputType == TLFormFieldInputTypeNumeric) {
            
            //The lenght constraint is allway 5 for now
            if (textField.text.length < 5) {
                
                //Check the min/max range
                if (self.minValue != self.maxValue) {
                    
                    //Get the final value
                    newValue = [textField.text stringByAppendingString:string];
                    NSInteger value = [newValue integerValue];
                    
                    //If the value is NOT in the range left it unchanged
                    if (value < self.minValue || value > self.maxValue)
                        return NO;
                } else {
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    formatter.numberStyle = NSNumberFormatterDecimalStyle;
                    newValue = [formatter numberFromString:[textField.text stringByAppendingString:string]];
                }
            } else
                return NO;
            
        } else
            newValue = [textField.text stringByAppendingString:string];
    
        else
            newValue = [textField.text substringToIndex:textField.text.length - 1];
    
    [self.delegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

//UISwitch and UISegmented value change

- (void)controlValueChange {
    [self.delegate didChangeValueForField:self newValue:[self getValue]];
}

@end


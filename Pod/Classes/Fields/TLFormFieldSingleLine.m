//
//  TLFormFieldSingleLine.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldSingleLine.h"
#import "TLFormField+Protected.h"


//This category is used for handling the mapping between NSNumber types (numberWithBool:, numberWithFloat:, etc) and his string values. Ex: you give a "numberWithBool" as value
//then the value is show as "Yes"/"No" and when the value is read you get a "numberWithBool" back. The same works for any type of number thanks to this category.
@interface NSNumber (NumberType)

- (CFNumberType)numberType;
+ (instancetype)numberOfType:(CFNumberType)type withValue:(id)value;

@end

//Add two specil values that will live side by side to the CFNumberType enum values
const short kTLNumberBooleanType    = -1;
const short kTLNumberNanType        = -2;

@implementation NSNumber (NumberType)

- (CFNumberType)numberType {
    //Get if a number is NSNumber-bool value (see: http://stackoverflow.com/questions/2518761/get-type-of-nsnumber )
    if (self == (id) kCFBooleanFalse || self == (id) kCFBooleanTrue)
        return kTLNumberBooleanType;
    else
        return CFNumberGetType((CFNumberRef)self);
}

//Given a type and a value return the corresponding NSNumber. This is like use NSNumberFormatter but much better.
+ (instancetype)numberOfType:(CFNumberType)type withValue:(id)value {
    
    const void *numberValue = NULL;
    
    switch (type) {
        case kCFNumberCharType:
        case kCFNumberSInt8Type: {
            char tmp = [value charValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberShortType:
        case kCFNumberSInt16Type: {
            short tmp = [value shortValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberIntType:
        case kCFNumberSInt32Type: {
            int tmp = [value intValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberLongType: {
            long tmp = [value longValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberLongLongType:
        case kCFNumberSInt64Type: {
            long long tmp = [value longLongValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberCGFloatType:
        case kCFNumberFloatType:
        case kCFNumberFloat32Type: {
            float tmp = [value floatValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberDoubleType:
        case kCFNumberFloat64Type: {
            double tmp = [value doubleValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberNSIntegerType: {
            NSInteger tmp = [value integerValue];
            numberValue = &tmp;
            break;
        }
        default:
            numberValue = NULL;
            break;
    }
    
    return CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, type, numberValue));
}

@end






@interface TLFormFieldSingleLine () <UITextFieldDelegate>
@end


@implementation TLFormFieldSingleLine {
    CFNumberType numberType;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        
        UILabel *titleLabel = (UILabel *) [titleView viewWithTag:TLFormFieldTitleLabelTag];
        titleLabel.textColor = [UIColor grayColor];
        
        switch (self.inputType) {
                
            case TLFormFieldInputTypeCustom:
            case TLFormFieldInputTypeNumeric:
            case TLFormFieldInputTypeDefault: {
                
                UITextField *textField = [[UITextField alloc] init];
                textField.tag = TLFormFieldValueLabelTag;
                textField.textAlignment = NSTextAlignmentRight;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                textField.borderStyle = UITextBorderStyleNone;
                textField.delegate = self;
                [self addSubview:textField];
                
                if (self.inputType == TLFormFieldInputTypeNumeric)
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, textField);
                
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-np-[textField]-bp-|"
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
                break;
            }
                
            case TLFormFieldInputTypeInlineYesNo: {
                
                UISwitch *yesNoSelect = [[UISwitch alloc] init];
                yesNoSelect.tag = TLFormFieldValueLabelTag;
                yesNoSelect.translatesAutoresizingMaskIntoConstraints = NO;
                [yesNoSelect addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
                
                [self addSubview:yesNoSelect];
                
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
    if ([fieldValue isKindOfClass:[NSString class]] == NO) {
        
        if ([fieldValue isKindOfClass:[NSNumber class]])
            numberType = [(NSNumber *) fieldValue numberType];
        else
            numberType = kTLNumberNanType;
        
        if (numberType == kTLNumberBooleanType)
            stringValue = [fieldValue boolValue] ? @"Yes" : @"No";
        else
            stringValue = [fieldValue stringValue];
    } else
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
    
    if ([valueView respondsToSelector:@selector(text)]) {
        NSString *stringValue = [valueView performSelector:@selector(text)];
        
        if (numberType == kTLNumberBooleanType)
            return @([stringValue boolValue]);
        
        else if (numberType != kTLNumberNanType)
            return [NSNumber numberOfType:numberType withValue:stringValue];
            
        else
            return stringValue;
    }
    
    else if ([valueView isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmented = (UISegmentedControl *)valueView;
        return [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    }
    
    else if ([valueView isKindOfClass:[UISwitch class]]) {
        UISwitch *yesNoSelect = (UISwitch *)valueView;
        return @(yesNoSelect.on);
    }
    
    return nil;
}

//UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.formDelegate didSelectField:self];
    return self.inputType != TLFormFieldInputTypeCustom;;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    id newValue = nil;
    
    if (string.length > 0)
        newValue = [textField.text stringByAppendingString:string];
    else
        newValue = [textField.text substringToIndex:textField.text.length - 1];
    
    //If the input type is numeric translate the value to an NSNumber in the same domain as the one given to the fild as initial value
    if (self.inputType == TLFormFieldInputTypeNumeric) {
        if (numberType == kTLNumberBooleanType)
            newValue = @([newValue boolValue]);
        
        else if (numberType != kTLNumberNanType)
            newValue = [NSNumber numberOfType:numberType withValue:newValue];
    }
    
    [self.formDelegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

//UISwitch and UISegmented value change

- (void)controlValueChange {
    [self.formDelegate didChangeValueForField:self newValue:[self getValue]];
}

@end


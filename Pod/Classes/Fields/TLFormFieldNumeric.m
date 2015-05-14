//
//  TLFormFieldNumeric.m
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldNumeric.h"
#import "TLFormField+Protected.h"
#import "NSNumber+NumberType.h"


@implementation TLFormFieldNumeric{
    CFNumberType numberType;
}

- (void)setupFieldForEditing {
    [super setupFieldForEditing];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    if ([fieldValue isKindOfClass:[NSNumber class]]) {
        NSNumber *value = (NSNumber *) fieldValue;
        numberType = [value numberType];
        NSString *stringValue = [value stringValue];
        
        if (self.textField)
            self.textField.text = stringValue;
        else
            self.valueViewText = stringValue;
    } else
        [NSException raise:@"Invalid field value" format:@"TLFormFieldNumeric only accept fields of type NSNumber. Suplied value: %@", fieldValue];
}

- (id)getValue {
    NSString *stringValue;
    
    if (self.textField)
        stringValue = self.textField.text;
    else
        stringValue = self.valueViewText;
        
    return [NSNumber numberOfType:numberType withValue:stringValue];
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
    
    //Translate the value to an NSNumber in the same domain as the one given to the fild as initial value
    newValue = [NSNumber numberOfType:numberType withValue:newValue];
    [self.formDelegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

@end

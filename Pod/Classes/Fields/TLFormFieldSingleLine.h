//
//  TLFormFieldSingleLine.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"



//The TLFormFieldType define how a fild will be showed. The TLFormFieldInputType define how a fild will behave when the form is in edit mode

typedef enum : NSUInteger {
    //The edition is done using the UITextField / UITextView class with and reported using the delegate
    TLFormFieldInputTypeDefault,
    //The keyboard is set to 'number pad' and the layout change to "title - value" with the text field for the value with a maximum of 50 pixels
    TLFormFieldInputTypeNumeric,
    //Instead of a UIText* control use a UISwitch
    TLFormFieldInputTypeInlineYesNo,
    //Instead of a UIText* control use a UISegmented control (This needs to be fixed to ask the data source for the options to show)
    TLFormFieldInputTypeInlineSelect,
    //This mark the field as disable and notify any tap using the form delegate. The controller should take care of the behavior
    TLFormFieldInputTypeCustom
} TLFormFieldInputType;



@interface TLFormFieldSingleLine : TLFormField

//How the field ascept and show values
@property (nonatomic, assign) TLFormFieldInputType inputType;

//The list of values to show in the segmented controll created for the LFormFieldInputTypeInlineSelect input type
@property (nonatomic, strong) NSArray *choicesValues;

@end



@interface TLFormFieldSingleLine (Protected)

@property (nonatomic, readonly) UITextField *textField;

@end
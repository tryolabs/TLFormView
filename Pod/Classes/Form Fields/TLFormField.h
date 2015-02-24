//
//  TLFormField.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import <UIKit/UIKit.h>



//Object in this class represent fields in the form. Each field can have one type of:

typedef enum : NSUInteger {
    //Reprecent an image in the form. Report when the image is tapped throught the form delegate.
    //Posible values for this type are: UIImage or NSURL pointing to an image
    TLFormFieldTypeImage,
    
    //Title like field. Only one line of text without field name sith big bold text
    //Posible values for this type are: NSString
    TLFormFieldTypeTitle,
    
    //A single row field. Show the value in a label
    //Posible values for this type are: NSString
    TLFormFieldTypeSingleLine,
    
    //A multi line text field. Show his value in a UITextView that adjust his size to the content (avoid scrolling)
    //Posible values for this type are: NSString
    TLFormFieldTypeMultiLine,
    
    //Show his value in a UITableView that adjust his size to the content (avoid scolling)
    //Posible values for this type are: NSArray of NSString
    TLFormFieldTypeList
} TLFormFieldType;

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


@interface TLFormField : UIView

//The field name is used to identify a field in the form. Is never showed to the user.
@property (nonatomic, strong) NSString *fieldName;

//The field name showed to the user. It's presented in a UILabel
@property (nonatomic, strong) NSString *title;

//The type of the field
@property (nonatomic, assign) TLFormFieldType fieldType;

//How the field ascept and show values
@property (nonatomic, assign) TLFormFieldInputType inputType;

//If not empty show a quesion mark button next to the field title when the form is on edit mode that when taped show a popver with this text
@property (nonatomic, strong) NSString *helpText;

@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, assign) NSInteger minValue;

//If this predicate evaluates to TRUE the field es visible. The predicate is evaluated every time a field value change, by an user interaction or by calling 'refreshValues'.
//In the predicate context, SELF is the TLFormField object that holds the predicate and all the other fields are accesible as variables.
//
//Example:
//          field.visibilityPredicate = [NSPredicate predicateWithFormat:@"$ingredients.value[SIZE] > 4"];
//
//Keep in mind that the type of 'value' may change depending the TLFormFieldType and TLFormFieldInputType of the field being referenced in the expresion.
//
//IMPORTANT: to hide the fileds the form create an NSLayoutConstraint for the field height and set it to 0.0. If some other field in the layout definition is taied to this field
//height in any way it will also be affected. Also because this add a new constraint it can cause an inconsistenci in the layout system and throw an exception. (Don't panic, look
//here: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/AutolayoutPG.pdf - "Auto Layout Degrades Gracefully with Unsatisfiable Constraints"
//
@property (nonatomic, strong) NSPredicate *visibilityPredicate;

//The list of values to show in the segmented controll created for the TLFormFieldTypeSingleLine / TLFormFieldInputTypeInlineSelect combination
@property (nonatomic, strong) NSArray *choicesValues;


//Construct a field with the given parameters. The defaul value is the one that should be visible if no value is returned throuht the TLFormViewDataSource
+ (id)formFieldWithType:(TLFormFieldType)fieldType name:(NSString *)fieldName title:(NSString *)displayName andDefaultValue:(id)defaultValue;

@end


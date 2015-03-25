//
//  TLFormField.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    TLFormFieldBorderNone   = 0,
    TLFormFieldBorderTop    = 1 << 0,
    TLFormFieldBorderRight  = 1 << 1,
    TLFormFieldBorderBotom  = 1 << 2,
    TLFormFieldBorderLeft   = 1 << 3,
    TLFormFieldBorderAll    = 255
} TLFormFieldBorder;

typedef char TLFormBorderStyleMask;


//Uncoment this to color all the subviews to chack any posible layout issues
//#define TLFormViewLayoutDebug


/**
 @abstract Represent a filed in that will be show in a TLFormView
 @discussion This is the base class for all the fields that can be used in the TLFormView.
 */
@interface TLFormField : UIView

///The field name is used to identify a field in the form. Is never showed to the user.
@property (nonatomic, strong) NSString *fieldName;

///If not empty show a quesion mark button next to the field title when the form is on edit mode that when taped show a popver with this text
@property (nonatomic, strong) NSString *helpText;

///Mask that tells which borders should be draw
@property (nonatomic, assign) TLFormBorderStyleMask borderStyle;

/**
 @abstract Predicate used to determine the visibility of this field.
 @discussion If this predicate evaluates to TRUE the field es visible. The predicate is evaluated every time a field value change, by an user interaction or by calling 'refreshValues'. In the predicate context, SELF is the TLFormField object that holds the predicate and all the other fields are accesible as variables.
 
 Example: field.visibilityPredicate = [NSPredicate predicateWithFormat:@"$ingredients.value[SIZE] > 4"];
 
 Keep in mind that the type of 'value' may change depending the TLFormFieldType and TLFormFieldInputType of the field being referenced in the expresion.
 
 IMPORTANT: to hide the fileds the form create an NSLayoutConstraint for the field height and set it to 0.0. If some other field in the layout definition is taied to this field height in any way it will also be affected. Also because this add a new constraint it can cause an inconsistenci in the layout system and throw an exception. (Don't panic, look here: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/AutolayoutPG.pdf - "Auto Layout Degrades Gracefully with Unsatisfiable Constraints"
 */
@property (nonatomic, strong) NSPredicate *visibilityPredicate;

/**
 @abstract Construct a field with the given parameters.
 @discussion Designated contrstructor for all the TLFormFields.
 @param fieldName The name of the fields
 @param displayName The title of the field
 @param defaultValue The value to use as default if there is no value returned form the data source
 @return A new instance of TLFormField
 */
+ (instancetype)formFieldWithName:(NSString *)fieldName title:(NSString *)displayName andDefaultValue:(id)defaultValue;

@end

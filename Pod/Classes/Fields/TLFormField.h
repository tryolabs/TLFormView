//
//  TLFormField.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import <UIKit/UIKit.h>


//Uncoment this to color all the subviews to chack any posible layout issues
//#define TLFormViewLayoutDebug


@interface TLFormField : UIView

//The field name is used to identify a field in the form. Is never showed to the user.
@property (nonatomic, strong) NSString *fieldName;

//If not empty show a quesion mark button next to the field title when the form is on edit mode that when taped show a popver with this text
@property (nonatomic, strong) NSString *helpText;

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

//Construct a field with the given parameters. The defaul value is the one that should be visible if no value is returned throuht the TLFormViewDataSource
+ (instancetype)formFieldWithName:(NSString *)fieldName title:(NSString *)displayName andDefaultValue:(id)defaultValue;

@end

//
//  TLFormView.h
//  TLFormView
//
//  Created by Bruno Berisso on 3/19/14.
//  Copyright (c) 2014 Gathered Table LLC. All rights reserved.
//

#import <UIKit/UIKit.h>



/************************************************************************************************************************************************/
/***************************************************************  TLFormField  ******************************************************************/
/************************************************************************************************************************************************/

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


/************************************************************************************************************************************************/
/*******************************************************  TLFormView Delegate and Data Source  **************************************************/
/************************************************************************************************************************************************/

//This delegate is fired when the user interact with any of the fields.

@class TLFormView;
@protocol TLFormViewDelegate

@optional

//The meaning of 'selected' change acording to the field type:
// - TLFormFieldTypeImage: the user tap over the image
// - TLFormFieldTypeTitle: not called
// - TLFormFieldTypeSingleLine: in edit mode and for fields with TLFormFieldInputType == TLFormFieldInputTypeCustom, called when the user tap over the field
// - TLFormFieldTypeMultiLine: not called
// - TLFormFieldTypeList: in edit mode, the user tap the "+" button
- (void)formView:(TLFormView *)form didSelecteField:(TLFormField *)field;

//In edit mode, called when a row is removed from the list. The controler should update the model.
- (void)formView:(TLFormView *)form listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

//In edit mode, called to check if a row could be moved to a different possition in the list.
- (BOOL)formView:(TLFormView *)form listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

//In edit mode, called when a row is moved from when position to another
- (void)formView:(TLFormView *)form listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

//In edit mode, called when the user change the value of some field.
- (void)formView:(TLFormView *)form didChangeValueForField:(TLFormField *)field newValue:(id)value;

@end


//This data source is a formal protocol to describe the setup process of the form.
@protocol TLFormViewDataSource <NSObject>

@optional

//Return the actual values to show in each field. If this method is not implemented the values are allways the ones set as default. Keep in mind that if this method is
//omited the calls to 'refreshValues' made to GTFromView will have no effect
- (id)formView:(TLFormView *)form valueForFieldWithName:(NSString *)fieldName;

- (TLFormFieldInputType)formView:(TLFormView *)form inputTypeForFieldWithName:(NSString *)fieldName;

@required

//Return an array of NSString's corresponding to the 'fieldName' of the TLFormField
- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form;

//Return the TLFormField object for a given 'fieldName'
- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName;

//Return an array of NSStrings. Each string is a constraint to be applied to the form using the to 'constraintsWithVisualFormat:' method of NSLayoutConstrin with the only
//difference that instead of use the view names it should have the field names. e.g:
//
//  TLFormField *userNameField = [TLFormField formFieldWithType:TLFormFieldTypeSingleLine name:@"userName" displayName:@"User Name" andDefaultValue:nil];
//
//  [form addConstraintsWithFormat:@[@"V:|-padding-[userName]-padding-|"]];
//
//Because the TLFormField is a subclass of UIScrollView is important to note that the constraints must be absolute in therms of size. For more details
//see the 'addConstraintsWithFormat:' in TLFormView and check the documentation at
//https://developer.apple.com/library/ios/documentation/userexperience/conceptual/AutolayoutPG/AutoLayoutbyExample/AutoLayoutbyExample.html#//apple_ref/doc/uid/TP40010853-CH5-SW2
- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form;

@end


/************************************************************************************************************************************************/
/****************************************************************  TLFormView  ******************************************************************/
/************************************************************************************************************************************************/

//The form view is a subclass of UIScrollView that position his subviews using autolayout constraints. The constraints must be provided by the user
//of the view. The TLFormView provide means of interaction with his fields throuht a delegate.

//The setup is performed by calling the 'setupFields' method. Multiple calls to this method are allowed, each call remove all the previous setup and
//start over.

//The values in the form can be refreshed using the 'refreshValues' method and can be read using the 'valuesForFields' method that returns a NSDictionary
//with the 'fieldName' property as key.


@interface TLFormView : UIScrollView

//This is the default padding used in the format strings of that define the layout. If changed after the layout was applied has no efect.
@property (nonatomic, assign) CGFloat padding;

//Set the editing state on all the fields.
@property (nonatomic, assign) BOOL editing;

//Set the editing state on all the fields and prioritize the default values in the first load
@property (nonatomic, assign) BOOL editingNew;

//Delegate that recieve a message every time the user interact with a field that's report interaction
@property (nonatomic, weak) IBOutlet id <TLFormViewDelegate> formDelegate;

//Data source
@property (nonatomic, weak) IBOutlet id <TLFormViewDataSource> formDataSource;

//Header and footer to show in the form
@property (nonatomic, weak) IBOutlet UIView *header;
@property (nonatomic, weak) IBOutlet UIView *footer;

//Setup the form making the appropiet calls to the data source passed as argument.
- (void)setupFields;

//Read the values for all the fields in the form. The returned dicionary has the 'fieldName' property of the fields as key and a value of the coresponding type depending on
//the field type set when created.
- (NSDictionary *)valuesForFields;

//Refresh the values in the fields. Send a 'valueForFieldWithName' to the data source to get the new values.
- (void)reloadValues;

@end

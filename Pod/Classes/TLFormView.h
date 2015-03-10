//
//  TLFormView.h
//  TLFormView
//
//  Created by Bruno Berisso on 3/19/14.
//  Copyright (c) 2014 Gathered Table LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLFormField.h"


/************************************************************************************************************************************************/
/*******************************************************  TLFormView Delegate and Data Source  **************************************************/
/************************************************************************************************************************************************/

/**
 @abstract Basic interaction with the fields
 @discussion This delegate is fired when the user interact with any of the fields.
 */
@class TLFormView;
@protocol TLFormViewDelegate <NSObject>

@optional

/**
 @abstract Called when the field is selected.
 @discussion When this method is fired depends of the TLFormField implementation that handle the field. In the mayority of the cases it's obvious when a field is selected (ex: a UISegmentedControl in a field)
 @param form The TLFormView instance being setup
 @param field The TLFormField instance that fire the event
 */
- (void)formView:(TLFormView *)form didSelectField:(TLFormField *)field;

/**
 @abstract In edit mode, called when the user change the value of some field.
 @discussion When this method is fired depends of the TLFormField implementation that handle the field. In the mayority of the cases it's obvious when a value change (ex: a UISegmentedControl in a field)
 @param form The TLFormView instance being setup
 @param field The TLFormField instance that fire the event
 @param value The new value of the field
 */
- (void)formView:(TLFormView *)form didChangeValueForField:(TLFormField *)field newValue:(id)value;

@end


/**
 @abstract Data source to describe the setup process of the form.
 @discussion This protocol delegates the setup process of the TLFormView to another object.
 */
@protocol TLFormViewDataSource <NSObject>

@optional

/**
 @abstract Return the actual values to show in each field
 @discussion If this method is not implemented the values are allways the ones set as default. Keep in mind that if this method is omited the calls to 'refreshValues' made to TLFromView will have no effect
 @param form The TLFormView instance being setup
 @param fieldName The name of the field
 @return The value corresponding the field name
 */
- (id)formView:(TLFormView *)form valueForFieldWithName:(NSString *)fieldName;

@required

/**
 @abstract Return an array of NSStrings corresponding to the 'fieldName' of the TLFormField.
 @param form The TLFormView instance being setup
 @return An NSArray of field names
 */
- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form;

/**
 @abstract A TLFormField for a given field name
 @discussion Return a TLFormField sublass instance for a given field name.
 @param form The TLFormView instance being setup
 @param fieldName The name of the field
 @return The TLFormField object for a given 'fieldName'
 */
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


/**
 @abstract The form view
 @discussion The form view is a subclass of UIScrollView that position his subviews using autolayout constraints. The constraints must be provided by the user of the view. The TLFormView provide means of interaction with his fields throuht a delegate. 
 The setup is performed by calling the 'setupFields' method or in the first call to 'layoutSubviews'. Multiple calls to this method are allowed, each call remove all the previous setup and start over. The values in the form can be refreshed using the 'refreshValues' method and can be read using the 'valuesForFields' method that returns a NSDictionary with the 'fieldName' property as key.
*/
@interface TLFormView : UIScrollView

///This is the default margin used in the format strings of that define the layout. If changed after the layout was applied has no efect.
@property (nonatomic, assign) CGFloat margin;

////Set the editing state on all the fields.
@property (nonatomic, assign) BOOL editing;

////Delegate that recieve a message every time the user interact with a field that's report interaction
@property (nonatomic, weak) IBOutlet id <TLFormViewDelegate> formDelegate;

////Data source
@property (nonatomic, weak) IBOutlet id <TLFormViewDataSource> formDataSource;

///Header to show in the form
@property (nonatomic, weak) IBOutlet UIView *header;
///Footer to show in the form
@property (nonatomic, weak) IBOutlet UIView *footer;

/**
 @abstract Setup the form.
 @discussion Make the appropiet calls to the 'formDataSource' and construct the form.
 */
- (void)setupFields;

/**
 @abstract Read the values for all the fields in the form.
 @discussion The returned dicionary has the 'fieldName' property of the fields as key and a value of the coresponding type depending on the field type set when created.
 @return A NSDictionary containing all the values of the form.
 */
- (NSDictionary *)valuesForFields;

/**
 @abstract Refresh the values in the fields.
 @discussion Get the values for each field sending a 'formView:valueForFieldWithName:' to the data source to get the new values and set it on each field.
 */
- (void)reloadValues;

@end

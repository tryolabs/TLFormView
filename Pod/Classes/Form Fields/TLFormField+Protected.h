//
//  TLFormField+Protected.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"
#import "UIView+Glow.h"



//Private delegate to pass events from the fields to the form

@protocol TLFormFieldDelegate <NSObject>

- (void)didSelectField:(TLFormField *)field;
- (void)listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (void)didChangeValueForField:(TLFormField *)field newValue:(id)value;

@end




//Forward declaration of some properties and methods used for the subclases

@interface TLFormField ()

@property (nonatomic, strong) id defautValue;
@property (nonatomic, weak) id <TLFormFieldDelegate> delegate;
@property (nonatomic, assign) CGFloat titleLabelFontSize;
@property (nonatomic, readonly) NSDictionary *defaultMetrics;

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing;
- (void)setValue:(id)fieldValue;
- (id)getValue;
- (UIView *)titleView;

@end
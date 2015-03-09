//
//  TLFormField+Protected.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"
#import "TLFormField+UIAppearance.h"
#import "UIView+Glow.h"



//Private delegate to pass events from the fields to the form

@protocol TLFormFieldDelegate <NSObject>

- (void)didSelectField:(TLFormField *)field;
- (void)didChangeValueForField:(TLFormField *)field newValue:(id)value;

@end


extern int const TLFormFieldTitleLabelTag;
extern int const TLFormFieldValueLabelTag;


//Forward declaration of some properties and methods used for the subclases

@interface TLFormField ()

@property (nonatomic, strong) id defautValue;
@property (nonatomic, weak) id <TLFormFieldDelegate> formDelegate;
@property (nonatomic, readonly) NSDictionary *defaultMetrics;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, assign) TLFormBorderStyleMask borderStyle;
@property (nonatomic, strong) NSString *title;


- (void)setupField:(BOOL)editing;
- (void)setValue:(id)fieldValue;
- (id)getValue;
- (UIView *)titleView;

@end
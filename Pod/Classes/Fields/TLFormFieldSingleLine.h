//
//  TLFormFieldSingleLine.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"


@interface TLFormFieldSingleLine : TLFormField

@end


@interface TLFormFieldSingleLine (Protected)

@property (nonatomic, readonly) UITextField *textField;
- (void)setupFieldForEditing;

@end
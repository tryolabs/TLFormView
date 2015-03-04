//
//  TLFormModel.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLFormView.h"


@interface TLFormSeparator : NSObject @end
TLFormSeparator * TLFormSeparatorValue ();


@interface TLFormText : NSString @end
TLFormText * TLFormTextValue(NSString *text);

@interface TLFormLongText : NSString @end
TLFormLongText * TLFormLongTextValue(NSString *longText);

@interface TLFormTitle : NSString @end
TLFormTitle * TLFormTitleValue (NSString *title);


@interface  TLFormNumber : NSNumber @end
TLFormNumber * TLFormNumberValue (NSNumber *number);

@interface  TLFormBoolean : NSNumber @end
TLFormBoolean * TLFormBooleanValue (BOOL boolean);

@interface TLFormEnumerated : NSDictionary @end
extern NSString * const TLFormEnumeratedSelectedValue;
extern NSString * const TLFormEnumeratedAllValues;

TLFormEnumerated * TLFormEnumeratedValue (id current, NSArray *all);


@interface TLFormList : NSArray @end
TLFormList * TLFormListValue(NSArray *array);


@interface TLFormImage : NSObject @end
TLFormImage * TLFormImageValue (NSObject *urlOrImage);



@interface TLFormModel : NSObject <TLFormViewDataSource, TLFormViewDelegate>

@end

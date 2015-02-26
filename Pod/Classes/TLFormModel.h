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


@interface TLFormText : NSString @end
@interface TLFormLongText : NSString @end
@interface TLFormTitle : NSString @end


@interface  TLFormNumber : NSNumber @end
@interface  TLFormBoolean : NSNumber @end


@interface TLFormEnumerated : NSDictionary @end
extern NSString * const TLFormEnumeratedSelectedValue;
extern NSString * const TLFormEnumeratedAllValues;


@interface TLFormList : NSArray @end


@interface TLFormImage : NSObject @end


@interface TLFormDate : NSDate @end



@interface TLFormModel : NSObject <TLFormViewDataSource, TLFormViewDelegate>

@end

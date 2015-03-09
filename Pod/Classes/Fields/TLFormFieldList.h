//
//  TLFormFieldList.h
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"


@protocol TLFormFieldListDelegate <NSObject>

//In edit mode, called when a row is removed from the list. The controler should update the model.
- (void)listFormField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

//In edit mode, called to check if a row could be moved to a different possition in the list.
- (BOOL)listFormField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

//In edit mode, called when a row is moved from when position to another
- (void)listFormField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

//In edit mode, called when the user tap the '+' icon
- (void)listFormFieldAddAction:(TLFormField *)field;

@end


@interface TLFormFieldList : TLFormField

@property (nonatomic, weak) id <TLFormFieldListDelegate> delegate;

@end

//
//  ViewController.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/23/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "ViewController.h"
#import "TLFormView.h"
#import "TLFormModel.h"



/*
 TLFormText
 TLFormLongText
 TLFormNumber
 TLFormBoolean
 TLFormEnumerated
 TLFormImage
 TLFormList
 - TLFormDate
 TLFormTitle
*/






@interface UserModel : TLFormModel

@property (nonatomic, strong) TLFormTitle *user_info;
@property (nonatomic, strong) TLFormImage *avatar;
@property (nonatomic, strong) TLFormText *name;
@property (nonatomic, strong) TLFormNumber *age;
@property (nonatomic, strong) TLFormLongText *_description;
@property (nonatomic, strong) TLFormEnumerated *hobbies;
@property (nonatomic, strong) TLFormList *friends;

@end

@implementation UserModel

@end














@interface ViewController () <TLFormViewDelegate>
@property (weak, nonatomic) IBOutlet TLFormView *form;
@end

@implementation ViewController {
    UserModel *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [[UserModel alloc] init];
    
    user.name = (TLFormText *) @"Some Long Name";
    user.age = (TLFormNumber *) @42;
    user._description = (TLFormLongText *) @"It is possible to subclass NSString (and NSMutableString), but doing so requires providing storage facilities for the string (which is not inherited by subclasses) and implementing two primitive methods. The abstract NSString and NSMutableString classes are the public interface of a class cluster consisting mostly of private, concrete classes that create and return a string object appropriate for a given situation. Making your own concrete subclass of this cluster imposes certain requirements (discussed in “Methods to Override”).";
    user.friends = (TLFormList *) @[@"friend 0", @"friend 1", @"friend 2", @"friend 3", @"friend 4"];
    user.hobbies = (TLFormEnumerated *) @{TLFormEnumeratedSelectedValue: @"Current one", TLFormEnumeratedAllValues : @{@"other 1": @2, @"other 2": @3}};
    
    self.form.formDataSource = user;
}

@end

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
#import "TLFormFieldList.h"



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
//@property (nonatomic, strong) TLFormImage *avatar;
@property (nonatomic, strong) TLFormText *name;
@property (nonatomic, strong) TLFormNumber *age;
@property (nonatomic, strong) TLFormBoolean *is_blonde;
@property (nonatomic, strong) TLFormEnumerated *hobbies;
@property (nonatomic, strong) TLFormSeparator *separator;
@property (nonatomic, strong) TLFormLongText *_description;
@property (nonatomic, strong) TLFormList *friends;

@end

@implementation UserModel @end




/*
 Face:
 - Color de fondo form
 - Color de fondo del titulo de un field
 - Color de fondo del valor de un field
 - Fuente del titulo de un field
 - Fuente del valor de un field
 - Color del segmented
 - Color / icono del help y add para listas
 - Color / fuente para el popup de help
 */









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
    user.is_blonde = (TLFormBoolean *) @YES;
    user._description = (TLFormLongText *) @"It is possible to subclass NSString (and NSMutableString), but doing so requires providing storage facilities for the string (which is not inherited by subclasses) and implementing two primitive methods. The abstract NSString and NSMutableString classes are the public interface of a class cluster consisting mostly of private, concrete classes that create and return a string object appropriate for a given situation. Making your own concrete subclass of this cluster imposes certain requirements (discussed in “Methods to Override”).";
    user.friends = (TLFormList *) @[@"friend 0", @"friend 1", @"friend 2", @"friend 3", @"friend 4"];
    user.hobbies = (TLFormEnumerated *) @{TLFormEnumeratedSelectedValue: @"other 1", TLFormEnumeratedAllValues : @[@"other 1", @"other 2"]};
    
    self.form.formDataSource = user;
    self.form.formDelegate = user;
    
    self.form.backgroundColor = [UIColor lightGrayColor];
    [[TLFormField appearance] setBackgroundColor:[UIColor whiteColor]];
    
    [[UISegmentedControl appearanceWhenContainedIn:[TLFormField class], nil] setTintColor:[UIColor magentaColor]];
    [[UITextField appearanceWhenContainedIn:[TLFormField class], nil] setBackgroundColor:[UIColor greenColor]];
    [[UITextView appearanceWhenContainedIn:[TLFormField class], nil] setBackgroundColor:[UIColor brownColor]];
}

- (IBAction)toggleEditionAction:(id)sender {
    self.form.editing = !self.form.editing;
    [self.form setupFields];
}

@end

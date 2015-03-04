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
#import "TLFormField+UIAppearance.h"


/*
 TLFormText
 TLFormLongText
 TLFormNumber
 TLFormBoolean
 TLFormEnumerated
 TLFormImage
 TLFormList
 TLFormTitle
*/






@interface UserModel : TLFormModel

@property (nonatomic, strong) TLFormTitle *user_info;
@property (nonatomic, strong) TLFormImage *avatar;
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
    
    user.name = TLFormTextValue(@"Some Long Name");
    user.age = TLFormNumberValue(@42);
    user.is_blonde = TLFormBooleanValue(YES);
    user._description = TLFormLongTextValue(@"It is possible to subclass NSString (and NSMutableString), but doing so requires providing storage facilities for the string (which is not inherited by subclasses) and implementing two primitive methods. The abstract NSString and NSMutableString classes are the public interface of a class cluster consisting mostly of private, concrete classes that create and return a string object appropriate for a given situation. Making your own concrete subclass of this cluster imposes certain requirements (discussed in “Methods to Override”).");
    user.friends = TLFormListValue(@[@"friend 0", @"friend 1", @"friend 2", @"friend 3", @"friend 4"]);
    user.hobbies = TLFormEnumeratedValue(@"other 1", @[@"other 1", @"other 2"]);
    
    NSURL *url = [NSURL URLWithString:@"http://www.infragistics.com/community/cfs-filesystemfile.ashx/__key/CommunityServer.Components.Avatars/00.00.00.22.06/4TR8IIORTEON.jpg_2D00_90x90.jpg"];
    user.avatar = TLFormImageValue(url);
    
    self.form.formDataSource = user;
    self.form.formDelegate = user;
    
    self.form.backgroundColor = [UIColor lightGrayColor];
    [[TLFormField appearance] setBackgroundColor:[UIColor whiteColor]];
    [[TLFormField appearance] setHightlightColor:[UIColor blueColor]];
    [[TLFormField textFieldAppearance] setBorderStyle:UITextBorderStyleRoundedRect];
}

- (IBAction)toggleEditionAction:(id)sender {
    self.form.editing = !self.form.editing;
    [self.form setupFields];
}

@end

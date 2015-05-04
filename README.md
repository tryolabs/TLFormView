# TLFormView

[![CI Status](http://img.shields.io/travis/BrunoBerisso/TLFormView.svg?style=flat)](https://travis-ci.org/BrunoBerisso/TLFormView)
[![Version](https://img.shields.io/cocoapods/v/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)
[![License](https://img.shields.io/cocoapods/l/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)
[![Platform](https://img.shields.io/cocoapods/p/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)

TLFormView is _yet another_ form view *trully* universal. This means that the same component support both iPhone and iPad using a mechanism around the [Auto Layout Visual Format] to adjust the layout to the runing device.

Because it doesn't extend ``UITableView`` you are completly free to create anything to use as a form field as long as it extends the base ``TLFormField`` class. It also has some nice fetures like: conditional visibility using ``NSPredicate``, in-place help for each field with ``UIPopoverControler`` and on-the-fly edit/read-only modes switch among other things.

## Usage

#### Form Setup

There is two baisc components: ``TLFormView`` and ``TLFormField``. ``TLFormView`` inherit from UIScrollView and add another data source and delegate to create and handle events form the form. You need to impement three methods of the ``TLFormViewDataSource`` protocol to get the form functional, these are:

```objective-c
- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form;

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName;

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form;
```

``fieldNamesToShowInFormView:`` return an array of strings containing the _field names_ (or ids) used to identify the fields in the form. ``formView:fieldForName:`` creates a field for every field name in the form. A field is any subclass of ``TLFormField`` (that is a sub class of ``UIView``), there is a set of default fields that can be used to fit the 80% of the use case. These are:

- ``TLFormFieldImage``: for display images form an url or a raw image
- ``TLFormFieldList``: for display a list of things
- ``TLFormFieldMultiLine``: to show long text
- ``TLFormFieldSingleLine``: to show short text, numbers and bool values
- ``TLFormFieldTitle``: to show a short text formated as a title

The project has a category over ``TLFormField`` with basic methods for customizing the aspect of the filds. It has some methods to configure the title and give access to the ``UIAppearance`` proxy of the internal components.

Once you give a ``TLFormField`` for each field name to the form you need to define how to layout those fields. To do so you need to implement the third method of the data source ``constraintsFormatForFieldsInForm:`` and return an array of strings containing the the rules in [Auto Layout Visual Format] to place the fields in the screen. When writing the rules you need to reference the fields using the field names you return in the ``fieldNamesToShowInFormView:`` implementation. Here you have the chance to check for the capabilities of the device and adapt your layout changing the rules as you need.

Here is an example implementation of the three requiered methods in ``TLFormViewDataSource``:

```objective-c
- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    return @[
        @"user_name",
        @"avatar",
        @"age",
    ];
}

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
    Class fieldClass;
    NSString *title;
    id value;

    if ([fieldName isEqualToString:@"user_name"]) {
        fieldClass = [TLFormFieldSingleLine class];
        title = @"User Name";
        value = userModel.name;
    }
    else if ([fieldName isEqualToString:@"avatar"]) {
        fieldClass = [TLFormFieldImage class];
        title = @"Avatar";
        value = userModel.avatarUrl;
    }
    else {
        fieldClass = [TLFormFieldSingleLine class];
        title = @"Age";
        value = userModel.age;
    }

    return [fieldClass formFieldWithName:fieldName title:title andDefaultValue:value];
}

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    
    //For iPhone we want a vertical layout like we get on a UITableView

    if (isIPhone) {
        return @[
            //Place the avatar on the top
            @"V:|-[avatar(==230)]-",
            @"H:|-[avatar(==420)]-|",
        
            //Now place all the fields to the bottom
            @"V:[avatar]-[user_name(>=44)]-",
            @"H:|-[user_name]-|",
        
            @"V:[age(==user_name)]-|",
            @"H:|-[age]-|"
        ];

    //For anyting else we will place the image on the top left and the rest of the fields to the right
    } else {
        return @[

            //Place the avatar on the top left
            @"V:|-[avatar(==230)]",
            @"H:|-[avatar]",
        
            //Now place all the fields to the right
            @"V:|-[user_name(>=44)]",
            @"H:|-[avatar]-[user_name]-|",
        
            @"V:[user_name]-[age(==user_name)]-|",
            @"H:|-[avatar(==420)]-[age]-|"
        ];
    }
}
```

This example produce this on iPhone

![iPhone result](Screenshots/iphone_ex_1.png)

and this on iPad

![iPad result](Screenshots/ipad_ex_1.png)

##### TLFormModel

To help you with the setup of the form there is a class ``TLFormModel`` that do what we just did automatically inferring the implementation of the ``TLFormViewDataSource`` form his own taxonomy. You only need to extend it and add one property for each field you want to show in the form. The types of the properties must be one of the types declared in the file TLFormModel.h. Each type corresponds to one of the standar ``TLFormField`` provided.

To read the values from the form just access the properties like you wold do on any object. To write the values you will need to wrap the values in one of the value constructors provide for each type. Once the values in the model are updated you need to manually perform a reload to show the new values with the ``reloadValues`` method of ``TLFormView`` (this is a cheep update, no view destruction is involved).

These are the declarations for the types supportd by ``TLFormModel``:
- ``TLFormSeparator``: extend NSObject. Rendered as a separator in the form, allow to group fields in sections. Has no value or title.
- ``TLFormText``: extend NSString.
- ``TLFormLongText``: extend NSString.
- ``TLFormTitle``: extend NSString.
- ``TLFormNumber``: extend NSNumber.
- ``TLFormBoolean``: extend NSNumber.
- ``TLFormList``: extend NSArray.
- ``TLFormEnumerated``: extend NSDictionary.
- ``TLFormImage``: extend NSObject.

These classes doesn't have any logic other than the one hinerited form his superclasses, they act almost as an annotation over a property. The intended way to construct values of this types is whith plain C functions declared in the TLFormModel.h that check the type of the parameter and copy the value given as parameter.

Using the type and value of his properties ``TLFormModel`` infere what kind of form field should use for each property. For the field title the property name is used. If the property name use snake-case naming convention each "_" is translated to a space and all words are capilalized, so the property "user_name" will have the title "User Name". The order of the fields is the one used to decleare the properties. For ex:

```objective-c
@interface UserModel : TLFormModel

@property (nonatomic, strong) TLFormImage *avatar;
@property (nonatomic, strong) TLFormText *user_name;

@end
```

Will present the avatar field at the top and the user name below.

Our previous example could be writed with ``TLFormModel`` like this:

```objective-c
@interface UserModel : TLFormModel

@property (nonatomic, strong) TLFormImage *avatar;
@property (nonatomic, strong) TLFormText *user_name;
@property (nonatomic, strong) TLFormNumber *age;

@end

@implementation UserModel @end
```

That's it. This will produce a vertical layout like the one we get on iPhone on all the platforms. Now to connect the ``TLFormModel`` to the form we need to use the ``setFormModel:`` method on the ``TLFormView`` we are using.

```objective-c
...

//At some point in some place...
FormUserModel *formUserModel = [FormUserModel new];

//This copy the values of our user model to the form model constructing the correct types using plain C functions
formUserModel.avatar = TLFormImage(userModel.avatar);
formUserModel.user_name = TLFormText(userModel.userName);
formUserModel.age = TLFormNumber(userModel.age);

TLFormView *form = ...
[form setFormModel:formUserModel];
```

To adapt the layout for other device families we need to override the implementation of ``constraintsFormatForFieldsInForm:`` provided by ``TLFormModel`` like this:

```objective-c
@implementation UserModel

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    
    //For iPhone we want the default implementation provided so just return the 'super' version
    if (isIPhone)
        return [super constraintsFormatForFieldsInForm:form];

    //For anyting else use our cusomt layout
    else {
        return @[

            //Place the avatar on the top left
            @"V:|-[avatar(==230)]",
            @"H:|-[avatar]",
        
            //Now place all the fields to the right
            @"V:|-[user_name(>=44)]",
            @"H:|-[avatar]-[user_name]-|",
        
            @"V:[user_name]-[age(==user_name)]-|",
            @"H:|-[avatar(==420)]-[age]-|"
        ];
    }
}

@end
```

Now supose that we want to edit this user info and get the result back. We need to toggle the edit state on the form and read the updated values from the ``TLFormModel`` instance we are using. This is how we could do it:

```objective-c

- (IBAction)toggleEditionAction:(id)sender {
    //Set the form on edit mode
    self.form.editing = !self.form.editing;
    //update the fileds to reflect it
    [self.form setupFields];
}

- (IBAction)saveUserAction:(id)sender {
    //Read the values ingresed by the user and save it to disc.

    NSDictionary values = @{
                            @"avatr": formUserModel.avatar,
                            @"user_name": formUserModel.name,
                            @"age": formUserModel.age
                        }
    [values writeToURL:[self saveUrl] atomically:YES];
}

```

About "editing" the images. The default ``TLFormFieldImage`` don't provide any way to pick an image at this point. You will need to handle the field selection and show some kind of image picker.

#### Event handling

``TLFormView`` report two events throught ``TLFormViewDelegate`` out of the box: ``didSelectField:`` and ``didChangeValueForField:``. The events are fired by a ``TLFormField`` implementation that notify a form about it and the form then propagate the event out. Depending on how the field is implemented it might have more events to report. For example the ``TLFormFieldList`` use a ``UITableView`` to present the list of values so it has it's own delegate that allows to customize if the rows can be rearanged, or the selection of one row.

## Requirements

iOS >= 8.0

## Installation

TLFormView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TLFormView"

Or clone the repo and check the code under `Pod/Classes`.

## Todo

There are many things that need improvement, here are some:

- [ ] TLFormDate support
- [ ] Centralized style using the methods on ``TLFormField+UIAppearance.h``
- [ ] Expose the ‘defaultMetrics’ as part of the style
- [ ] TLFormModel: look a better way to make objects mutations more efficient
- [ ] Add keyboard next/prev buttons
- [ ] Validate with predicate
- [ ] Refactor the TLFormView to TLFormViewController so we can automatically handle: choose fotos, add a string to a list, layout for orientation, etc.

If you want to contribut to the project please consider pick one of this items.

## Author

BrunoBerisso, bruno@tryolabs.com

## License

TLFormView is available under the MIT license. See the LICENSE file for more info.

[Auto Layout Visual Format]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html#//apple_ref/doc/uid/TP40010853-CH3-SW11

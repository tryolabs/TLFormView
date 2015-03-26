//
//  TLFormFieldList.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldList.h"
#import "TLFormField+Protected.h"


#define kTLFormFieldListRowHeight   44.0


@interface TLFormFieldList () <UITableViewDataSource, UITableViewDelegate>

@end


@implementation TLFormFieldList {
    UILabel *titleLabel;
    UITableView *tableView;
    UIButton *plusButton;
    NSMutableArray *items;
}

- (BOOL)delegateCanPerformSelector:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    titleLabel = (UILabel *) [self viewWithTag:TLFormFieldTitleLabelTag];
    if (editing)
        titleLabel.textColor = [UIColor grayColor];
    
    tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.scrollEnabled = NO;
    tableView.dataSource = self;
    tableView.editing = editing;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ItemCell"];
    [self addSubview:tableView];
    
    items = [self.defautValue mutableCopy];
    
    NSDictionary *views;
    
    if (editing) {
        plusButton = [[UIButton alloc] init];
        plusButton.translatesAutoresizingMaskIntoConstraints = NO;
        plusButton.titleLabel.font = [UIFont systemFontOfSize:35];
        [plusButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:plusButton];
        
        views = NSDictionaryOfVariableBindings(titleView, tableView, plusButton);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-[plusButton]-bp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[plusButton][tableView]-sp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView][tableView]-sp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        //Set the compresson and hugging priorities for the title and the button so it behave correctly with long text
        [titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [plusButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
    } else {
        views = NSDictionaryOfVariableBindings(titleView, tableView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-bp-[titleView]-bp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-np-[titleView][tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
}

- (void)setValue:(id)fieldValue {
    if (items.count != [fieldValue count])
        [self invalidateIntrinsicContentSize];
    
    items = [fieldValue mutableCopy];
    [tableView reloadData];
}

- (id)getValue {
    return items;
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    width = titleLabel.intrinsicContentSize.width + plusButton.intrinsicContentSize.width;
    height = MAX(titleLabel.intrinsicContentSize.height, plusButton.intrinsicContentSize.height) + (items.count * kTLFormFieldListRowHeight);
    
    return CGSizeMake(width, height);
}

- (void)plusAction:(id)sender {
    if ([self delegateCanPerformSelector:@selector(listFormFieldAddAction:)])
        [self.delegate listFormFieldAddAction:self];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTLFormFieldListRowHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //Invalidate the intrinsic content size so the layout is recalculated. The delay is used to let the animation end before update the layout
    [self performSelector:@selector(invalidateIntrinsicContentSize) withObject:nil afterDelay:0.3];
    
    [self.delegate listFormField:self didDeleteRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.editing;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //If this method is not implemented on the delegate return YES
    return ![self delegateCanPerformSelector:@selector(listFormField:canMoveRowAtIndexPath:)] || [self.delegate listFormField:self canMoveRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.delegate listFormField:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

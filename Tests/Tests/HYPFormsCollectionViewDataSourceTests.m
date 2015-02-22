@import UIKit;
@import XCTest;

#import "FORMFieldValidation.h"
#import "FORMGroup.h"
#import "FORMField.h"
#import "FORMCollectionViewDataSource.h"
#import "FORMSection.h"
#import "FORMData.h"
#import "FORMTarget.h"
#import "HYPImageFormFieldCell.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsCollectionViewDataSourceTests : XCTestCase

@end

@implementation HYPFormsCollectionViewDataSourceTests

- (void)testIndexInForms
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    [dataSource processTarget:[FORMTarget hideFieldTargetWithID:@"display_name"]];
    [dataSource processTarget:[FORMTarget showFieldTargetWithID:@"display_name"]];
    FORMField *field = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    NSUInteger index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 2);

    [dataSource processTarget:[FORMTarget hideFieldTargetWithID:@"username"]];
    [dataSource processTarget:[FORMTarget showFieldTargetWithID:@"username"]];
    field = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 2);

    [dataSource processTargets:[FORMTarget hideFieldTargetsWithIDs:@[@"first_name",
                                                                     @"address",
                                                                     @"username"]]];
    [dataSource processTarget:[FORMTarget showFieldTargetWithID:@"username"]];
    field = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 1);
    [dataSource processTargets:[FORMTarget showFieldTargetsWithIDs:@[@"first_name",
                                                                     @"address"]]];

    [dataSource processTargets:[FORMTarget hideFieldTargetsWithIDs:@[@"last_name",
                                                                     @"address"]]];
    [dataSource processTarget:[FORMTarget showFieldTargetWithID:@"address"]];
    field = [dataSource.formsManager fieldWithID:@"address" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:dataSource.formsManager.forms];
    XCTAssertEqual(index, 0);
    [dataSource processTarget:[FORMTarget showFieldTargetWithID:@"last_name"]];
}

- (void)testEnableAndDisableTargets
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];
    [dataSource enable];

    FORMField *targetField = [dataSource.formsManager fieldWithID:@"base_salary" includingHiddenFields:YES];
    XCTAssertFalse(targetField.isDisabled);

    FORMTarget *disableTarget = [FORMTarget disableFieldTargetWithID:@"base_salary"];
    [dataSource processTarget:disableTarget];
    XCTAssertTrue(targetField.isDisabled);

    FORMTarget *enableTarget = [FORMTarget enableFieldTargetWithID:@"base_salary"];
    [dataSource processTargets:@[enableTarget]];
    XCTAssertFalse(targetField.isDisabled);

    [dataSource disable];
    XCTAssertTrue(targetField.isDisabled);

    [dataSource enable];
    XCTAssertFalse(targetField.isDisabled);
}

- (void)testInitiallyDisabled
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    FORMField *totalField = [dataSource.formsManager fieldWithID:@"total" includingHiddenFields:YES];
    XCTAssertTrue(totalField.disabled);
}

- (void)testUpdatingTargetValue
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    FORMField *targetField = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertNil(targetField.fieldValue);

    FORMTarget *updateTarget = [FORMTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"John Hyperseed";

    [dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(targetField.fieldValue, @"John Hyperseed");
}

- (void)testDefaultValue
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    FORMField *usernameField = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    XCTAssertNotNil(usernameField.fieldValue);
}

- (void)testCondition
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    FORMField *displayNameField = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    FORMField *usernameField = [dataSource.formsManager fieldWithID:@"username" includingHiddenFields:YES];
    FORMFieldValue *fieldValue = usernameField.fieldValue;
    XCTAssertEqualObjects(fieldValue.valueID, @0);

    FORMTarget *updateTarget = [FORMTarget updateFieldTargetWithID:@"display_name"];
    updateTarget.targetValue = @"Mr.Melk";

    updateTarget.condition = @"$username == 2";
    [dataSource processTarget:updateTarget];
    XCTAssertNil(displayNameField.fieldValue);

    updateTarget.condition = @"$username == 0";
    [dataSource processTarget:updateTarget];
    XCTAssertEqualObjects(displayNameField.fieldValue, @"Mr.Melk");
}

- (void)testReloadWithDictionary
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    [dataSource reloadWithDictionary:@{@"first_name" : @"Elvis",
                                       @"last_name" : @"Nunez"}];

    FORMField *field = [dataSource.formsManager fieldWithID:@"display_name" includingHiddenFields:YES];
    XCTAssertEqualObjects(field.fieldValue, @"Elvis Nunez");
}

- (void)testClearTarget
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];

    FORMField *firstNameField = [dataSource.formsManager fieldWithID:@"first_name" includingHiddenFields:YES];
    XCTAssertNotNil(firstNameField);

    firstNameField.fieldValue = @"John";
    XCTAssertNotNil(firstNameField.fieldValue);

    FORMTarget *clearTarget = [FORMTarget clearFieldTargetWithID:@"first_name"];
    [dataSource processTarget:clearTarget];
    XCTAssertNil(firstNameField.fieldValue);
}

- (void)testFormFieldsAreValid
{
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"field-validations.json"
                                                             inBundle:[NSBundle bundleForClass:[self class]]];

    FORMCollectionViewDataSource *dataSource = [[FORMCollectionViewDataSource alloc] initWithJSON:JSON
                                                                                   collectionView:nil
                                                                                           layout:nil
                                                                                           values:nil
                                                                                         disabled:YES];
    XCTAssertFalse([dataSource formFieldsAreValid]);

    [dataSource reloadWithDictionary:@{@"first_name" : @"Supermancito"}];

    XCTAssertTrue([dataSource formFieldsAreValid]);
}

@end

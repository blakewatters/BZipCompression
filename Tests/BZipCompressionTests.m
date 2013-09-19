//
//  BZipCompressionTests.h
//  BZipCompression
//
//  Created by Blake Watters on 9/19/13.
//  Copyright (c) 2013 Blake Watters. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <SenTestingKit/SenTestingKit.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "BZipCompression.h"

@interface BZipCompressionTests : SenTestCase

@property (nonatomic, readonly) NSBundle *testsBundle;

@end

@implementation BZipCompressionTests

- (void)setUp
{
    _testsBundle = [NSBundle bundleForClass:[self class]];
}

- (void)testDecompression
{
    NSURL *fixtureURL = [self.testsBundle URLForResource:@"Fixture" withExtension:@".txt.bz2"];
    NSData *compressedData = [NSData dataWithContentsOfURL:fixtureURL];
    NSError *error = nil;
    NSData *decompressedData = [BZipCompression decompressedDataWithData:compressedData error:&error];
    expect(decompressedData).notTo.beNil();
    NSString *decompressedFileContents = [[NSString alloc] initWithData:decompressedData encoding:NSUTF8StringEncoding];
    expect(decompressedFileContents).to.equal(@"Hello World!\n");
}

- (void)testDecompressionFailureWithNonCompressedFile
{
    NSURL *fixtureURL = [self.testsBundle URLForResource:@"Fixture" withExtension:@".txt"];
    NSData *compressedData = [NSData dataWithContentsOfURL:fixtureURL];
    NSError *error = nil;
    NSData *decompressedData = [BZipCompression decompressedDataWithData:compressedData error:&error];
    expect(decompressedData).to.beNil();
    expect(error).notTo.beNil();
    expect(error.code).to.equal(BZipErrorIncorrectMagicData);
}

- (void)testDecompressionFailsWithErrorIfGivenNilInputData
{
    NSError *error = nil;
    NSData *decompressedData = [BZipCompression decompressedDataWithData:nil error:&error];
    expect(decompressedData).to.beNil();
    expect(error).notTo.beNil();
    expect(error.code).to.equal(BZipErrorNilInputDataError);
}

- (void)testCompression
{
    NSData *stringData = [@"God is a mute and there is no 'why?'." dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSData *compressedData = [BZipCompression compressedDataWithData:stringData blockSize:BZipDefaultBlockSize workFactor:0 error:&error];
    expect(compressedData).notTo.beNil();
    expect(error).to.beNil();

    NSData *decompressedData = [BZipCompression decompressedDataWithData:compressedData error:&error];
    expect(decompressedData).notTo.beNil();
    NSString *decompressedFileContents = [[NSString alloc] initWithData:decompressedData encoding:NSUTF8StringEncoding];
    expect(decompressedFileContents).to.equal(@"God is a mute and there is no 'why?'.");
}

- (void)testCompressionFailsWithErrorIfGivenNilInputData
{
    NSError *error = nil;
    NSData *decompressedData = [BZipCompression compressedDataWithData:nil blockSize:BZipDefaultBlockSize workFactor:0 error:&error];
    expect(decompressedData).to.beNil();
    expect(error).notTo.beNil();
    expect(error.code).to.equal(BZipErrorNilInputDataError);
}

@end

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

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "BZipCompression.h"

@interface BZipCompressionTests : XCTestCase

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

- (void)testDecompressionToPath
{
    NSString *inputPath = [self.testsBundle pathForResource:@"Fixture" ofType:@"txt.bz2"];
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"fixture.txt"]];
    NSError *error = nil;
    BOOL success = [BZipCompression decompressDataFromFileAtPath:inputPath toFileAtPath:outputPath error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    NSString *decompressedFileContents = [NSString stringWithContentsOfFile:outputPath encoding:NSUTF8StringEncoding error:&error];
    expect(decompressedFileContents).to.equal(@"Hello World!\n");
}

- (void)testDecompressionOfLargeFileToPath
{
    NSString *inputPath = [self.testsBundle pathForResource:@"anna_karenina" ofType:@"txt.bz2"];
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"anna_karenina.txt"]];
    NSError *error = nil;
    BOOL success = [BZipCompression decompressDataFromFileAtPath:inputPath toFileAtPath:outputPath error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    NSString *referenceFile = [self.testsBundle pathForResource:@"anna_karenina" ofType:@"txt"];
    BOOL contentsAreEqual = [[NSFileManager defaultManager] contentsEqualAtPath:outputPath andPath:referenceFile];
    expect(contentsAreEqual).to.beTruthy();
}

- (void)testAsyncDecompressonToPath
{
    NSString *inputPath = [self.testsBundle pathForResource:@"anna_karenina" ofType:@"txt.bz2"];
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"anna_karenina.txt"]];
    __block BOOL done = NO;
    [BZipCompression asynchronouslyDecompressFileAtPath:inputPath toFileAtPath:outputPath progress:nil completion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        done = YES;
    }];
    expect(done).will.beTruthy();
    
    NSString *referenceFile = [self.testsBundle pathForResource:@"anna_karenina" ofType:@"txt"];
    BOOL contentsAreEqual = [[NSFileManager defaultManager] contentsEqualAtPath:outputPath andPath:referenceFile];
    expect(contentsAreEqual).to.beTruthy();
}

- (void)testMonitoringProgressOfDecompressionOperation
{
    NSString *inputPath = [self.testsBundle pathForResource:@"anna_karenina" ofType:@"txt.bz2"];
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"anna_karenina.txt"]];
    __block BOOL done = NO;
    NSProgress *progress = nil;
    [BZipCompression asynchronouslyDecompressFileAtPath:inputPath toFileAtPath:outputPath progress:&progress completion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        done = YES;
    }];
    expect(progress).notTo.beNil();
    expect(progress.totalUnitCount).to.equal(530241);
    [progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionInitial
                  context:nil];
    expect(done).will.beTruthy();
    expect(progress.fractionCompleted).to.equal(1.0);
    expect(progress.completedUnitCount).to.equal(530241);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    NSProgress __unused *progress = object;
//    NSLog(@"Total unit completed %lld (fraction completed=%f)", progress.completedUnitCount, progress.fractionCompleted);
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

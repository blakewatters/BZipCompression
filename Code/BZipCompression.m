//
//  BZipCompression.m
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

#import <bzlib.h>
#import "BZipCompression.h"

NSString * const BZipErrorDomain = @"com.blakewatters.BZipCompression";
static NSUInteger const BZipCompressionBufferSize = 1024;
NSInteger const BZipDefaultBlockSize = 7;
NSInteger const BZipDefaultWorkFactor = 0;

@implementation BZipCompression

+ (NSData *)compressedDataWithData:(NSData *)data blockSize:(NSInteger)blockSize workFactor:(NSInteger)workFactor error:(NSError **)error
{
    if (! data) {
        if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:BZipErrorNilInputDataError userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Input data cannot be `nil`.", nil) }];
        return nil;
    }
    if ([data length] == 0) return data;

    bz_stream stream;
    bzero(&stream, sizeof(stream));
    stream.next_in = (char *)[data bytes];
    stream.avail_in = [data length];

    NSMutableData *buffer = [NSMutableData dataWithLength:BZipCompressionBufferSize];
    stream.next_out = [buffer mutableBytes];
    stream.avail_out = BZipCompressionBufferSize;

    int bzret;
    bzret = BZ2_bzCompressInit(&stream, blockSize, 0, workFactor);
    if (bzret != BZ_OK) {
        if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:bzret userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`BZ2_bzCompressInit` failed", nil) }];
        return nil;
    }

    NSMutableData *compressedData = [NSMutableData data];
    do {
        bzret = BZ2_bzCompress(&stream, (stream.avail_in) ? BZ_RUN : BZ_FINISH);
        if (bzret < BZ_OK) {
            if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:bzret userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`BZ2_bzCompress` failed", nil) }];
            return nil;
        }

        [compressedData appendBytes:[buffer bytes] length:(BZipCompressionBufferSize - stream.avail_out)];
        stream.next_out = [buffer mutableBytes];
        stream.avail_out = BZipCompressionBufferSize;
    } while(bzret != BZ_STREAM_END);

    BZ2_bzCompressEnd(&stream);

    return compressedData;
}

+ (NSData *)decompressedDataWithData:(NSData *)data error:(NSError **)error
{
    if (! data) {
        if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:BZipErrorNilInputDataError userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Input data cannot be `nil`.", nil) }];
        return nil;
    }
    if ([data length] == 0) return data;

    bz_stream stream;
    bzero(&stream, sizeof(stream));
    stream.next_in = (char *)[data bytes];
    stream.avail_in = [data length];

    NSMutableData *buffer = [NSMutableData dataWithLength:BZipCompressionBufferSize];
    stream.next_out = [buffer mutableBytes];
    stream.avail_out = BZipCompressionBufferSize;

    int bzret;
    bzret = BZ2_bzDecompressInit(&stream, 0, NO);
    if (bzret != BZ_OK) {
        if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:bzret userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`BZ2_bzDecompressInit` failed", nil) }];
        return nil;
    }

    NSMutableData *decompressedData = [NSMutableData data];
    do {
        bzret = BZ2_bzDecompress(&stream);
        if (bzret < BZ_OK) {
            if (error) *error = [NSError errorWithDomain:BZipErrorDomain code:bzret userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`BZ2_bzDecompress` failed", nil) }];
            return nil;
        }

        [decompressedData appendBytes:[buffer bytes] length:(BZipCompressionBufferSize - stream.avail_out)];
        stream.next_out = [buffer mutableBytes];
        stream.avail_out = BZipCompressionBufferSize;
    } while(bzret != BZ_STREAM_END);

    BZ2_bzDecompressEnd(&stream);
    
    return decompressedData;
}

@end

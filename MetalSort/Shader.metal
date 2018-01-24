//
//  Shader.metal
//  MetalSort
//
//  Created by Tim Gymnich on 13.09.17.
//  Copyright © 2017 Tim Gymnich. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef int DataType;


kernel void parallelBitonic(device DataType *input [[buffer(0)]],
                            constant int &p [[buffer(1)]],
                            constant int &q [[buffer(2)]],
                            uint gid [[thread_position_in_grid]])
{
    int distance = 1 << (p-q);
    bool direction = ((gid >> p) & 2) == 0;
    
    if ((gid & distance) == 0 && (input[gid] > input[gid | distance]) == direction) {
        DataType temp = input[gid];
        input[gid] = input[gid | distance];
        input[gid | distance] = temp;
    }
}




//
//  main.swift
//  MetalSort
//
//  Created by Tim Gymnich on 13.09.17.
//  Copyright © 2017 Tim Gymnich. All rights reserved.
//

import Metal

typealias DataType = CInt

let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = device.makeDefaultLibrary()!
let sortFunction = library.makeFunction(name: "parallelBitonic")!
let pipeline = try! device.makeComputePipelineState(function: sortFunction)

var data: [DataType] = [435,15,14,20,345,11,100,9,8,7,6,5,9,3,2,0]
let dataBuffer = device.makeBuffer(bytes: &data, length: MemoryLayout<DataType>.stride * data.count, options: [.storageModeShared])!

let threadgroupsPerGrid = MTLSize(width: data.count, height: 1, depth: 1)
let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)

guard let logn = Int(exactly: log2(Double(data.count))) else {
    fatalError("data.count is not a power of 2")
}

for p in 0..<logn {
    for q in 0..<p+1 {
        
        var n1 = p
        var n2 = q
        
        let commands = commandQueue.makeCommandBuffer()!
        let encoder = commands.makeComputeCommandEncoder()!
            
        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(dataBuffer, offset: 0, index: 0)
        encoder.setBytes(&n1, length: MemoryLayout<DataType>.stride, index: 1)
        encoder.setBytes(&n2, length: MemoryLayout<DataType>.stride, index: 2)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
            
        commands.commit()
        commands.waitUntilCompleted()
    }
}

let dataPointer = dataBuffer.contents().assumingMemoryBound(to: DataType.self)
let dataBufferPointer = UnsafeMutableBufferPointer(start: dataPointer, count: data.count)
let resultsArray = Array.init(dataBufferPointer)

print(resultsArray)

//
//  File.swift
//  libgit2.swift
//
//  Created by Ky on 2025-01-16.
//

import Foundation



extension String: @retroactive RandomAccessCollection {
    public typealias SubSequence = Substring
    
    
}



extension String.SubSequence: @retroactive RandomAccessCollection {
    
}

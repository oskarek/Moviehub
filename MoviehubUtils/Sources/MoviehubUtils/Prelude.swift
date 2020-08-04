//
//  Prelude.swift
//  
//
//  Created by Oskar Ek on 2020-07-19.
//

import Foundation

/// Configure a value with a given closure
public func configure<A>(_ a: A, _ f: (inout A) -> Void) -> A {
  var a = a
  f(&a)
  return a
}

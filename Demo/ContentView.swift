//
//  ContentView.swift
//  Demo
//
//  Created by Fumiya Yamanaka on 2020/02/07.
//

import SwiftUI
import SIWA

struct ContentView: View {
  var body: some View {
    SIWA() { result in
      switch result {
        case let .success(c):
          print("success:", c)
        case let .failure(error):
          print("error:", error)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

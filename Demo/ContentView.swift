//
//  ContentView.swift
//  Demo
//
//  Created by Fumiya Yamanaka on 2020/02/07.
//

import SwiftUI
import Siwa

struct ContentView: View {

  var body: some View {
    VStack {
      Button("do what something with Apple", action: {
        SiwaCoordinator(credentialResult: { result in
          switch result {
          case let .success(c):
            print("success:", c)
          case let .failure(error):
            print("error:", error)
          }
        }).requestAuthorization()
      })
      .frame(width: 200, height: 50, alignment: .center)
      SiwaButton() { result in
        switch result {
        case let .success(c):
          print("success:", c)
        case let .failure(error):
          print("error:", error)
        }
      }
      .frame(width: 200, height: 50, alignment: .center)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

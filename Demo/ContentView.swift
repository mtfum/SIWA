//
//  ContentView.swift
//  Demo
//
//  Created by Fumiya Yamanaka on 2020/02/07.
//

import SwiftUI
import Siwa

struct ContentView: View {

  @State var siwaCoordinator: SiwaCoordinator?

  var body: some View {
    VStack {
      Button("do what something with Apple", action: {
        self.siwaCoordinator = SiwaCoordinator(credentialResult: { result in
          switch result {
          case let .success(c):
            print("success:", c)
          case let .failure(error):
            print("error:", error)
          }
        })
        self.siwaCoordinator?.requestAuthorization()
      })
        .frame(width: 240, height: 50, alignment: .center)
//        .cornerRadius(8)
        .border(Color.blue, width: 1)


      SiwaButton() { result in
        switch result {
        case let .success(c):
          print("success:", c)
        case let .failure(error):
          print("error:", error)
        }
      }
      .frame(width: 240, height: 50, alignment: .center)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

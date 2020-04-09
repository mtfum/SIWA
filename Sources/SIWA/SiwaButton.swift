#if os(iOS)
import UIKit
import SwiftUI
import Combine

import AuthenticationServices

extension String: Error {}

@available(iOS 13, *)
public struct SiwaButton: View {

  private let result: (Result<SiwaCredential, Error>) -> Void

  private let button: SignInWithAppleButton

  private var coordinator: SiwaCoordinator {
    SiwaCoordinator(credentialResult: result)
  }

  public init(
    type: ASAuthorizationAppleIDButton.ButtonType = .default,
    result: @escaping (Result<SiwaCredential, Error>) -> Void
  ) {
    self.result = result
    self.button = SignInWithAppleButton(type: type)
  }

  public var body: some View {
    button.onTapGesture(perform: coordinator.requestAuthorization)
  }

  private struct SignInWithAppleButton: UIViewRepresentable {

    private var type: ASAuthorizationAppleIDButton.ButtonType

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    init(type: ASAuthorizationAppleIDButton.ButtonType = .default) {
      self.type = type
    }

    public func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
      return ASAuthorizationAppleIDButton(
        authorizationButtonType: type,
        authorizationButtonStyle: colorScheme == .dark ? .white : .black
      )
    }

    public func updateUIView(_ uiView: ASAuthorizationAppleIDButton,
                      context: UIViewRepresentableContext<SignInWithAppleButton>) {
    }
  }
}

@available(iOS 13, *)
struct Siwa_Previews: PreviewProvider {
  static var previews: some View {
    SiwaButton(result: { _ in })
      .frame(width: 200, height: 40, alignment: .center)
  }
}

#endif

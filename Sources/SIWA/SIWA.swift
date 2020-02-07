#if !os(macOS)
import UIKit
import SwiftUI
import Combine
import CryptoKit
import AuthenticationServices

extension String: Error {}

public struct SIWA: View {

  public struct Credential {
    let idToken: String
    let rawNonce: String
  }

  private let result: (Result<Credential, Error>) -> Void

  private let button: UIControl

  public init(button: UIControl = ASAuthorizationAppleIDButton(), result: @escaping (Result<Credential, Error>) -> Void) {
    self.button = button
    self.result = result
  }

  public var body: some View {
    let controller = Controller(credentialResult: result, button: button)
    return controller
      .frame(width: controller.button.frame.width, height: controller.button.frame.height, alignment: .center)
  }

  private struct Controller: UIViewControllerRepresentable {

    let credentialResult: (Result<Credential, Error>) -> Void

    let button: UIControl

    let vc: UIViewController = UIViewController()

    func makeCoordinator() -> Coordinator {
      return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
      vc.view.addSubview(button)
      return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

    final class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

      var parent: Controller

      var currentNonce: String?

      init(_ parent: Controller) {
        self.parent = parent
        super.init()
        parent.button.addTarget(self, action: #selector(didTapAppleIDButton), for: .touchUpInside)
      }

      @objc
      func didTapAppleIDButton() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
      }

      func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        parent.vc.view.window!
      }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
          parent.credentialResult(.failure("Credentials are not of type ASAuthorizationAppleIDCredential"))
          return
        }

        guard let nonce = currentNonce else {
          parent.credentialResult(.failure("Invalid state: A login callback was received, but no login request was sent."))
          return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          parent.credentialResult(.failure("Unable to fetch identity token"))
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          parent.credentialResult(.failure("Unable to serialize token string from data: \(appleIDToken.debugDescription)"))
          return
        }
        parent.credentialResult(.success(.init(idToken: idTokenString, rawNonce: nonce)))
      }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        parent.credentialResult(.failure(error))
      }

      // https://qiita.com/_mogaming/items/4b76b6d4f12a66963fb4#ui
      private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
          let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
              fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
          }

          randoms.forEach { random in
            if length == 0 {
              return
            }

            if random < charset.count {
              result.append(charset[Int(random)])
              remainingLength -= 1
            }
          }
        }

        return result
      }

      private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
      }
    }
  }
}
#endif

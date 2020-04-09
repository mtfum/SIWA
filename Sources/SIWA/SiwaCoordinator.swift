//
//  SiwaAuthorize.swift
//  Siwa
//
//  Created by Fumiya Yamanaka on 2020/04/08.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

@available(iOS 13, *)
public final class SiwaCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

  private var currentNonce: String?

  private let credentialResult: (Result<SiwaCredential, Error>) -> Void

  public init(credentialResult: @escaping (Result<SiwaCredential, Error>) -> Void) {
    self.credentialResult = credentialResult
    super.init()
  }

  public func requestAuthorization() {
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

  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    UIApplication.shared.windows.last?.rootViewController?.view.window ?? ASPresentationAnchor()
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
      credentialResult(.failure("Credentials are not of type ASAuthorizationAppleIDCredential"))
      return
    }

    guard let nonce = currentNonce else {
      credentialResult(.failure("Invalid state: A login callback was received, but no login request was sent."))
      return
    }
    guard let appleIDToken = appleIDCredential.identityToken else {
      credentialResult(.failure("Unable to fetch identity token"))
      return
    }
    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
      credentialResult(.failure("Unable to serialize token string from data: \(appleIDToken.debugDescription)"))
      return
    }
    credentialResult(.success(.init(idToken: idTokenString, rawNonce: nonce)))
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    credentialResult(.failure(error))
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


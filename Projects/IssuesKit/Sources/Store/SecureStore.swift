import Foundation
import KeychainSwift
import RxSwift

enum SecureStoreKey: String, Hashable {
    case githubAccessToken
}

protocol SecureStoring {
    func set(_ value: String, key: SecureStoreKey)
    func delete(key: SecureStoreKey)
    func get(key: SecureStoreKey) -> String?
    func observe(key: SecureStoreKey) -> Observable<String?>
}

class SecureStore: SecureStoring {
    
    private let keychain: KeychainSwift = KeychainSwift()
    private let subject: PublishSubject<(key: SecureStoreKey, value: String?)> = PublishSubject()
    
    func set(_ value: String, key: SecureStoreKey) {
        keychain.set(value, forKey: key.rawValue)
        subject.onNext((key: key, value: value))
    }
    
    func delete(key: SecureStoreKey) {
        keychain.delete(key.rawValue)
        subject.onNext((key: key, value: nil))
    }
    
    func get(key: SecureStoreKey) -> String? {
        return keychain.get(key.rawValue)
    }
    
    func observe(key: SecureStoreKey) -> Observable<String?> {
        return self.subject.filter({ $0.key == key }).map({ $0.value })
    }
    
}

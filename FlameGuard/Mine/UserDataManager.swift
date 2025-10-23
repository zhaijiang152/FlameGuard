//
//  UserDefault.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/20.
//
import UIKit

struct UserProfile: Codable {
    var name: String
    var gender: String
    var bio: String
    var avatarData: Data?
}

class UserDataManager {
    static let shared = UserDataManager()
    private let defaults = UserDefaults.standard
    private let userProfileKey = "userProfile"

    func saveUserProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: userProfileKey)
        }
    }

    func loadUserProfile() -> UserProfile {
        if let data = defaults.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        } else {
            return UserProfile(
                name: "用户",
                gender: "男",
                bio: "",
                avatarData: nil
            )
        }
    }

    func clearUserProfile() {
        defaults.removeObject(forKey: userProfileKey)
    }
}

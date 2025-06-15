//
//  WorkoutError.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//


import Foundation

public enum WorkoutError: Error, LocalizedError {
    case sessionAlreadyActive
    case noActiveSession
    case cannotResumeSession
    case saveFailed
    
    public var errorDescription: String? {
        switch self {
        case .sessionAlreadyActive:
            return "A workout session is already active"
        case .noActiveSession:
            return "No active workout session"
        case .cannotResumeSession:
            return "Cannot resume workout session"
        case .saveFailed:
            return "Failed to save workout session"
        }
    }
}

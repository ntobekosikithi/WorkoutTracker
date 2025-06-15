//
//  WorkoutType.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation

public enum WorkoutType: String, CaseIterable, Codable, Sendable {
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case strength = "Strength Training"
    case yoga = "Yoga"
    case walking = "Walking"
    
    public var systemImage: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .strength: return "dumbbell"
        case .yoga: return "figure.mind.and.body"
        case .walking: return "figure.walk"
        }
    }
}

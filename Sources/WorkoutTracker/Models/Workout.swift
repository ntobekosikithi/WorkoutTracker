//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import Foundation

public struct Workout: Codable, Identifiable, Equatable {
    public let id: UUID
    public let type: WorkoutType
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    public init(type: WorkoutType, startTime: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.startTime = startTime
        self.endTime = nil
    }
    
    internal mutating func end() {
        self.endTime = Date()
    }
}

public enum WorkoutType: String, CaseIterable, Codable {
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case weightLifting = "Weight Lifting"
    case yoga = "Yoga"
    case walking = "Walking"
    
    public var emoji: String {
        switch self {
        case .running: return "🏃‍♂️"
        case .cycling: return "🚴‍♂️"
        case .swimming: return "🏊‍♂️"
        case .weightLifting: return "🏋️‍♂️"
        case .yoga: return "🧘‍♂️"
        case .walking: return "🚶‍♂️"
        }
    }
}

public enum WorkoutState {
    case notStarted
    case active
    case paused
    case completed
}

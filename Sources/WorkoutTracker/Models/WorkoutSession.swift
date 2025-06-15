//
//  WorkoutSession.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation

public struct WorkoutSession: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let type: WorkoutType
    public let startTime: Date
    public var endTime: Date?
    public var status: WorkoutStatus
    public var duration: TimeInterval
    public var pausedAt: Date?
    public var resumedAt: Date?
    public var calories: Int?
    public var distance: Double?
    
    public var durationInMinutes: Double {
        return duration / 60
    }
    
    public var estimatedCalories: Int {
        if let calories = calories {
            return calories
        }
        // Simple estimation based on workout type and duration
        return estimateCalories(for: type, duration: duration)
    }
    
    public init(
        id: UUID,
        type: WorkoutType,
        startTime: Date,
        endTime: Date? = nil,
        status: WorkoutStatus = .inProgress,
        duration: TimeInterval = 0,
        pausedAt: Date? = nil,
        resumedAt: Date? = nil,
        calories: Int? = nil,
        distance: Double? = nil
    ) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.duration = duration
        self.pausedAt = pausedAt
        self.resumedAt = resumedAt
        self.calories = calories
        self.distance = distance
    }
    
    private func estimateCalories(for workoutType: WorkoutType, duration: TimeInterval) -> Int {
        let minutesElapsed = duration / 60
        let caloriesPerMinute: Double
        
        switch workoutType {
        case .running:
            caloriesPerMinute = 12.0
        case .cycling:
            caloriesPerMinute = 8.0
        case .swimming:
            caloriesPerMinute = 14.0
        case .strength:
            caloriesPerMinute = 6.0
        case .yoga:
            caloriesPerMinute = 3.0
        case .walking:
            caloriesPerMinute = 4.0
        }
        
        return Int(minutesElapsed * caloriesPerMinute)
    }
}

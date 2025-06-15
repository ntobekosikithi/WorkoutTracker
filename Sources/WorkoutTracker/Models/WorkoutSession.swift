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
}

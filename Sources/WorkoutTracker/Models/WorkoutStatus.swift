//
//  WorkoutStatus.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation

public enum WorkoutStatus: String, Codable, Sendable {
    case inProgress = "In Progress"
    case paused = "Paused"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

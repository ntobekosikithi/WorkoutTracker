// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine
import Utilities

@available(iOS 14.0, *)
@MainActor
public final class WorkoutTracker: ObservableObject {
    @Published public private(set) var currentSession: WorkoutSession?
    @Published public private(set) var isTracking: Bool = false
    @Published public private(set) var elapsedTime: TimeInterval = 0
    
    private let workoutService: WorkoutService
    private let logger: Logger
    private var timer: Timer?
    
    public init(
        workoutService: WorkoutService? = nil,
        logger: Logger = Logger.shared
    ) {
        self.workoutService = WorkoutServiceImplementation()
        self.logger = logger
    }
    
    public func startWorkout(type: WorkoutType) async throws {
        guard currentSession == nil else {
            throw WorkoutError.sessionAlreadyActive
        }
        
        logger.info("Starting workout: \(type.rawValue)")
        
        let session = WorkoutSession(
            id: UUID(),
            type: type,
            startTime: Date(),
            status: .inProgress
        )
        
        currentSession = session
        isTracking = true
        elapsedTime = 0
        
        startTimer()
        
        try await workoutService.saveSession(session)
    }
    
    public func pauseWorkout() async throws {
        guard var session = currentSession,
              session.status == .inProgress else {
            throw WorkoutError.noActiveSession
        }
        
        logger.info("Pausing workout")
        
        session.status = .paused
        session.pausedAt = Date()
        currentSession = session
        isTracking = false
        
        stopTimer()
        
        try await workoutService.updateSession(session)
    }
    
    public func resumeWorkout() async throws {
        guard var session = currentSession,
              session.status == .paused else {
            throw WorkoutError.cannotResumeSession
        }
        
        logger.info("Resuming workout")
        
        session.status = .inProgress
        session.resumedAt = Date()
        currentSession = session
        isTracking = true
        
        startTimer()
        
        try await workoutService.updateSession(session)
    }
    
    public func stopWorkout() async throws {
        guard var session = currentSession else {
            throw WorkoutError.noActiveSession
        }
        
        logger.info("Stopping workout")
        
        session.status = .completed
        session.endTime = Date()
        session.duration = elapsedTime
        
        stopTimer()
        
        try await workoutService.updateSession(session)
        
        currentSession = nil
        isTracking = false
        elapsedTime = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Public Interface
@available(iOS 14.0, *)
public extension WorkoutTracker {
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

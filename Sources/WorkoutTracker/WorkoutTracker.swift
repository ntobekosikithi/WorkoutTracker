// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine
import Utilities
import GoalManager

@available(iOS 14.0, *)
@MainActor
public final class WorkoutTracker: ObservableObject {
    @Published public private(set) var currentSession: WorkoutSession?
    @Published public private(set) var isTracking: Bool = false
    @Published public private(set) var elapsedTime: TimeInterval = 0
    
    private let workoutService: WorkoutService
    private let goalManager: GoalManager
    private let logger: Logger
    private var timer: Timer?
    
    public init(
        workoutService: WorkoutService? = nil,
        goalManager: GoalManager = GoalManager(),
        logger: Logger = Logger.shared
    ) {
        self.workoutService = WorkoutServiceImplementation()
        self.goalManager = goalManager
        self.logger = logger
    }
    
    public func startWorkout(type: WorkoutType) async throws {
        guard currentSession == nil else {
            throw WorkoutError.sessionAlreadyActive
        }
        
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

        session.status = .completed
        session.endTime = Date()
        session.duration = elapsedTime
        do {
            
            try await UpdateSessionWithCurrentProgress(workoutSession: session)
        } catch  {
            logger.error("Failed to update workout sessions: \(error)")
        }
        currentSession = nil
        isTracking = false
        elapsedTime = 0
    }
    
    private func UpdateSessionWithCurrentProgress(workoutSession: WorkoutSession) async throws {
        var session = workoutSession
        if session.calories == nil {  session.calories = session.estimatedCalories }

        if session.distance == nil { session.distance = session.estimatedDistance }

        if session.steps == nil { session.steps = session.estimatedSteps }
        
        stopTimer()
        
        try await workoutService.updateSession(session)

        do {
            await goalManager.loadGoals()
            try await goalManager.processWorkoutCompletion(session)
            logger.info("Successfully updated goal progress for completed workout")
        } catch {
            logger.error("Failed to update goal progress: \(error)")
        }
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

        return hours > 0
            ? String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
    }
}

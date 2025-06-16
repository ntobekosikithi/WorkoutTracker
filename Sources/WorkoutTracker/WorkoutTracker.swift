// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine
import Utilities
import GoalManager

@available(iOS 14.0, *)
@MainActor
public final class WorkoutTracker: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var currentSession: WorkoutSession?
    @Published public private(set) var isTracking: Bool = false
    @Published public private(set) var elapsedTime: TimeInterval = 0

    // MARK: - Dependencies

    private let workoutService: WorkoutService
    private let goalManager: GoalManager
    private let logger: Logger

    // MARK: - Internal State

    private var timer: Timer?

    // MARK: - Init

    public init(
        workoutService: WorkoutService? = nil,
        goalManager: GoalManager = GoalManager(),
        logger: Logger = LoggerImplementation()
    ) {
        self.workoutService = workoutService ?? WorkoutServiceImplementation()
        self.goalManager = goalManager
        self.logger = logger
    }

    // MARK: - Workout Lifecycle

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
        guard var session = currentSession, session.status == .inProgress else {
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
        guard var session = currentSession, session.status == .paused else {
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

        stopTimer()

        do {
            try await updateSessionWithFinalMetrics(session)
        } catch {
            logger.error("Failed to update workout session: \(error)")
        }

        currentSession = nil
        isTracking = false
        elapsedTime = 0
    }

    // MARK: - Private Helpers

    private func updateSessionWithFinalMetrics(_ session: WorkoutSession) async throws {
        var updatedSession = session

        if updatedSession.calories == nil {
            updatedSession.calories = updatedSession.estimatedCalories
        }

        if updatedSession.distance == nil {
            updatedSession.distance = updatedSession.estimatedDistance
        }

        if updatedSession.steps == nil {
            updatedSession.steps = updatedSession.estimatedSteps
        }

        try await workoutService.updateSession(updatedSession)

        do {
            await goalManager.loadGoals()
            try await goalManager.processWorkoutCompletion(updatedSession)
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

// MARK: - Public Computed Properties

@available(iOS 14.0, *)
public extension WorkoutTracker {
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60

        return hours > 0
            ? String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
    }
}


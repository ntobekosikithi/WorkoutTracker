// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine
import Utilities

@available(iOS 14.0, *)
@MainActor
public final class WorkoutTracker: ObservableObject {
    @Published public private(set) var currentWorkout: Workout?
    @Published public private(set) var workoutHistory: [Workout] = []
    @Published public private(set) var state: WorkoutState = .notStarted
    @Published public private(set) var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var pausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    private let storage: DataStorage
    
    public init(storage: DataStorage = DataStorageImplementation()) {
        self.storage = storage
        loadWorkoutHistory()
    }
    
    // MARK: - Public Interface
    
    public func startWorkout(type: WorkoutType) {
        guard state == .notStarted else { return }
        
        currentWorkout = Workout(type: type)
        state = .active
        elapsedTime = 0
        pausedDuration = 0
        startTimer()
    }
    
    public func pauseWorkout() {
        guard state == .active else { return }
        
        state = .paused
        pauseStartTime = Date()
        stopTimer()
    }
    
    public func resumeWorkout() {
        guard state == .paused else { return }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        state = .active
        startTimer()
    }
    
    public func stopWorkout() {
        guard state == .active || state == .paused else { return }
        
        stopTimer()
        
        if var workout = currentWorkout {
            workout.end()
            workoutHistory.append(workout)
            saveWorkoutHistory()
        }
        
        currentWorkout = nil
        state = .completed
        elapsedTime = 0
        pausedDuration = 0
        pauseStartTime = nil
        
        // Auto-reset to notStarted after a brief delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            state = .notStarted
        }
    }
    
    public func resetWorkout() {
        stopTimer()
        currentWorkout = nil
        state = .notStarted
        elapsedTime = 0
        pausedDuration = 0
        pauseStartTime = nil
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let workout = currentWorkout else { return }
        elapsedTime = Date().timeIntervalSince(workout.startTime) - pausedDuration
    }
    
    private func saveWorkoutHistory() {
        do {
            let data = try JSONEncoder().encode(workoutHistory)
            try? storage.saveObject(data, forKey: "workout_history")
        } catch {
            print("Failed to save workout history: \(error)")
        }
    }
    
    private func loadWorkoutHistory() {
        workoutHistory = (try? storage.retrieveObject([Workout].self, forKey: "workout_history")) ?? []
    }
}

// MARK: - Computed Properties
@available(iOS 14.0, *)
public extension WorkoutTracker {
    var formattedElapsedTime: String {
        formatTimeInterval(elapsedTime)
    }
    
    var totalWorkoutsThisWeek: Int {
        let startOfWeek = Date().startOfWeek
        return workoutHistory.filter { workout in
            workout.startTime >= startOfWeek
        }.count
    }
    
    var totalDurationThisWeek: TimeInterval {
        let startOfWeek = Date().startOfWeek
        return workoutHistory
            .filter { $0.startTime >= startOfWeek }
            .reduce(0) { $0 + $1.duration }
    }
}

// MARK: - Helper Functions
private func formatTimeInterval(_ interval: TimeInterval) -> String {
    let hours = Int(interval) / 3600
    let minutes = Int(interval) % 3600 / 60
    let seconds = Int(interval) % 60
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

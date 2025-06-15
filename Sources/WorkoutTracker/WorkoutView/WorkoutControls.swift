//
//  WorkoutControls.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public struct WorkoutControls: View {
    @ObservedObject var workoutTracker: WorkoutTracker
    let selectedType: WorkoutType
    let onError: (String) -> Void
    
    public var body: some View {
        VStack(spacing: 16) {
            if workoutTracker.currentSession == nil {
                Button("Start Workout") {
                    Task {
                        do {
                            try await workoutTracker.startWorkout(type: selectedType)
                        } catch {
                            onError(error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                HStack(spacing: 16) {
                    if workoutTracker.isTracking {
                        Button("Pause") {
                            Task {
                                do {
                                    try await workoutTracker.pauseWorkout()
                                } catch {
                                    onError(error.localizedDescription)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Resume") {
                            Task {
                                do {
                                    try await workoutTracker.resumeWorkout()
                                } catch {
                                    onError(error.localizedDescription)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Stop") {
                        Task {
                            do {
                                try await workoutTracker.stopWorkout()
                            } catch {
                                onError(error.localizedDescription)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
    }
}

//
//  WorkoutView.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
public struct WorkoutView: View {
    @StateObject private var tracker = WorkoutTracker()
    @State private var selectedWorkoutType: WorkoutType = .running
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                workoutTypeSelector
                
                currentWorkoutDisplay
                
                controlButtons
                
                Spacer()
                
                workoutStats
            }
            .padding()
            .navigationTitle("Workout Tracker")
        }
    }
    
    private var workoutTypeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Workout Type")
                .font(.headline)
            
            Picker("Workout Type", selection: $selectedWorkoutType) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.emoji)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .disabled(tracker.state != .notStarted)
        }
    }
    
    private var currentWorkoutDisplay: some View {
        VStack(spacing: 16) {
            if let workout = tracker.currentWorkout {
                VStack(spacing: 8) {
                    Text(workout.type.emoji)
                        .font(.system(size: 60))
                    
                    Text(workout.type.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Text(tracker.formattedElapsedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Text(stateText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(stateColor.opacity(0.2))
                    )
            } else {
                Text("No active workout")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 200)
    }
    
    private var controlButtons: some View {
        HStack(spacing: 16) {
            switch tracker.state {
            case .notStarted:
                Button("Start Workout") {
                    tracker.startWorkout(type: selectedWorkoutType)
                }
                .buttonStyle(PrimaryButtonStyle())
                
            case .active:
                Button("Pause") {
                    tracker.pauseWorkout()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Stop") {
                    tracker.stopWorkout()
                }
                .buttonStyle(DestructiveButtonStyle())
                
            case .paused:
                Button("Resume") {
                    tracker.resumeWorkout()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Stop") {
                    tracker.stopWorkout()
                }
                .buttonStyle(DestructiveButtonStyle())
                
            case .completed:
                Button("Start New Workout") {
                    tracker.resetWorkout()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    
    private var workoutStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            HStack {
                StatCard(
                    title: "Workouts",
                    value: "\(tracker.totalWorkoutsThisWeek)",
                    icon: "figure.run"
                )
                
                StatCard(
                    title: "Duration",
                    value: formatTimeInterval(tracker.totalDurationThisWeek),
                    icon: "clock"
                )
            }
        }
    }
    
    private var stateText: String {
        switch tracker.state {
        case .notStarted: return "Ready to start"
        case .active: return "Workout in progress"
        case .paused: return "Workout paused"
        case .completed: return "Workout completed!"
        }
    }
    
    private var stateColor: Color {
        switch tracker.state {
        case .notStarted: return .blue
        case .active: return .green
        case .paused: return .orange
        case .completed: return .purple
        }
    }
}

// MARK: - Supporting Views
@available(iOS 14.0, *)
private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Button Styles
@available(iOS 14.0, *)
private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

@available(iOS 14.0, *)
private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

@available(iOS 14.0, *)
private struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}


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

@available(iOS 14.0, *)
#Preview {
    WorkoutView()
}

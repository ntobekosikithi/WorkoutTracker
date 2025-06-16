//
//  WorkoutSessionCard.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import SwiftUI
import Utilities

@available(iOS 14.0, *)
public struct WorkoutSessionCard: View {
    let session: WorkoutSession
    let elapsedTime: String
    let isTracking: Bool
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: session.type.systemImage)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(session.type.rawValue)
                        .font(.headline)
                    Text(session.status.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(isTracking ? .green : .orange)
                    .frame(width: 12, height: 12)
            }
            
            Text(elapsedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

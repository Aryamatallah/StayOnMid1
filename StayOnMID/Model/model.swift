//
//  model.swift
//  APP1
//
//  Created by Aryam on 26/02/2026.
//
import Foundation

struct Medication: Identifiable, Codable {
    let id: UUID
    var name: String
    var time: Date
    var frequency: Int        // 1 - 2 - 3
    var remaining: Int        // كم باقي اليوم
    var repeatDays: [Int]     // أيام الأسبوع 1-7

    init(
        id: UUID = UUID(),
        name: String,
        time: Date,
        frequency: Int,
        repeatDays: [Int]
    ) {
        self.id = id
        self.name = name
        self.time = time
        self.frequency = frequency
        self.remaining = frequency
        self.repeatDays = repeatDays
    }
}

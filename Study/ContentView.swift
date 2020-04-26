//
//  ContentView.swift
//  Study
//
//  Created by GP on 4/23/20.
//  Copyright © 2020 GP. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        //Text("Hello, World!")
        Text(stats())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(.custom("Monaco", size: 14))
        //.foregroundColor(.green)
    }
    
    /**********************************************************/
    func stats() -> String {
        let text = readFile()
        if (text == "") {
            return "File is empty"
        }
        let data = csv(data: text)
        var dict = [Date: Int]()
        for row in data {
            let dateStr = row[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let minutes = Int(row[2].trimmingCharacters(in: .whitespacesAndNewlines))
            let date = readDate(fromStr: dateStr)
            if (dict[date] == nil) {
                dict[date] = minutes
            } else {
                dict[date]! += minutes!
            }
        }
        
        var sum = 0
        for date in dict.keys {
            sum += dict[date]!
        }
        let average = sum / dict.count
        var str = formattedCalendar()
        str += "\n Average -> \(formatTimeP(from: average))\n"
        
        let sortedKeys = Array(dict.keys).sorted()
        for (i, date) in sortedKeys.enumerated() {
            if ((sortedKeys.count - i) <= 7) {
                let formatter = DateFormatter()
                formatter.timeStyle = .none
                formatter.dateStyle = .short
                str += "\n \(formatter.string(from: date)) -> \(formatTimeP(from: dict[date] ?? 0))"
            }
        }
        return str
    }
    
    /**********************************************************/
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    /**********************************************************/
    func readFile() -> String {
        let file = "study.csv"
        if let dir = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask).first {
            let fileURL = dir.appendingPathComponent("\(NSUserName())/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/\(file)")
            
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text
            } catch {/* error handling here */
                print("Unexpected error: \(error).")
            }
        }
        return "readFile error"
    }
    
    /**********************************************************/
    func appendToFile(minutes: Int) {
        let current = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        var str = "\n\(formatter.string(from: current))"
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        str += ",\(formatter.string(from: current))"
        str += ",\(minutes)"
        
        let file = "study.csv"
        if let dir = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask).first {
            let fileURL = dir.appendingPathComponent("\(NSUserName())/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/\(file)")
            
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(str.data(using: String.Encoding.utf8)!)
            } else {
                do {
                    try str.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("Unexpected error: \(error).")
                    _ = AppDelegate.dialogOKCancel(question: "Error", text: "\(error)", cancelButton: false)
                    NSApplication.shared.terminate(self)
                }
                //try write(to: fileURL, options: .atomic)
            }
        }
    }
    
    /**********************************************************/
    func readDate(fromStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter.date(from: fromStr)!
    }
    
    /**********************************************************/
    func formatTimeP(from: Int) -> String {
        let hr = from / 60
        let mnt = from % 60
        var str = ""
        if (mnt < 10) {
            str += "\(hr):0\(mnt)"
        } else {
            str += "\(hr):\(mnt)"
        }
        return str
    }
    
    /**********************************************************/
    func formattedCalendar() -> String {
        let calendar = Calendar.current
        let date = Date()
        let range = calendar.range(of: .day, in: .month, for: date)!
        let year = calendar.component(.year, from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: date)
        var str = " \(month) \(year)\n\n"
        let today = calendar.component(.day, from: date)
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateComponents.day = 1
        let date1 = calendar.date(from: dateComponents)
        let wday1 = calendar.component(.weekday, from: date1!)
        
        str += " Su  Mo  Tu  We  Th  Fr  Sa\n"
        for _ in 2...wday1 {
            str += "    "
        }
        for i in 1...range.count {
            if (i == today) {
                str += (i < 10) ? " [" : "["
            } else {
                str += (i < 10) ? "  " : " "
            }
            str += "\(i)"
            str += (i == today) ? "]" : " "
            if (((wday1 + i - 1) % 7) == 0) {
                str += "\n"
            }
        }
        str += "\n"
        return str
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

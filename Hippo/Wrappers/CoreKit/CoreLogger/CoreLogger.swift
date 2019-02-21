//
// CoreLogger.swift
//
// Copyright (c) 2015-2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

private let benchmarker = Benchmarker()


public enum Level {
    case application, api, request, response, socket, message, info, error, warning, custom, all, customError
    
    var description: String {
        return String(describing: self).uppercased()
    }
    
}
//
//extension Level: Comparable {}
//
// func ==(x: Level, y: Level) -> Bool {
//    return x.hashValue == y.hashValue
//}
//
// func <(x: Level, y: Level) -> Bool {
//    return x.hashValue < y.hashValue
//}

public class CoreLogger {
    /// The logger state.
     var enabled: Bool = true
    
    /// The logger formatter.
     var formatter: Formatter {
        didSet { formatter.logger = self }
    }
    
    /// The logger theme.
     var theme: LoggerTheme?
    
    /// The minimum level of severity.
     var allowedLevel: [Level]
    
    /// The logger format.
     var format: String {
        return formatter.description
    }
    
    /// The logger colors
//     var colors: String {
//        return theme?.description ?? ""
//    }
    
    /// The queue used for logging.
    private let queue = DispatchQueue(label: "corekit.log")
    
    /**
     Creates and returns a new logger.
     
     - parameter formatter: The formatter.
     - parameter theme:     The theme.
     - parameter minLevel:  The minimum level of severity.
     
     - returns: A newly created logger.
     */
     public init(formatter: Formatter = .defaultFormat, theme: LoggerTheme? = nil, minLevels: [Level]? = nil) {
        self.formatter = formatter
        self.theme = theme
        self.allowedLevel = minLevels ?? [Level.all]
        
        formatter.logger = self
    }
    /**
     Creates and returns a new logger.
     
     - parameter formatter: The formatter.
     - parameter theme:     The theme.
     - parameter minLevel:  The minimum level of severity.
     
     - returns: A newly created logger.
     */
    public init(formatter: Formatter = .defaultFormat, theme: LoggerTheme? = nil, minLevel: Level = .all) {
        self.formatter = formatter
        self.theme = theme
        self.allowedLevel = [minLevel]
        
        formatter.logger = self
    }
    /**
     Logs a message with a trace severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func trace(_ items: Any..., level: Level, separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(level, items, separator, terminator, file, line, column, function)
    }
    
    /**
     Logs a message with a debug severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
     public func debug(_ items: Any..., level: Level, separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(level, items, separator, terminator, file, line, column, function)
    }
    
    /**
     Logs a message with an info severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
     public func info(_ items: Any..., level: Level, separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(level, items, separator, terminator, file, line, column, function)
    }
    
    /**
     Logs a message with a warning severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
     public func warning(_ items: Any..., level: Level, separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(level, items, separator, terminator, file, line, column, function)
    }
    
    /**
     Logs a message with an error severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    public func error(_ items: Any..., level: Level, separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(level, items, separator, terminator, file, line, column, function)
    }
    
    /**
     Logs a message.
     
     - parameter level:      The severity level.
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    private func log(_ level: Level, _ items: [Any], _ separator: String, _ terminator: String, _ file: String, _ line: Int, _ column: Int, _ function: String) {
        guard enabled else {
            return
        }
        
        guard allowedLevel.contains(level) || allowedLevel.contains(.all) else {
            return
        }
        
        let date = Date()
        
        let result = formatter.format(
            level: level,
            items: items,
            separator: separator,
            terminator: terminator,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )
        
        queue.async {
            Swift.print(result, separator: "", terminator: "")
        }
    }
    
    /**
     Measures the performance of code.
     
     - parameter description: The measure description.
     - parameter n:           The number of iterations.
     - parameter file:        The file in which the measure happens.
     - parameter line:        The line at which the measure happens.
     - parameter column:      The column at which the measure happens.
     - parameter function:    The function in which the measure happens.
     - parameter block:       The block to measure.
     */
     public func measure(_ level: Level, _ description: String? = nil, iterations n: Int = 10, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, block: () -> Void) {
        guard enabled else {
            return
        }
        
        guard allowedLevel.contains(level) || allowedLevel.contains(.all) else {
            return
        }
        
        let measure = benchmarker.measure(description, iterations: n, block: block)
        
        let date = Date()
        
        let result = formatter.format(
            description: measure.description,
            average: measure.average,
            relativeStandardDeviation: measure.relativeStandardDeviation,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )
        
        queue.async {
            Swift.print(result)
        }
    }
}

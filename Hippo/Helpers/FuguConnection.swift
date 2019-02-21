//
//  FuguConnection.swift
//  Fugu
//
//  Created by Gagandeep Arora on 04/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//




//
//  NetworkReachabilityManager.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if !os(watchOS)

import Foundation
import SystemConfiguration

/// The `NetworkReachabilityManager` class listens for reachability changes of hosts and addresses for both WWAN and
/// WiFi network interfaces.
///
/// Reachability can be used to determine background information about why a network operation failed, or to retry
/// network requests when a connection is established. It should not be used to prevent a user from initiating a network
/// request, as it's possible that an initial request may be required to establish reachability.
open class NetworkReachabilityManager {
    /// Defines the various states of network reachability.
    ///
    /// - unknown:      It is unknown whether the network is reachable.
    /// - notReachable: The network is not reachable.
    /// - reachable:    The network is reachable.
    public enum NetworkReachabilityStatus {
        case unknown
        case notReachable
        case reachable(ConnectionType)
    }
    
    /// Defines the various connection types detected by reachability flags.
    ///
    /// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
    /// - wwan:           The connection type is a WWAN connection.
    public enum ConnectionType {
        case ethernetOrWiFi
        case wwan
    }
    
    /// A closure executed when the network reachability status changes. The closure takes a single argument: the
    /// network reachability status.
    public typealias Listener = (NetworkReachabilityStatus) -> Void
    
    // MARK: - Properties
    
    /// Whether the network is currently reachable.
    open var isReachable: Bool { return isReachableOnWWAN || isReachableOnEthernetOrWiFi }
    
    /// Whether the network is currently reachable over the WWAN interface.
    open var isReachableOnWWAN: Bool { return networkReachabilityStatus == .reachable(.wwan) }
    
    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    open var isReachableOnEthernetOrWiFi: Bool { return networkReachabilityStatus == .reachable(.ethernetOrWiFi) }
    
    /// The current network reachability status.
    open var networkReachabilityStatus: NetworkReachabilityStatus {
        guard let flags = self.flags else { return .unknown }
        return networkReachabilityStatusForFlags(flags)
    }
    
    /// The dispatch queue to execute the `listener` closure on.
    open var listenerQueue: DispatchQueue = DispatchQueue.main
    
    /// A closure executed when the network reachability status changes.
    open var listener: Listener?
    
    open var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            return flags
        }
        
        return nil
    }
    
    private let reachability: SCNetworkReachability
    open var previousFlags: SCNetworkReachabilityFlags
    
    // MARK: - Initialization
    
    /// Creates a `NetworkReachabilityManager` instance with the specified host.
    ///
    /// - parameter host: The host used to evaluate network reachability.
    ///
    /// - returns: The new `NetworkReachabilityManager` instance.
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
        self.init(reachability: reachability)
    }
    
    /// Creates a `NetworkReachabilityManager` instance that monitors the address 0.0.0.0.
    ///
    /// Reachability treats the 0.0.0.0 address as a special token that causes it to monitor the general routing
    /// status of the device, both IPv4 and IPv6.
    ///
    /// - returns: The new `NetworkReachabilityManager` instance.
    public convenience init?() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &address, { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return nil }
        
        self.init(reachability: reachability)
    }
    
    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
        self.previousFlags = SCNetworkReachabilityFlags()
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Listening
    
    /// Starts listening for changes in network reachability status.
    ///
    /// - returns: `true` if listening was started successfully, `false` otherwise.
    @discardableResult
    open func startListening() -> Bool {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()
        
        let callbackEnabled = SCNetworkReachabilitySetCallback(
            reachability,
            { (_, flags, info) in
                let reachability = Unmanaged<NetworkReachabilityManager>.fromOpaque(info!).takeUnretainedValue()
                reachability.notifyListener(flags)
        },
            &context
        )
        
        let queueEnabled = SCNetworkReachabilitySetDispatchQueue(reachability, listenerQueue)
        
        listenerQueue.async {
            self.previousFlags = SCNetworkReachabilityFlags()
            self.notifyListener(self.flags ?? SCNetworkReachabilityFlags())
        }
        
        return callbackEnabled && queueEnabled
    }
    
    /// Stops listening for changes in network reachability status.
    open func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
    
    // MARK: - Internal - Listener Notification
    
    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        guard previousFlags != flags else { return }
        previousFlags = flags
        
        listener?(networkReachabilityStatusForFlags(flags))
    }
    
    // MARK: - Internal - Network Reachability Status
    
    func networkReachabilityStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
        guard isNetworkReachable(with: flags) else { return .notReachable }
        
        var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)
        
        #if os(iOS)
        if flags.contains(.isWWAN) { networkStatus = .reachable(.wwan) }
        #endif
        
        return networkStatus
    }
    
    func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}

// MARK: -

extension NetworkReachabilityManager.NetworkReachabilityStatus: Equatable {}

/// Returns whether the two network reachability status values are equal.
///
/// - parameter lhs: The left-hand side value to compare.
/// - parameter rhs: The right-hand side value to compare.
///
/// - returns: `true` if the two values are equal, `false` otherwise.
public func ==(
    lhs: NetworkReachabilityManager.NetworkReachabilityStatus,
    rhs: NetworkReachabilityManager.NetworkReachabilityStatus)
    -> Bool
{
    switch (lhs, rhs) {
    case (.unknown, .unknown):
        return true
    case (.notReachable, .notReachable):
        return true
    case let (.reachable(lhsConnectionType), .reachable(rhsConnectionType)):
        return lhsConnectionType == rhsConnectionType
    default:
        return false
    }
}

#endif




////import SystemConfiguration
////import Foundation
//
//public enum FuguConnectionError: Error {
//    case FailedToCreateWithAddress(sockaddr_in)
//    case FailedToCreateWithHostname(String)
//    case UnableToSetCallback
//    case UnableToSetDispatchQueue
//}
//
//@available(*, unavailable, renamed: "Notification.Name.fuguConnectionChanged")
//public let FuguConnectionChangedNotification = NSNotification.Name("FuguConnectionChangedNotification")
//
//extension Notification.Name {
//    public static let fuguConnectionChanged = Notification.Name("fuguConnectionChanged")
//}
//
//func callback(reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
//    
//    guard let info = info else { return }
//    
//    let reachability = Unmanaged<FuguConnection>.fromOpaque(info).takeUnretainedValue()
//    reachability.reachabilityChanged()
//}
//
//public class FuguConnection {
//    
//    public typealias NetworkReachable = (FuguConnection) -> ()
//    public typealias NetworkUnreachable = (FuguConnection) -> ()
//    
//    @available(*, unavailable, renamed: "Conection")
//    public enum NetworkStatus: CustomStringConvertible {
//        case notReachable, reachableViaWiFi, reachableViaWWAN
//        public var description: String {
//            switch self {
//            case .reachableViaWWAN: return "Cellular"
//            case .reachableViaWiFi: return "WiFi"
//            case .notReachable: return "No Connection"
//            }
//        }
//    }
//    
//    public enum Connection: CustomStringConvertible {
//        case none, wifi, cellular
//        public var description: String {
//            switch self {
//            case .cellular: return "Cellular"
//            case .wifi: return "WiFi"
//            case .none: return "No Connection"
//            }
//        }
//    }
//    
//    public var whenReachable: NetworkReachable?
//    public var whenUnreachable: NetworkUnreachable?
//    
//    @available(*, deprecated: 4.0, renamed: "allowsCellularConnection")
//    public let reachableOnWWAN: Bool = true
//    
//    /// Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)
//    public var allowsCellularConnection: Bool
//    
//    // The notification center on which "reachability changed" events are being posted
//    public var notificationCenter: NotificationCenter = NotificationCenter.default
//    
//    @available(*, deprecated: 4.0, renamed: "connection.description")
//    public var currentReachabilityString: String {
//        return "\(connection)"
//    }
//    
//    @available(*, unavailable, renamed: "connection")
//    public var currentReachabilityStatus: Connection {
//        return connection
//    }
//    
//    fileprivate var connection: Connection {
//        
//        guard isReachableFlagSet else {
//         return .none
//      }
//        
//        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
//        guard isRunningOnDevice else {
//         return .wifi
//      }
//        
//        var connection = Connection.none
//        
//        if !isConnectionRequiredFlagSet {
//            connection = .wifi
//        }
//        
//        if isConnectionOnTrafficOrDemandFlagSet {
//            if !isInterventionRequiredFlagSet {
//                connection = .wifi
//            }
//        }
//        
//        if isOnWWANFlagSet {
//            if !allowsCellularConnection {
//                connection = .none
//            } else {
//                connection = .cellular
//            }
//        }
//        
//        return connection
//    }
//    
//    class var isNetworkConnected: Bool {
//        return FuguNetworkHandler.shared.reachability.connection.hashValue != Connection.none.hashValue
//    }
//    fileprivate var previousFlags: SCNetworkReachabilityFlags?
//    
//    fileprivate var isRunningOnDevice: Bool = {
//        #if (arch(i386) || arch(x86_64)) && os(iOS)
//            return false
//        #else
//            return true
//        #endif
//    }()
//    
//    fileprivate var notifierRunning = false
//    fileprivate let reachabilityRef: SCNetworkReachability
//    
//    fileprivate let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")
//    
//    required public init(reachabilityRef: SCNetworkReachability) {
//        allowsCellularConnection = true
//        self.reachabilityRef = reachabilityRef
//    }
//    
//    public convenience init?(hostname: String) {
//        
//        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }
//        
//        self.init(reachabilityRef: ref)
//    }
//    
//    public convenience init?() {
//        
//        var zeroAddress = sockaddr()
//        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
//        zeroAddress.sa_family = sa_family_t(AF_INET)
//        
//        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else { return nil }
//        
//        self.init(reachabilityRef: ref)
//    }
//    
//    deinit {
//        stopNotifier()
//    }
//}
//
//public extension FuguConnection {
//    
//    // MARK: - *** Notifier methods ***
//    func startNotifier() throws {
//        
//        guard !notifierRunning else {
//         return
//      }
//        
//        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
//        context.info = UnsafeMutableRawPointer(Unmanaged<FuguConnection>.passUnretained(self).toOpaque())
//        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
//            stopNotifier()
//            throw FuguConnectionError.UnableToSetCallback
//        }
//        
//        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
//            stopNotifier()
//            throw FuguConnectionError.UnableToSetDispatchQueue
//        }
//        
//        // Perform an initial check
//        reachabilitySerialQueue.async {
//            self.reachabilityChanged()
//        }
//        
//        notifierRunning = true
//    }
//    
//    func stopNotifier() {
//        defer { notifierRunning = false }
//        
//        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
//        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
//    }
//    
//    // MARK: - *** Connection test methods ***
//    @available(*, deprecated: 4.0, message: "Please use `connection != .none`")
//    var isReachable: Bool {
//        
//        guard isReachableFlagSet else { return false }
//        
//        if isConnectionRequiredAndTransientFlagSet {
//            return false
//        }
//        
//        if isRunningOnDevice {
//            if isOnWWANFlagSet && !reachableOnWWAN {
//                // We don't want to connect when on cellular connection
//                return false
//            }
//        }
//        
//        return true
//    }
//    
//    @available(*, deprecated: 4.0, message: "Please use `connection == .cellular`")
//    var isReachableViaWWAN: Bool {
//        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
//        return isRunningOnDevice && isReachableFlagSet && isOnWWANFlagSet
//    }
//    
//    @available(*, deprecated: 4.0, message: "Please use `connection == .wifi`")
//    var isReachableViaWiFi: Bool {
//        
//        // Check we're reachable
//        guard isReachableFlagSet else { return false }
//        
//        // If reachable we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
//        guard isRunningOnDevice else { return true }
//        
//        // Check we're NOT on WWAN
//        return !isOnWWANFlagSet
//    }
//    
//    var description: String {
//        
//        let W = isRunningOnDevice ? (isOnWWANFlagSet ? "W" : "-") : "X"
//        let R = isReachableFlagSet ? "R" : "-"
//        let c = isConnectionRequiredFlagSet ? "c" : "-"
//        let t = isTransientConnectionFlagSet ? "t" : "-"
//        let i = isInterventionRequiredFlagSet ? "i" : "-"
//        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
//        let D = isConnectionOnDemandFlagSet ? "D" : "-"
//        let l = isLocalAddressFlagSet ? "l" : "-"
//        let d = isDirectFlagSet ? "d" : "-"
//        
//        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
//    }
//}
//
//fileprivate extension FuguConnection {
//    
//    func reachabilityChanged() {
//        guard previousFlags != flags else { return }
//        
//        let block = connection != .none ? whenReachable : whenUnreachable
//        
//        DispatchQueue.main.async {
//            block?(self)
//            self.notificationCenter.post(name: .fuguConnectionChanged, object:self)
//        }
//        previousFlags = flags
//    }
//    
//    var isOnWWANFlagSet: Bool {
//        #if os(iOS)
//            return flags.contains(.isWWAN)
//        #else
//            return false
//        #endif
//    }
//    var isReachableFlagSet: Bool {
//        return flags.contains(.reachable)
//    }
//    var isConnectionRequiredFlagSet: Bool {
//        return flags.contains(.connectionRequired)
//    }
//    var isInterventionRequiredFlagSet: Bool {
//        return flags.contains(.interventionRequired)
//    }
//    var isConnectionOnTrafficFlagSet: Bool {
//        return flags.contains(.connectionOnTraffic)
//    }
//    var isConnectionOnDemandFlagSet: Bool {
//        return flags.contains(.connectionOnDemand)
//    }
//    var isConnectionOnTrafficOrDemandFlagSet: Bool {
//        return !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
//    }
//    var isTransientConnectionFlagSet: Bool {
//        return flags.contains(.transientConnection)
//    }
//    var isLocalAddressFlagSet: Bool {
//        return flags.contains(.isLocalAddress)
//    }
//    var isDirectFlagSet: Bool {
//        return flags.contains(.isDirect)
//    }
//    var isConnectionRequiredAndTransientFlagSet: Bool {
//        return flags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
//    }
//    
//    var flags: SCNetworkReachabilityFlags {
//        var flags = SCNetworkReachabilityFlags()
//        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
//            return flags
//        } else {
//            return SCNetworkReachabilityFlags()
//        }
//    }
//}

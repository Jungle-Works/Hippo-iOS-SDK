//
//  HippoStrings.swift
//  Hippo
//
//  Created by Vishal on 20/11/18.
//

import Foundation

public class HippoStrings {
    //cp sdk
    static var ongoing = "Current".localized
    static var past = "Past".localized
    static var newConversation = "New Conversation".localized
    static var noNetworkConnection = "No internet connection".localized
    static var connected = "Connected".localized
    static var somethingWentWrong = "Something went wrong.".localized
    static var loading = "Loading...".localized
    static var photoLibrary = "Photo & Video Library".localized
    static var camera = "Camera".localized
    static var document = "Document".localized
    static var payment = "Payment".localized
    static var retry = "Retry".localized
    static var noChatStarted = "Seems like you haven't started any chat yet, kick start it now!".localized
    static var noChatInCatagory = "You have no chats.".localized
    static var writeReview = "Write a review".localized
    open var messagePlaceHolderText = "Send a message....".localized
    static var enterSomeText = "Please enter some text.".localized
    static var attachmentCancel = "Cancel".localized
    static var ok = "OK".localized
    static var support = "Support".localized
    static var noMinSelection = "Please select atleast one option"
    
    
    open var disbaledCameraErrorMessage = "Access to Camera is denied. Please enable from setings."
    open var cameraString = "New Image via Camera"
    open var displayNameForCustomers = "Fleet"
    open var broadCastTitle = "This will send message to your active*"
    open var broadCastTitleInfo = "*Based on past 30 days login activity."
    open var selectTeamsString = "Select Team"
    open var showString = "Show"
    open var selectString = "Select"
    open var selectedString = "Selected"
    open var titleString = "Title"
    open var MessageString = "Message"
    open var seePreviousMessges = "See Previous Messages"
    open var noBroadcastAvailable = "No broadcast found!"
    
    open var allTeamString = "All Teams"
    open var allAgentsString = "All"
    
//    open var checkingNewMessages = "Updating new messages..."
    
    var videoCallDisabledFromHippo = "Please contact your Admin to enable video call."
    
    var callClientNotFound = "CallClient is not installed, please add pod Hippo/Call in pod file and run pod install and then try again"
    var invalidEmail = "Invalid email address"
    var inputDataIsInvalid = "Input data is invalid"
    var notAllowedForAgent = "This function/method is not allowed for agent."
    
    var defaultFallbackText = "This message cannot be displayed"
    var chatHistory = "Conversations"
    
    //Status
    static let active = "Active"
    static let inActive = "Inactive"
    static let revoked = "Revoked"
    static let invited = "Invited"
    
    //Conversation Screen Text
    static let normalMessagePlaceHolder = "Type a message..."//"Type a message, use / to add a saved reply"
    static let privateMessagePlaceHolder = "Send an Internal note to your team, use @name to tag"
    static let normalMessagePlaceHolderWithoutCannedMessage = "Type a message..."
    
    public init() {
        
    }
}

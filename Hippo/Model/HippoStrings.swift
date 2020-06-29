//
//  HippoStrings.swift
//  Hippo
//
//  Created by Vishal on 20/11/18.
//

import Foundation
import HippoCallClient


public class HippoStrings {
    //cp sdk
    static var ongoing = "Current".localized
    static var past = "Past".localized
    open var newConversation = "New Conversation".localized
    static var noNetworkConnection = "No internet connected".localized
    static var connected = "Connected".localized
    static var somethingWentWrong = "Something went wrong. Please try again".localized
    static var loading = "Loading...".localized
    static var photoLibrary = "Photo & Video Library".localized
    static var camera = "Camera".localized
    static var document = "Document".localized
    static var payment = "Payment".localized
    open var retry = "Retry".localized
    open var noChatStarted = "Seems like you haven't started any chat yet, kick start it now!".localized
    open var noChatInCatagory = "You have no chats.".localized
    static var writeReview = "Write a review".localized
    open var messagePlaceHolderText = "Send a message...".localized
    static var enterSomeText = "Please enter some text.".localized
    static var attachmentCancel = "Cancel".localized
    static var ok = "OK".localized
    static var support = "Support".localized
    static var noMinSelection = "Please select atleast one option".localized
    static var broadcastDetails = "Broadcast Details".localized
    static var recipients = "Recipients".localized
    static var addOption = "Add an option".localized
    static var requestPayment = "Request Payment".localized
    static var savePlan = "Save Plan".localized
    static var updatePlan = "Update Plan".localized
    static var connecting = "Connecting...".localized
    static var hippoDefaultText = "Your request has been submitted successfully".localized
    static var callback = "Call Back".localized
    static var callAgain = "Call Again".localized
    static var callEnded = "call ended".localized
    static var video = "video".localized
    static var voice = "voice".localized
    static var the = "The".localized
    static var missed = "Missed".localized
    static var call = "call".localized
    static var ongoing_call = "Ongoing".localized
    static var paymentPaid = "- PAID -".localized
    static var paymentPending = "- PENDING -".localized
    static var free = "Free".localized
    static var at = "at".localized
    static var messageSent = " sent a message".localized
    static var today = "Today".localized
    static var yesterday = "Yesterday".localized
    static var Pay = "Pay".localized
    static var Done = "Done".localized
    static var selectString = "Select".localized
    static var clearAll = "Clear All".localized
    static var noPaymentMethod = "No payment method available".localized
    static var readMore = "Read More".localized
    static var readLess = "Read Less".localized
    static var noNotificationFound = "No Notifications found".localized
    static var you = "You".localized
    static var versionMismatch = "Version Mismatch".localized
    static var callAnyway = "Call anyway".localized
    static var callOldSdk = "does not have the updated app, Calling using old SDK...".localized
    static var yesCancel = "Yes, Cancel".localized
    static var no = "No".localized
    static var currency = "Currency".localized
    static var title = "Title".localized
    static var price = "Price".localized
    static var enterPrice = "Enter Price".localized
    var selectaPlan = "Select a Plan".localized
    static var proccedToPay = "Proceed To Pay".localized
    static var ratingReview = "Rating & Review".localized
    static var audio = "Audio".localized
    static var image = "Image".localized
    static var cancel = "Cancel".localized
    static var alert = "Alert!".localized
    static var chatHistory = "Conversations".localized
    static var enterTitle = "Enter Title".localized
    static var enterDescription = "Enter Description".localized
    static var description = "Description".localized
    static var notifications = "Notifications".localized
    static var submit = "Submit".localized
    static var totalPrice = "Total Price".localized
    static var yes = "Yes".localized
    static var logout = "Are you sure you want to logout?".localized
    static var logoutTitle = "Logout".localized
    static var unknownMessage = "This message doesn't support in your current app.".localized
    static var allAgentsString = "All".localized
    var incomingCall = "Incoming Call".localized
    static var paymentRequest = "Payment Request".localized
    static var calling = "CALLING...".localized
    static var noComment = "No Comment...".localized
    static var ringing = "RINGING...".localized
    static var busyAnotherCall = "Busy on another call...".localized
    static var callDeclined = "Call Declined".localized
    static var isCallingYou = "is calling you...".localized
    static var sendPhoto = "Send Photo".localized
    static var back = "Back".localized
    static var slowInternet = "Slow Internet connection.".localized
    static var hippoSecurePayment = "100% secure payment".localized
    static var paymentRequested = "A payment is requested to you".localized
    static var clear = "Clear".localized
    static var cancelPayment = "Are you sure you want to cancel the payment?".localized
    static var cancelPaymentTitle = "Cancel Payment".localized

    open var disbaledCameraErrorMessage = "Access to Camera is denied. Please enable from setings."
    open var cameraString = "New Image via Camera"
    open var displayNameForCustomers = "Fleet"
    open var broadCastTitle = "This will send message to your active*"
    open var broadCastTitleInfo = "*Based on past 30 days login activity."
    open var selectTeamsString = "Select Team"
    open var showString = "Show"
    open var selectedString = "Selected"
    open var titleString = "Title"
    open var MessageString = "Message"
    open var seePreviousMessges = "See Previous Messages"
    open var noBroadcastAvailable = "No broadcast found!"
    
    open var allTeamString = "All Teams"
   
    
//    open var checkingNewMessages = "Updating new messages..."
    
    var videoCallDisabledFromHippo = "Please contact your Admin to enable video call."
    
    var callClientNotFound = "CallClient is not installed, please add pod Hippo/Call in pod file and run pod install and then try again"
    var invalidEmail = "Invalid email address"
    var inputDataIsInvalid = "Input data is invalid"
    var notAllowedForAgent = "This function/method is not allowed for agent."
    
    var defaultFallbackText = "This message cannot be displayed"
    
    
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
        HippoStrings.updateHippoCallClientStrings()
    }
    
    class func updateHippoCallClientStrings(){
        if versionCode > 320{
            #if canImport(HippoCallClient)
            
            HippoCallClientStrings.calling = HippoStrings.calling
            HippoCallClientStrings.ringing = HippoStrings.ringing
            HippoCallClientStrings.callingYou = HippoStrings.isCallingYou
            HippoCallClientStrings.callDeclined = HippoStrings.callDeclined
            HippoCallClientStrings.busyOnOtherCall = HippoStrings.busyAnotherCall
            
            #else
            
            #endif
        }
    }
    
}

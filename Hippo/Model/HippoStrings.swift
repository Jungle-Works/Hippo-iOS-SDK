//
//  HippoStrings.swift
//  Hippo
//
//  Created by Vishal on 20/11/18.
//

import Foundation
#if canImport(HippoCallClient)
import HippoCallClient
#else
#endif

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
    static var retry = "Retry".localized
    static var noChatStarted = "Seems like you haven't started any chat yet, kick start it now!".localized
    static var noChatInCatagory = "You have no chats.".localized
    static var writeReview = "Write a review".localized
    static var messagePlaceHolderText = "Send a message...".localized
    static var enterSomeText = "Please enter some text.".localized
    //static var attachmentCancel = "Cancel".localized
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
    static var selectaPlan = "Select a Plan".localized
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
    static var incomingCall = "Incoming Call".localized
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
    static var sendPaymentRequestPopup = "Are you sure you want to send Payment request?".localized
    static var deletePaymentPlan = "Are you sure you want to delete Payment Plan?".localized
    static var editPaymentPlan = "Are you sure you want to edit Payment Plan?".localized
    static var savePaymentPlan = "Save Payment Plan".localized
    static var planId = "Plan id:".localized
    static var planNameTitle = "Plan name:".localized
    static var planOwner = "Plan Owner:".localized
    static var updatedAt = "Updated at:".localized
    static var sendPayment = "Send Payment".localized
    static var donotAllowPersonalInfo = "You are not allowed to share personal details.".localized
    
    
    /// Agent sdk
    static var thanksForFeedback = "Thank you for your comments!".localized
    static var closed = "Closed".localized
    static var openChat = "Open Chats".localized
    static var newConversation = "New Conversation".localized
    static var actions = "Actions".localized
    static var closeChat = "Close Chat".localized
    static var attachmentImage = "Attachment: Image".localized
    static var status = "Status".localized
    static var myChats = "My Chats".localized
    static var unassigned = "Unassigned".localized
    static var coversationClosed = "Conversation Closed".localized
    static var conversationReopened = "Conversation Re-opened".localized
    static var conversationAssigned = "Conversation Assigned".localized
    static var profile = "Profile".localized
    static var channelInfo = "Channel Info".localized
    static var info = "Info".localized
    static var search = "Search".localized
    static var takeOver = "Take Over".localized
    static var savedPlans = "Saved Plans".localized
    static var planName = "Plan Name".localized
    static var email = "Email".localized
    static var inApp = "In App".localized
    static var selfTag = "Self".localized
    static var assignedToThemselves = "assigned to themselves".localized
    static var newChatAssignedToYou = "new chat is assigned to you".localized
    static var chatAssigned = "assigned chat to".localized
    static var chatReopenedby = "chat was reopened by".localized
    static var chatAutoOpened = "The chat was auto-opened".localized
    static var chatAutoClosed = "The chat was auto-closed".localized
    static var chatReopened = "The chat was re-opened by".localized
    static var chatClosedBy = "The chat was closed by".localized
    static var chatAutoAssigned = "was auto assigned".localized
    static var forceAssigned = "was forced assigned".localized
    static var tagged = "tagged".localized
    static var mentionedYou = "mentioned you".localized
    static var missedCallFrom = "you missed call from".localized
    static var allChats = "All Chats".localized
    static var text = "Text".localized
    static var internalNotes = "Internal Notes".localized
    static var bot = "Bot".localized
    static var privateMessagePlaceHolder = "Send an internal note to your team, use @name to tag".localized
    static var delivered = "Delivered".localized
    static var me = "Me".localized
    static var sentAPhoto = "sent a photo".localized
    static var sentAFile = "sent a File".localized
    static var customer = "Customer".localized
    static var assignConversation = "Assign Conversation".localized
    static var reset = "Reset".localized
    static var filter = "Filter".localized
    static var apply = "Apply".localized
    static var send = "SEND".localized
    static var noBotActionAvailable = "No Bot Action Available.".localized
    static var assignedTo = "Assigned To".localized
    static var demo = "Demo".localized
    static var visitor = "Visitor".localized
    static var agent = "Agent".localized
    static var userProfile = "User Profile".localized
    static var sendTitle = "Send".localized
    static var tags = "Tags".localized
    static var daysAgo = "days ago".localized
    static var botSkipped = "Bot has been skipped for this chat session.".localized
    static var newCustomer = "New Customer".localized
    static var closeChatPopup = "Are you sure, you want to Close this chat?".localized
    static var reopenChatPopup = "Are you sure, you want to Reopen this chat?".localized
    static var takeOverChat = "Are you sure, you want to assign this chat to you?".localized
    static var reasignChat = "Are you sure, you want to reassign?".localized
    static var reasignChatToYou = "Are you sure, you want to reassign this chat to you?".localized
    static var saved = "Saved!".localized
    static var imageSaved = "Image has been saved to your photos.".localized
    static var reopenChat = "Reopen Chat".localized
    static var noDataFound = "No data found!"
    static var isRequired = "is required".localized
    static var enterPlanName = "Enter plan name".localized
    static var invalidPriceAmount = "Invalid Price".localized
    static var fieldEmpty = "Field cannot be empty".localized
    static var closedChat = "Closed Chats".localized
    static var noConversationFound = "No conversations found.".localized
    static var botInProgress = "Bot in progress".localized
    static var connectingToMeeting = "Connecting you to your meeting".localized
    static var deleteMessagePopup = "Are you sure you want to delete this message?".localized
    static var deleteForEveryone = "Delete for Everyone".localized
    static var edit = "Edit".localized
    static var delete = "Delete".localized
    static var edited = "Edited".localized
    static var copy = "Copy".localized
    static var deleteMessage = "deleted this message.".localized
    static var establishingConnection = "Please wait while we are establishing the connection.."
    
    open var disbaledCameraErrorMessage = "Access to Camera is denied. Please enable from setings."
    
    static var myChatsOnly = "My Chats Only".localized
    static var unassignedChats = "Unassigned Chats".localized
    static var mySupportChats = "My Support Chats".localized
    static var type = "Type".localized
    static var supportChats = "Support Chats".localized
    static var requiredField = "Field is required"
    static var enterValidEmail = "Enter valid email"
    
    
    
  
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
    open var presciption = "Send E-form"
    open var selectPresciptionHeader = "Select E-form Template"
    open var sendPrescription = "Send Prescription"
    open var noCustomField = "No custom field found."
    
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
    
  
   
    
    public init() {
      
    }
    
    class func updateHippoCallClientStrings(){
        #if canImport(JitsiMeet)
        
        HippoCallClientStrings.calling = HippoStrings.calling
        HippoCallClientStrings.ringing = HippoStrings.ringing
        HippoCallClientStrings.callingYou = HippoStrings.isCallingYou.lowercased()
        HippoCallClientStrings.callDeclined = HippoStrings.callDeclined
        HippoCallClientStrings.busyOnOtherCall = HippoStrings.busyAnotherCall
        HippoCallClientStrings.connectingToMeeting = HippoStrings.connectingToMeeting
//        HippoCallClientStrings.establishingConnection = HippoStrings.establishingConnection
        
        #endif
    }
    
}

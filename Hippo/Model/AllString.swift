//
//  AllString.swift
//  Hippo
//
//  Created by Arohi Sharma on 23/06/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//
 
import Foundation
class AllString{
    
    class func getAllStrings(completion: @escaping HippoResponseRecieved) {
        var params = [String: Any]()
        params["request_source"] = HippoConfig.shared.appUserType == .agent ? 1 : 0
        params["app_secret_key"] = HippoConfig.shared.appUserType == .agent ? HippoConfig.shared.agentDetail?.appSecrectKey : HippoConfig.shared.appSecretKey
        params["lang"] = getCurrentLanguageLocale()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.getLanguage.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                completion(error as? HippoError, nil)
                return
            }
            guard let apiResponse = responseObject as? [String : Any], let data = apiResponse["data"] as? [String : Any], let response = data["business_data"] as? [String: Any] else {
                return
            }
            if HippoConfig.shared.appUserType == .agent{
              agentParsing(response)
            }else{
              customerParsing(response)
            }
            HippoStrings.updateHippoCallClientStrings()
            completion(error as? HippoError, nil)
        }
    }
    
    class func customerParsing(_ response: [String : Any]){
        if let appGurantee = response["app_guarantee"] as? String{
            
        }
        if let callAgain = response["call_again"] as? String{
            HippoStrings.callAgain = callAgain
        }
        
        if let cancelPayment = response["cancel_payment_text"] as? String{
            HippoStrings.cancelPayment = cancelPayment
        }
        
        if let label_StartChat = response["float_label_start_chat"] as? String{
            
        }
        
        if let label_Actions = response["fugu_agent_actions"] as? String{
            
        }
        
        if let label_Actions = response["fugu_attachment"] as? String{
            
        }
        
        if let audio = response["fugu_audio"] as? String{
            HippoStrings.audio = audio
        }
        if let camera = response["fugu_camera"] as? String{
            HippoStrings.camera = camera
        }
        
        if let cancel = response["fugu_cancel"] as? String{
            HippoStrings.cancel = cancel
        }
        if let connected = response["fugu_connected"] as? String{
            HippoStrings.connected = connected
        }
        if let connecting = response["fugu_connecting"] as? String{
            HippoStrings.connecting = connecting
        }
        if let document = response["fugu_document"] as? String{
            HippoStrings.document = document
        }
        
        if let fileNotFound = response["fugu_file_not_found"] as? String{
            
        }
        
        if let leaveComment = response["fugu_leave_comment"] as? String{
            
        }
        if let error_msg_yellow_bar = response["error_msg_yellow_bar"] as? String{
            HippoStrings.slowInternet = error_msg_yellow_bar
        }
        
        if let loading = response["fugu_loading"] as? String{
            HippoStrings.loading = loading
        }
        
        if let retry = response["fugu_menu_retry"] as? String{
            HippoStrings.retry = retry
        }
        
        if let newConversation = response["fugu_new_conversation"] as? String{
            HippoConfig.shared.strings.newConversation = newConversation
        }
        
        if let noDataFound = response["fugu_no_data_found"] as? String{
            
        }
        
        if let ok = response["fugu_ok"] as? String{
            HippoStrings.ok = ok
        }
        if let payment = response["fugu_payment"] as? String{
            HippoStrings.payment = payment
        }
        if let document = response["fugu_pdf"] as? String{
            HippoStrings.document = document
        }
        if let powered_by = response["fugu_powered_by"] as? String{
            // HippoStrings.powered_by = powered_by
        }
        
        if let send_message = response["fugu_send_message"] as? String{
            HippoStrings.messagePlaceHolderText = send_message
            
        }
        if let show_more = response["fugu_show_more"] as? String{
            
        }
        if let support = response["fugu_support"] as? String{
            HippoStrings.support = support
            
        }
        
        if let tap_to_view = response["fugu_tap_to_view"] as? String{
            
        }
        if let text = response["fugu_text"] as? String{
            
        }
        
        if let title = response["fugu_title"] as? String{
            HippoStrings.title = title
        }
        
        if let cant_connect = response["fugu_unable_to_connect_internet"] as? String{
        }
        
        if let video = response["fugu_video"] as? String{
            HippoStrings.video = video
            
        }
        if let voice = response["fugu_voice"] as? String{
            HippoStrings.voice = voice
            
        }
        if let hippo_activity_image_trans = response["hippo_activity_image_trans"] as? String{
            
        }
        if let hippo_add_an_option = response["hippo_add_an_option"] as? String{
            HippoStrings.addOption = hippo_add_an_option
        }
        if let hippo_alert = response["hippo_alert"] as? String{
            HippoStrings.alert = hippo_alert
        }
        if let hippo_all_agents_busy = response["hippo_all_agents_busy"] as? String{
            
        }
        if let hippo_at = response["hippo_at"] as? String{
            HippoStrings.at = hippo_at
        }
        if let hippo_attachment_file = response["hippo_attachment_file"] as? String{
            
        }
        if let hippo_audio_call = response["hippo_audio_call"] as? String{
            
        }
        if let hippo_broadcast_detail = response["hippo_broadcast_detail"] as? String{
            HippoStrings.broadcastDetails = hippo_broadcast_detail
        }
        if let hippo_browse_other_doc = response["hippo_browse_other_doc"] as? String{
            
        }
        if let hippo_busy_on_call = response["hippo_busy_on_call"] as? String{
            HippoStrings.busyAnotherCall = hippo_busy_on_call
        }
        if let hippo_call = response["hippo_call"] as? String{
            HippoStrings.call = hippo_call
        }
        if let hippo_call_back = response["hippo_call_back"] as? String{
            HippoStrings.callback = hippo_call_back
        }
        if let hippo_call_calling = response["hippo_call_calling"] as? String{
            HippoStrings.calling = hippo_call_calling
        }
        if let hippo_call_declined = response["hippo_call_declined"] as? String{
            HippoStrings.callDeclined = hippo_call_declined
        }
        if let hippo_call_ended = response["hippo_call_ended"] as? String{
            
        }
        if let hippo_call_hungup = response["hippo_call_hungup"] as? String{
            
        }
        if let hippo_call_incoming = response["hippo_call_incoming"] as? String{
            //HippoStrings.incomingCall = hippo_call_incoming
        }
        if let hippo_call_incoming_audio_call = response["hippo_call_incoming_audio_call"] as? String{
            
        }
        if let hippo_call_incoming_video_call = response["hippo_call_incoming_video_call"] as? String{
            
        }
        if let hippo_call_outgoing = response["hippo_call_outgoing"] as? String{
            
        }
        if let hippo_call_rejected = response["hippo_call_rejected"] as? String{
            
        }
        
        if let hippo_calling_connection = response["hippo_calling_connection"] as? String{
            HippoStrings.connectingToMeeting = hippo_calling_connection
        }
        
        if let hippo_establishing_connection = response["hippo_establishing_connection"] as? String{
            HippoStrings.establishingConnection = hippo_establishing_connection
        }
        
        if let hippo_call_ringing = response["hippo_call_ringing"] as? String{
            HippoStrings.ringing = hippo_call_ringing
        }
        if let hippo_call_with = response["hippo_call_with"] as? String{
            
        }
        if let hippo_call_with_you = response["hippo_call_with_you"] as? String{
            
        }
        if let hippo_calling_from_old = response["hippo_calling_from_old"] as? String{
            HippoStrings.callOldSdk = hippo_calling_from_old
        }
        if let hippo_cancel_payment = response["hippo_cancel_payment"] as? String{
            HippoStrings.cancelPaymentTitle = hippo_cancel_payment
        }
        if let hippo_card = response["hippo_card"] as? String{
            
        }
        if let hippo_chat = response["hippo_chat"] as? String{
            
        }
        if let hippo_chat_support = response["hippo_chat_support"] as? String{
            
        }
        if let hippo_chats = response["hippo_chats"] as? String{
            
        }
        if let hippo_clear_all_notification = response["hippo_clear_all_notification"] as? String{
            HippoStrings.clearAll = hippo_clear_all_notification
        }
        if let hippo_copy_to_clipboard = response["hippo_copy_to_clipboard"] as? String{
            
        }
        if let hippo_could_not_send_message = response["hippo_could_not_send_message"] as? String{
            
        }
        if let hippo_country_picker_header = response["hippo_country_picker_header"] as? String{
            
        }
        if let hippo_currency = response["hippo_currency"] as? String{
            HippoStrings.currency = hippo_currency
        }
        if let hippo_current = response["hippo_current"] as? String{
            HippoStrings.ongoing = hippo_current
        }
        if let hippo_customer_missed_a = response["hippo_customer_missed_a"] as? String{
            
        }
        if let hippo_disconnect = response["hippo_disconnect"] as? String{
            
        }
        if let hippo_empty_other_user_unique_keys = response["hippo_empty_other_user_unique_keys"] as? String{
            
        }
        if let hippo_empty_transaction_id = response["hippo_empty_transaction_id"] as? String{
            
        }
        if let hippo_emptymessage = response["hippo_emptymessage"] as? String{
            HippoStrings.enterSomeText = hippo_emptymessage
        }
        if let hippo_enter_number_only = response["hippo_enter_number_only"] as? String{
            
        }
        if let hippo_enter_phone_number = response["hippo_enter_phone_number"] as? String{
            
        }
        if let hippo_enter_title = response["hippo_enter_title"] as? String{
            HippoStrings.enterTitle = hippo_enter_title
        }
        
        if let hippo_enter_valid_email = response["hippo_enter_valid_email"] as? String{
            HippoStrings.enterValidEmail = hippo_enter_valid_email
        }
        if let hippo_enter_valid_phn_no = response["hippo_enter_valid_phn_no"] as? String{
            
        }
        if let hippo_enter_valid_price = response["hippo_enter_valid_price"] as? String{
            
        }
        if let hippo_error_msg_sending = response["hippo_error_msg_sending"] as? String{
            
        }
        if let hippo_error_no_countries_found = response["hippo_error_no_countries_found"] as? String{
            
        }
        if let hippo_feature_no_supported = response["hippo_feature_no_supported"] as? String{
            
        }
        if let hippo_fetching_payment_methods = response["hippo_fetching_payment_methods"] as? String{
            
        }
        if let hippo_field_cant_empty = response["hippo_field_cant_empty"] as? String{
            HippoStrings.requiredField = hippo_field_cant_empty
        }
        if let hippo_file_already_in_queue = response["hippo_file_already_in_queue"] as? String{
            
        }
        if let hippo_file_not_supported = response["hippo_file_not_supported"] as? String{
            
        }
        if let hippo_files = response["hippo_files"] as? String{
            
        }
        if let hippo_fill_pre_field = response["hippo_fill_pre_field"] as? String{
            
        }
        if let hippo_find_an_expert = response["hippo_find_an_expert"] as? String{
            
        }
        if let hippo_free = response["hippo_free"] as? String{
            HippoStrings.free = hippo_free
        }
        if let hippo_grant_permission = response["hippo_grant_permission"] as? String{
            
        }
        if let hippo_history = response["hippo_history"] as? String{
            HippoStrings.chatHistory = hippo_history
        }
        if let hippo_invalid_price = response["hippo_invalid_price"] as? String{
            
        }
        if let hippo_item_description = response["hippo_item_description"] as? String{
            HippoStrings.enterDescription = hippo_item_description
        }
        if let hippo_item_price = response["hippo_item_price"] as? String{
            HippoStrings.enterPrice = hippo_item_price
        }
        if let hippo_large_file = response["hippo_large_file"] as? String{
            
        }
        if let hippo_logout_msg = response["hippo_logout_msg"] as? String{
            HippoStrings.logout = hippo_logout_msg
        }
        if let hippo_message_sucessfully = response["hippo_message_sucessfully"] as? String{
            HippoStrings.hippoDefaultText = hippo_message_sucessfully
        }
        if let hippo_minimum_Multiselection = response["hippo_minimum_Multiselection"] as? String{
            HippoStrings.noMinSelection = hippo_minimum_Multiselection
        }
        if let hippo_missed = response["hippo_missed"] as? String{
            HippoStrings.missed = hippo_missed
        }
        if let hippo_missed_call = response["hippo_missed_call"] as? String{
            
        }
        if let hippo_netbanking = response["hippo_netbanking"] as? String{
            
        }
        if let hippo_no = response["hippo_no"] as? String{
            HippoStrings.no = hippo_no
        }
        if let hippo_no_chat = response["hippo_no_chat"] as? String{
            HippoStrings.noChatStarted = hippo_no_chat
        }
        if let hippo_no_chat_init = response["hippo_no_chat_init"] as? String{
            
        }
        if let hippo_no_internet_connected = response["hippo_no_internet_connected"] as? String{
            HippoStrings.noNetworkConnection = hippo_no_internet_connected
        }
        if let hippo_no_notifications = response["hippo_no_notifications"] as? String{
            HippoStrings.noNotificationFound = hippo_no_notifications
        }
        if let hippo_no_payment_methods = response["hippo_no_payment_methods"] as? String{
            HippoStrings.noPaymentMethod = hippo_no_payment_methods
        }
        if let hippo_nochats = response["hippo_nochats"] as? String{
            HippoStrings.noChatInCatagory = hippo_nochats
        }
        if let hippo_notifications = response["hippo_notifications"] as? String{
            HippoStrings.notifications = hippo_notifications
        }
        if let hippo_notifications_deleted = response["hippo_notifications_deleted"] as? String{
            
        }
        if let hippo_notifications_title = response["hippo_notifications_title"] as? String{
            
        }
        if let hippo_ongoing = response["hippo_ongoing"] as? String{
            HippoStrings.ongoing_call = hippo_ongoing
        }
        if let hippo_paid = response["hippo_paid"] as? String{
            HippoStrings.paymentPaid = hippo_paid
        }
        if let hippo_past = response["hippo_past"] as? String{
            HippoStrings.past = hippo_past
        }
        if let hippo_pay_btnText = response["hippo_pay_btnText"] as? String{
            HippoStrings.Pay = hippo_pay_btnText
        }
        if let hippo_pay_with_netbanking = response["hippo_pay_with_netbanking"] as? String{
            
        }
        if let hippo_pay_with_paymob = response["hippo_pay_with_paymob"] as? String{
            
        }
        if let hippo_pay_with_paytm = response["hippo_pay_with_paytm"] as? String{
            
        }
        if let hippo_pay_with_razorpay = response["hippo_pay_with_razorpay"] as? String{
            
        }
        if let hippo_payfort = response["hippo_payfort"] as? String{
            
        }
        if let hippo_payment_loader = response["hippo_payment_loader"] as? String{
            
        }
        if let hippo_payment_title = response["hippo_payment_title"] as? String{
            HippoStrings.payment = hippo_payment_title
        }
        if let hippo_paytm = response["hippo_paytm"] as? String{
            
        }
        if let hippo_pending = response["hippo_pending"] as? String{
            HippoStrings.paymentPending = hippo_pending
        }
        if let hippo_photo_video_library = response["hippo_photo_video_library"] as? String{
            HippoStrings.photoLibrary = hippo_photo_video_library
        }
        if let hippo_proceed_to_pay = response["hippo_proceed_to_pay"] as? String{
            HippoStrings.proccedToPay = hippo_proceed_to_pay
        }
        if let hippo_rating_review = response["hippo_rating_review"] as? String{
            HippoStrings.ratingReview = hippo_rating_review
        }
        if let hippo_rationale_ask = response["hippo_rationale_ask"] as? String{
            
        }
        if let hippo_rationale_ask_again = response["hippo_rationale_ask_again"] as? String{
            
        }
        if let hippo_read_less = response["hippo_read_less"] as? String{
            HippoStrings.readLess = hippo_read_less
        }
        if let hippo_read_more = response["hippo_read_more"] as? String{
            HippoStrings.readMore = hippo_read_more
        }
        if let hippo_recipients = response["hippo_recipients"] as? String{
            HippoStrings.recipients = hippo_recipients
        }
        if let hippo_request_payment = response["hippo_request_payment"] as? String{
            HippoStrings.requestPayment = hippo_request_payment
        }
        if let hippo_save_plan = response["hippo_save_plan"] as? String{
            HippoStrings.savePlan = hippo_save_plan
        }
        if let hippo_search = response["hippo_search"] as? String{
            
        }
        if let hippo_select_string = response["hippo_select_string"] as? String{
            HippoStrings.selectString = hippo_select_string
        }
        if let hippo_sent_a_msg = response["hippo_sent_a_msg"] as? String{
            HippoStrings.messageSent = hippo_sent_a_msg
        }
        if let hippo_something_went_wrong = response["hippo_something_went_wrong"] as? String{
            HippoStrings.somethingWentWrong = hippo_something_went_wrong
        }
        if let hippo_something_wentwrong = response["hippo_something_wentwrong"] as? String{
            
        }
        if let hippo_something_wrong = response["hippo_something_wrong"] as? String{
            
        }
        if let hippo_storage_permission = response["hippo_storage_permission"] as? String{
            
        }
        if let hippo_stripe = response["hippo_stripe"] as? String{
            
        }
        if let hippo_submit = response["hippo_submit"] as? String{
            HippoStrings.submit = hippo_submit
        }
        if let hippo_tap_to_retry = response["hippo_tap_to_retry"] as? String{
            
        }
        if let hippo_text = response["hippo_text"] as? String{
            
        }
        if let hippo_the = response["hippo_the"] as? String{
            HippoStrings.the = hippo_the
        }
        if let hippo_the_video_call = response["hippo_the_video_call"] as? String{
            
        }
        if let hippo_the_video_call_ended = response["hippo_the_video_call_ended"] as? String{
            
        }
        if let hippo_the_voice_call = response["hippo_the_voice_call"] as? String{
            
        }
        if let hippo_the_voice_call_ended = response["hippo_the_voice_call_ended"] as? String{
            
        }
        if let hippo_title_item_description = response["hippo_title_item_description"] as? String{
            HippoStrings.description = hippo_title_item_description
        }
        if let hippo_title_item_price = response["hippo_title_item_price"] as? String{
            HippoStrings.price = hippo_title_item_price
        }
        if let hippo_today = response["hippo_today"] as? String{
            HippoStrings.today = hippo_today
        }
        if let hippo_total_count = response["hippo_total_count"] as? String{
            HippoStrings.totalPrice = hippo_total_count
        }
        if let hippo_update_plan = response["hippo_update_plan"] as? String{
            HippoStrings.updatePlan = hippo_update_plan
        }
        if let hippo_video = response["hippo_video"] as? String{
            
        }
        if let hippo_with_country_code = response["hippo_with_country_code"] as? String{
        }
        if let hippo_writereview = response["hippo_writereview"] as? String{
            HippoStrings.writeReview = hippo_writereview
        }
        if let hippo_yes = response["hippo_yes"] as? String{
            HippoStrings.yes = hippo_yes
        }
        if let hippo_yes_cancel = response["hippo_yes_cancel"] as? String{
            HippoStrings.yesCancel = hippo_yes_cancel
        }
        if let hippo_yesterday = response["hippo_yesterday"] as? String{
            HippoStrings.yesterday = hippo_yesterday
        }
        if let hippo_you = response["hippo_you"] as? String{
            HippoStrings.you = hippo_you
        }
        if let hippo_you_have_no_chats = response["hippo_you_have_no_chats"] as? String{
            
        }
        if let hippo_you_missed_a = response["hippo_you_missed_a"] as? String{
            
        }
        if let logout = response["logout"] as? String{
            HippoStrings.logoutTitle = logout
        }
        if let talk_to = response["talk_to"] as? String{
            
        }
        if let title_settings_dialog = response["title_settings_dialog"] as? String{
            
        }
        if let unknown_message = response["unknown_message"] as? String{
            HippoStrings.unknownMessage = unknown_message
        }
        if let uploading_in_progress = response["uploading_in_progress"] as? String{
            
        }
        if let vw_all = response["vw_all"] as? String{
            HippoStrings.allAgentsString = vw_all
        }
        if let vw_confirm = response["vw_confirm"] as? String{
            HippoStrings.Done = vw_confirm
        }
        
        if let hippo_call_ended = response["hippo_call_ended"] as? String{
            HippoStrings.callEnded = hippo_call_ended
        }
        
        if let vw_no_photo_app = response["vw_no_photo_app"] as? String{
            
        }
        if let vw_no_video_app = response["vw_no_video_app"] as? String{
            
        }
        if let vw_rationale_storage = response["vw_rationale_storage"] as? String{
            
        }
        if let vw_up_to_max = response["vw_up_to_max"] as? String{
            
        }
        
        if let hippo_secure_payment = response["hippo_secure_payment"] as? String{
            HippoStrings.hippoSecurePayment = hippo_secure_payment
        }
        
        if let PAYMENT_REQUESTED = response["PAYMENT_REQUESTED"] as? String{
            HippoStrings.paymentRequested = PAYMENT_REQUESTED
        }
        
        if let hippo_clear = response["hippo_clear"] as? String{
            HippoStrings.clear = hippo_clear
        }
        
        if let hippo_calling_you = response["hippo_calling_you"] as? String{
            HippoStrings.isCallingYou = hippo_calling_you
        }
        
        if let hippo_select_a_plan = response["hippo_select_a_plan"] as? String{
            HippoStrings.selectaPlan = hippo_select_a_plan
        }
        
        if let hippo_message_not_allow = response["hippo_message_not_allow"] as? String{
            HippoStrings.donotAllowPersonalInfo = hippo_message_not_allow
        }

        if let hippo_Thankyou_Feedback = response["hippo_Thankyou_Feedback"] as? String{
            HippoStrings.thanksForFeedback = hippo_Thankyou_Feedback
        }

        if let hippo_edit_text = response["hippo_edit_text"] as? String{
            HippoStrings.edit = hippo_edit_text
        }
        if let hippo_delete_text = response["hippo_delete_text"] as? String{
            HippoStrings.delete = hippo_delete_text
        }
        if let hippo_edited = response["hippo_edited"] as? String{
            HippoStrings.edited = hippo_edited
        }
        if let hippo_delete_for_everyone = response["hippo_delete_for_everyone"] as? String{
            HippoStrings.deleteForEveryone = hippo_delete_for_everyone
        }
        if let hippo_copy_text = response["hippo_copy_text"] as? String{
            HippoStrings.copy = hippo_copy_text
        }
        if let hippo_delete_this_message = response["hippo_delete_this_message"] as? String{
            HippoStrings.deleteMessagePopup = hippo_delete_this_message
        }
        if let hippo_message_deleted = response["hippo_message_deleted"] as? String{
            HippoStrings.deleteMessage = hippo_message_deleted
        }
    }
    
    class func agentParsing(_ response: [String: Any]){
        if let hippo_message_deleted = response["hippo_message_deleted"] as? String{
            HippoStrings.deleteMessage = hippo_message_deleted
        }
        if let hippo_edit_text = response["hippo_edit_text"] as? String{
            HippoStrings.edit = hippo_edit_text
        }
        if let hippo_delete_text = response["hippo_delete_text"] as? String{
            HippoStrings.delete = hippo_delete_text
        }
        if let hippo_edited = response["hippo_edited"] as? String{
            HippoStrings.edited = hippo_edited
        }
        if let hippo_delete_for_everyone = response["hippo_delete_for_everyone"] as? String{
            HippoStrings.deleteForEveryone = hippo_delete_for_everyone
        }
        if let hippo_copy_text = response["hippo_copy_text"] as? String{
            HippoStrings.copy = hippo_copy_text
        }
        if let hippo_delete_this_message = response["hippo_delete_this_message"] as? String{
            HippoStrings.deleteMessagePopup = hippo_delete_this_message
        }
        if let hippo_message_not_allow = response["hippo_message_not_allow"] as? String{
            HippoStrings.donotAllowPersonalInfo = hippo_message_not_allow
        }
        
        if let hippo_save_plan = response["hippo_save_plan"] as? String{
            HippoStrings.savePlan = hippo_save_plan
        }
        
        if let hippo_pending = response["hippo_pending"] as? String{
            HippoStrings.paymentPending = hippo_pending
        }
        if let hippo_request_payment = response["hippo_request_payment"] as? String{
            HippoStrings.requestPayment = hippo_request_payment
        }
        if let hippo_day_ago = response["hippo_day_ago"] as? String{
            HippoStrings.daysAgo = hippo_day_ago
        }
        if let hippo_call = response["hippo_call"] as? String{
            HippoStrings.call = hippo_call
        }
        if let hippo_imagesaved_title = response["hippo_imagesaved_title"] as? String{
            HippoStrings.saved = hippo_imagesaved_title
        }
        if let hippo_image_saved = response["hippo_image_saved"] as? String{
            HippoStrings.imageSaved = hippo_image_saved
        }
        if let hippo_photo_video_library = response["hippo_photo_video_library"] as? String{
            HippoStrings.photoLibrary = hippo_photo_video_library
        }
        if let FILE_IMAGE = response["FILE_IMAGE"] as? String{
            HippoStrings.sentAPhoto = FILE_IMAGE
        }
        if let FILE_ATTACHMENT = response["FILE_ATTACHMENT"] as? String{
            HippoStrings.sentAFile = FILE_ATTACHMENT
        }
        if let PAYMENT_REQUESTED = response["PAYMENT_REQUESTED"] as? String{
            HippoStrings.paymentRequested = PAYMENT_REQUESTED
        }
        if let ASSIGNED_TO_THEMSELVES = response["ASSIGNED_TO_THEMSELVES"] as? String{
            HippoStrings.assignedToThemselves = ASSIGNED_TO_THEMSELVES
        }
        if let NEW_CHAT_ASSIGNED_TO_YOU = response["NEW_CHAT_ASSIGNED_TO_YOU"] as? String{
            HippoStrings.newChatAssignedToYou = NEW_CHAT_ASSIGNED_TO_YOU
        }
        if let ASSIGNED_CHAT_TO = response["ASSIGNED_CHAT_TO"] as? String{
            HippoStrings.chatAssigned = ASSIGNED_CHAT_TO
        }
        if let CHAT_REOPENED_BY = response["CHAT_REOPENED_BY"] as? String{
            HippoStrings.chatReopenedby = CHAT_REOPENED_BY
        }
        if let CHAT_WAS_AUTO_OPENED = response["CHAT_WAS_AUTO_OPENED"] as? String{
            HippoStrings.chatAutoOpened = CHAT_WAS_AUTO_OPENED
        }
        if let CHAT_WAS_AUTO_CLOSED = response["CHAT_WAS_AUTO_CLOSED"] as? String{
            HippoStrings.chatAutoClosed = CHAT_WAS_AUTO_CLOSED
        }
        if let CHAT_WAS_RE_OPENED = response["CHAT_WAS_RE_OPENED"] as? String{
            HippoStrings.chatReopened = CHAT_WAS_RE_OPENED
        }
        if let CHAT_WAS_CLOSED = response["CHAT_WAS_CLOSED"] as? String{
            HippoStrings.chatClosedBy = CHAT_WAS_CLOSED
        }
        if let WAS_AUTO_ASSIGNED = response["WAS_AUTO_ASSIGNED"] as? String{
            HippoStrings.chatAutoAssigned = WAS_AUTO_ASSIGNED
        }
        if let WAS_FORCE_ASSIGNED = response["WAS_FORCE_ASSIGNED"] as? String{
            HippoStrings.forceAssigned = WAS_FORCE_ASSIGNED
        }
        if let TAGGED = response["TAGGED"] as? String{
            HippoStrings.tagged = TAGGED
        }
        if let MENTIONED_YOU = response["MENTIONED_YOU"] as? String{
            HippoStrings.mentionedYou = MENTIONED_YOU
        }
        if let CALLING_YOU = response["CALLING_YOU"] as? String{
            HippoStrings.isCallingYou = CALLING_YOU
        }
        if let MISSED_CALL_FROM = response["MISSED_CALL_FROM"] as? String{
            HippoStrings.missedCallFrom = MISSED_CALL_FROM
        }
        if let RATING_AND_REVIEW = response["RATING_AND_REVIEW"] as? String{
            HippoStrings.ratingReview = RATING_AND_REVIEW
        }
        if let BOT_SKIPPED_FOR_THIS_SESSION = response["BOT_SKIPPED_FOR_THIS_SESSION"] as? String{
            HippoStrings.botSkipped = BOT_SKIPPED_FOR_THIS_SESSION
        }
        if let NEW_CUSTOMER = response["NEW_CUSTOMER"] as? String{
            HippoStrings.newCustomer = NEW_CUSTOMER
        }
        if let hippo_call_calling = response["hippo_call_calling"] as? String{
            HippoStrings.calling = hippo_call_calling
        }
        if let hippo_call_ringing = response["hippo_call_ringing"] as? String{
            HippoStrings.ringing = hippo_call_ringing
        }
        if let hippo_call_declined = response["hippo_call_declined"] as? String{
            HippoStrings.callDeclined = hippo_call_declined
        }
        if let hippo_busy_on_call = response["hippo_busy_on_call"] as? String{
            HippoStrings.busyAnotherCall = hippo_busy_on_call
        }
        if let closed = response["closed"] as? String{
            HippoStrings.closed = closed
        }
        if let hippo_Reopen_Chat = response["hippo_Reopen_Chat"] as? String{
            HippoStrings.reopenChat = hippo_Reopen_Chat
        }
        if let hello_blank_fragment = response["hello_blank_fragment"] as? String{
            
        }
        
        if let open_conversations = response["open_conversations"] as? String{
            
        }
        
        if let closed_conversations = response["closed_conversations"] as? String{
            
        }
        
        if let fugu_unable_to_connect_internet = response["fugu_unable_to_connect_internet"] as? String{
            
        }
        
        if let fugu_no_internet_connection_retry = response["fugu_no_internet_connection_retry"] as? String{
            
        }
        
        if let hippo_something_wrong_api = response["hippo_something_wrong_api"] as? String{
            
        }
        
        if let fugu_new_conversation = response["fugu_new_conversation"] as? String{
            HippoStrings.newConversation = fugu_new_conversation
        }
        
        if let fugu_new_conversations = response["fugu_new_conversations"] as? String{
            
        }
        
        if let fugu_loading = response["fugu_loading"] as? String{
            HippoStrings.loading = fugu_loading
        }
        
        if let fugu_powered_by = response["fugu_powered_by"] as? String{
            
        }
        
        if let fugu_menu_refresh = response["fugu_menu_refresh"] as? String{
            
        }
        
        if let forgot_password = response["forgot_password"] as? String{
            
        }
        
        if let dont_have_account = response["dont_have_account"] as? String{
            
        }
        
        if let confirmation = response["confirmation"] as? String{
            
        }
        
        if let register_your_business = response["register_your_business"] as? String{
            
        }
        
        if let sign_in = response["sign_in"] as? String{
            
        }
        
        if let sign_up = response["sign_up"] as? String{
            
        }
        
        if let password = response["password"] as? String{
            
        }
        
        if let business_name = response["business_name"] as? String{
            
        }
        
        if let new_password = response["new_password"] as? String{
            
        }
        
        if let old_password = response["old_password"] as? String{
            
        }
        
        if let confirm_password = response["confirm_password"] as? String{
            
        }
        
        if let email_address = response["email_address"] as? String{
            
        }
        
        if let login_to_continue = response["login_to_continue"] as? String{
            
        }
        
        if let err_msg_email = response["err_msg_email"] as? String{
            
        }
        
        if let err_msg_search = response["err_msg_search"] as? String{
            
        }
        
        if let err_msg_password = response["err_msg_password"] as? String{
            
        }
        
        if let err_msg_name = response["err_msg_name"] as? String{
            
        }
        
        if let err_msg_business_name = response["err_msg_business_name"] as? String{
            
        }
        
        if let err_msg_phone = response["err_msg_phone"] as? String{
            
        }
        
        if let err_msg_phone_invalid = response["err_msg_phone_invalid"] as? String{
            
        }
        
        if let forgot_password_desc = response["forgot_password_desc"] as? String{
            
        }
        
        if let done = response["done"] as? String{
            
        }
        
        if let hippo_you = response["hippo_you"] as? String{
            HippoStrings.you = hippo_you
        }
        
        if let hippo_user = response["hippo_user"] as? String{
            
        }
        
        if let details = response["details"] as? String{
            
        }
        
        if let actions = response["actions"] as? String{
            HippoStrings.actions = actions
        }
        
        if let close_conversation = response["close_conversation"] as? String{
            HippoStrings.closeChat = close_conversation
        }
        
        if let assign_conversation = response["assign_conversation"] as? String{
            
        }
        
        if let participants = response["participants"] as? String{
            
        }
        
        if let type_message_only = response["type_message_only"] as? String{
            
        }
        
        if let type_a_message = response["type_a_message"] as? String{
            
        }
        
        if let type_a_normal_message = response["type_a_normal_message"] as? String{
            
        }
        
        if let type_a_internal_note = response["type_a_internal_note"] as? String{
            HippoStrings.privateMessagePlaceHolder = type_a_internal_note
        }
        
        if let reopen_conversation = response["reopen_conversation"] as? String{
            
        }
        
        if let pick_image_from = response["pick_image_from"] as? String{
            
        }
        
        if let camera = response["camera"] as? String{
            HippoStrings.camera = camera
        }
        
        if let gallery = response["gallery"] as? String{
            
        }
        
        if let no_gallery = response["no_gallery"] as? String{
            
        }
        
        if let permission_was_not_granted_text = response["permission_was_not_granted_text"] as? String{
            
        }
        
        if let retry = response["retry"] as? String{
            HippoStrings.retry = retry
        }
        
        if let attachment = response["attachment"] as? String{
            HippoStrings.attachmentImage = attachment
        }
        
        if let send_message = response["send_message"] as? String{
            HippoStrings.messagePlaceHolderText = send_message
        }
        
        if let leave_an_internal_note = response["leave_an_internal_note"] as? String{
            
        }
        
        if let saved_replies = response["saved_replies"] as? String{
            
        }
        
        if let no_conversation_found = response["no_conversation_found"] as? String{
            HippoStrings.noConversationFound = no_conversation_found
        }
        
        if let no_previous_conversation_found = response["no_previous_conversation_found"] as? String{
            
        }
        
        if let we_could_not_found_any_conversation = response["we_could_not_found_any_conversation"] as? String{
            
        }
        
        if let we_could_not_found_previous_conversation = response["we_could_not_found_previous_conversation"] as? String{
            
        }
        
        if let enter_code = response["enter_code"] as? String{
            
        }
        
        if let status = response["status"] as? String{
            HippoStrings.status = status
        }
        
        if let closed_chats = response["closed_chats"] as? String{
            HippoStrings.closedChat = closed_chats
        }
        
        if let open_chats = response["open_chats"] as? String{
            HippoStrings.openChat = open_chats
        }
        
        if let type = response["type"] as? String{
            
        }
        
        if let my_chats = response["my_chats"] as? String{
            HippoStrings.myChats = my_chats
        }
        
        if let unassigned = response["unassigned"] as? String{
            HippoStrings.unassigned = unassigned
        }
        
        if let tagged = response["tagged"] as? String{
            
        }
        
        if let labels = response["labels"] as? String{
            
        }
        
        if let logout_message = response["logout_message"] as? String{
            
        }
        
        if let proceed = response["proceed"] as? String{
            
        }
        
        if let cancel = response["cancel"] as? String{
            HippoStrings.cancel = cancel
        }
        
        if let assign_agent_message = response["assign_agent_message"] as? String{
            HippoStrings.reasignChat = assign_agent_message
        }
        
        if let self_assign_agent_message = response["self_assign_agent_message"] as? String{
            HippoStrings.reasignChatToYou = self_assign_agent_message
        }
        
        if let confirm = response["confirm"] as? String{
            
        }
        
        if let close_chat_message = response["close_chat_message"] as? String{
            HippoStrings.closeChatPopup = close_chat_message
        }
        
        if let close = response["close"] as? String{
            
        }
        
        if let reopen_chat_message = response["reopen_chat_message"] as? String{
            HippoStrings.reopenChatPopup = reopen_chat_message
        }
        
        if let reopen_caps = response["reopen_caps"] as? String{
            
        }
        
        if let logout_caps = response["logout_caps"] as? String{
            
        }
        
        if let logout = response["logout"] as? String{
            
        }
        
        if let tap_to_view = response["tap_to_view"] as? String{
            
        }
        
        if let conversation_closed = response["conversation_closed"] as? String{
            HippoStrings.coversationClosed = conversation_closed
        }
        
        if let conversation_re_opend = response["conversation_re_opend"] as? String{
            HippoStrings.conversationReopened = conversation_re_opend
        }
        
        if let conversation_assigned = response["conversation_assigned"] as? String{
            HippoStrings.conversationAssigned = conversation_assigned
        }
        
        if let tool_tip_filter = response["tool_tip_filter"] as? String{
            
        }
        
        if let analytics = response["analytics"] as? String{
            
        }
        
        if let volume_trends = response["volume_trends"] as? String{
            
        }
        
        if let time_trends = response["time_trends"] as? String{
            
        }
        
        if let agent_wise_trends = response["agent_wise_trends"] as? String{
            
        }
        
        if let support = response["support"] as? String{
            
        }
        
        if let chat_with_fugu = response["chat_with_fugu"] as? String{
            
        }
        
        if let all_chats = response["all_chats"] as? String{
            HippoStrings.allChats = all_chats
        }
        
        if let profile = response["profile"] as? String{
            
        }
        
        if let all_agents = response["all_agents"] as? String{
            
        }
        
        if let all_channels = response["all_channels"] as? String{
            
        }
        
        if let all_tags = response["all_tags"] as? String{
            
        }
        
        if let agents = response["agents"] as? String{
            
        }
        
        if let new_text = response["new_text"] as? String{
            
        }
        
        if let replied = response["replied"] as? String{
            
        }
        
        if let assigned = response["assigned"] as? String{
            
        }
        
        if let apply = response["apply"] as? String{
            HippoStrings.apply = apply
        }
        
        if let date = response["date"] as? String{
            
        }
        
        if let today = response["today"] as? String{
            HippoStrings.today = today
        }
        
        if let yesterday = response["yesterday"] as? String{
            HippoStrings.yesterday = yesterday
        }
        
        if let last_7_days = response["last_7_days"] as? String{
            
        }
        
        if let last_30_days = response["last_30_days"] as? String{
            
        }
        
        if let agent_wise_data = response["agent_wise_data"] as? String{
            
        }
        
        if let avg_resp_time = response["avg_resp_time"] as? String{
            
        }
        
        if let avg_close_time = response["avg_close_time"] as? String{
            
        }
        
        if let avg_response_time = response["avg_response_time"] as? String{
            
        }
        
        if let channels = response["channels"] as? String{
            
        }
        
        if let tags = response["tags"] as? String{
            HippoStrings.tags = tags
        }
        
        if let channel_info = response["channel_info"] as? String{
            HippoStrings.channelInfo = channel_info
        }
        
        if let close_small = response["close_small"] as? String{
            
        }
        
        if let my_analytics = response["my_analytics"] as? String{
            
        }
        
        if let edit_profile = response["edit_profile"] as? String{
            
        }
        
        if let first_visit = response["first_visit"] as? String{
            
        }
        
        if let url = response["url"] as? String{
            
        }
        
        if let device = response["device"] as? String{
            
        }
        
        if let no_of_visits = response["no_of_visits"] as? String{
            
        }
        
        if let last_visit = response["last_visit"] as? String{
            
        }
        
        if let business = response["business"] as? String{
            
        }
        
        if let name = response["name"] as? String{
            
        }
        
        if let name_caps = response["name_caps"] as? String{
            
        }
        
        if let phone_no_caps = response["phone_no_caps"] as? String{
            
        }
        
        if let email_add_caps = response["email_add_caps"] as? String{
            
        }
        
        if let no_of_visitors = response["no_of_visitors"] as? String{
            
        }
        
        if let social_profile = response["social_profile"] as? String{
            
        }
        
        if let past_chats = response["past_chats"] as? String{
            
        }
        
        if let view_more = response["view_more"] as? String{
            
        }
        
        if let shared_images = response["shared_images"] as? String{
            
        }
        
        if let basic_info = response["basic_info"] as? String{
            
        }
        
        if let custom_data = response["custom_data"] as? String{
            
        }
        
        if let reassign_conversation = response["reassign_conversation"] as? String{
            
        }
        
        if let ok = response["ok"] as? String{
            
        }
        
        if let user_info = response["user_info"] as? String{
            
        }
        
        if let info = response["info"] as? String{
            HippoStrings.info = info
        }
        
        if let change_password = response["change_password"] as? String{
            
        }
        
        if let your_profile = response["your_profile"] as? String{
            
        }
        
        if let available = response["available"] as? String{
            
        }
        
        if let offline = response["offline"] as? String{
            
        }
        
        if let away = response["away"] as? String{
            
        }
        
        if let away_message = response["away_message"] as? String{
            
        }
        
        if let updating_conversation = response["updating_conversation"] as? String{
            
        }
        
        if let available_message = response["available_message"] as? String{
            
        }
        
        if let save = response["save"] as? String{
            
        }
        
        if let profile_save_succ = response["profile_save_succ"] as? String{
            
        }
        
        if let pass_save_succ = response["pass_save_succ"] as? String{
            
        }
        
        if let same_pass_err = response["same_pass_err"] as? String{
            
        }
        
        if let empty_msg = response["empty_msg"] as? String{
            HippoStrings.fieldEmpty = empty_msg
        }
     
        
        if let PleaseEnterAddressType = response["PleaseEnterAddressType"] as? String{
            
        }
        
        if let PasswordDoesntMatch = response["PasswordDoesntMatch"] as? String{
            
        }
        
        if let PleaseEnterFirstName = response["PleaseEnterFirstName"] as? String{
            
        }
        
        if let PleaseEnterAddress = response["PleaseEnterAddress"] as? String{
            
        }
        
        if let PleaseEnterDob = response["PleaseEnterDob"] as? String{
            
        }
        
        if let NameThreeCharLong = response["NameThreeCharLong"] as? String{
            
        }
        
        if let NameCannotContainSpecialCharacters = response["NameCannotContainSpecialCharacters"] as? String{
            
        }
        
        if let PleaseEnterLastName = response["PleaseEnterLastName"] as? String{
            
        }
        
        if let LastNameCannotContainSpecialChar = response["LastNameCannotContainSpecialChar"] as? String{
            
        }
        
        if let PleaseEnterEmailId = response["PleaseEnterEmailId"] as? String{
            
        }
        
        if let PleaseEnterValidEmail = response["PleaseEnterValidEmail"] as? String{
            
        }
        
        if let PleaseEnterPassword = response["PleaseEnterPassword"] as? String{
            
        }
        
        if let PasswordContainAtleastSixChar = response["PasswordContainAtleastSixChar"] as? String{
            
        }
        
        if let PleaseEnterPhoneNo = response["PleaseEnterPhoneNo"] as? String{
            
        }
        
        if let PhoneNoCannotStartFromZero = response["PhoneNoCannotStartFromZero"] as? String{
            
        }
        
        if let PhoneLengthAtmostfifteen = response["PhoneLengthAtmostfifteen"] as? String{
            
        }
        
        if let PhoneLengthAtleastSix = response["PhoneLengthAtleastSix"] as? String{
            
        }
        
        if let PleaseEnterValidPhoneNo = response["PleaseEnterValidPhoneNo"] as? String{
            
        }
        
        if let PleaseEnterFourDigitOtp = response["PleaseEnterFourDigitOtp"] as? String{
            
        }
        
        if let PleaseEnterCountryCode = response["PleaseEnterCountryCode"] as? String{
            
        }
        
        if let PleaseEnterValidCountryCode = response["PleaseEnterValidCountryCode"] as? String{
            
        }
        
        if let PleaseSelectYourRole = response["PleaseSelectYourRole"] as? String{
            
        }
        
        if let EmailNotVerified = response["EmailNotVerified"] as? String{
            
        }
        if let PhoneNotVerified = response["PhoneNotVerified"] as? String{
            
        }
        
        if let RefNotVerify = response["RefNotVerify"] as? String{
            
        }
        
        if let PleaseFenceMsg = response["PleaseFenceMsg"] as? String{
            
        }
        
        if let PleaseEnterOtp = response["PleaseEnterOtp"] as? String{
            
        }
        
        if let Search = response["Search"] as? String{
            
        }
        
        if let people = response["people"] as? String{
            
        }
        
        if let custom_attributes = response["custom_attributes"] as? String{
            
        }
        
        if let visitor_info = response["visitor_info"] as? String{
            
        }
        
        if let utm_source = response["utm_source"] as? String{
            
        }
        
        if let utm_medium = response["utm_medium"] as? String{
            
        }
        
        if let utm_product = response["utm_product"] as? String{
            
        }
        
        if let utm_continent_code = response["utm_continent_code"] as? String{
            
        }
        
        if let utm_referrer = response["utm_referrer"] as? String{
            
        }
        
        if let utm_vertical_page = response["utm_vertical_page"] as? String{
            
        }
        
        if let utm_previous_page = response["utm_previous_page"] as? String{
            
        }
        
        if let utm_term = response["utm_term"] as? String{
            
        }
        
        if let utm_web_referrer = response["utm_web_referrer"] as? String{
            
        }
        
        if let utm_old_source = response["utm_old_source"] as? String{
            
        }
        
        if let utm_old_medium = response["utm_old_medium"] as? String{
            
        }
        
        if let utm_gclid = response["utm_gclid"] as? String{
            
        }
        
        if let old_utm_campaign = response["old_utm_campaign"] as? String{
            
        }
        
        if let utm_campaign = response["utm_campaign"] as? String{
            
        }
        
        if let utm_session_ip = response["utm_session_ip"] as? String{
            
        }
        
        if let show_more = response["show_more"] as? String{
            
        }
        
        if let show_less = response["show_less"] as? String{
            
        }
        
        if let day_list = response["day_list"] as? String{
            
        }
        
        if let hippo_feedback_text = response["hippo_feedback_text"] as? String{
            
        }
        
        if let default_feedback_msg = response["default_feedback_msg"] as? String{
            
        }
        
        if let hippo_rating_title = response["hippo_rating_title"] as? String{
            
        }
        
        if let hippo_rating_title_text = response["hippo_rating_title_text"] as? String{
            
        }
        
        if let hippo_thanks = response["hippo_thanks"] as? String{
            
        }
        
        if let hippo_rated_message = response["hippo_rated_message"] as? String{
            HippoStrings.thanksForFeedback = hippo_rated_message
        }
        
        if let feedback_pending = response["feedback_pending"] as? String{
            
        }
        
        if let feedback_popup = response["feedback_popup"] as? String{
            
        }
        
        if let feedback_sent = response["feedback_sent"] as? String{
            
        }
        
        if let terms_of_service = response["terms_of_service"] as? String{
            
        }
        
        if let privacy_policy = response["privacy_policy"] as? String{
            
        }
        
        if let tnc_title = response["tnc_title"] as? String{
            
        }
        
        if let tnc_message = response["tnc_message"] as? String{
            
        }
        
        if let decline = response["decline"] as? String{
            
        }
        
        if let accept = response["accept"] as? String{
            
        }
        
        if let no_bot_found = response["no_bot_found"] as? String{
            
        }
        
        if let next = response["next"] as? String{
            
        }
        
        if let update_profile = response["update_profile"] as? String{
            
        }
        
        
        if let assign_the_deal_to_me = response["assign_the_deal_to_me"] as? String{
            
        }
        
        if let could_not_send_message = response["could_not_send_message"] as? String{
            
        }
        
        if let tap_to_retry = response["tap_to_retry"] as? String{
            
        }
        
        if let no_internet_cancel = response["no_internet_cancel"] as? String{
            
        }
        
        if let load_more = response["load_more"] as? String{
            
        }
        
        if let reset = response["reset"] as? String{
            HippoStrings.reset = reset
        }
        
        if let filter = response["filter"] as? String{
            HippoStrings.filter = filter
        }
        
        if let no_data_found = response["no_data_found"] as? String{
            HippoStrings.noDataFound = no_data_found
        }
        
        if let search_here = response["search_here"] as? String{
            
        }
        
        if let fetching_messages = response["fetching_messages"] as? String{
            
        }
        
        if let video_call = response["video_call"] as? String{
            
        }
        
        if let call_again = response["call_again"] as? String{
             HippoStrings.callAgain = call_again
        }
        
        if let hippo_call_back = response["hippo_call_back"] as? String{
            HippoStrings.callback = hippo_call_back
        }
        
        if let agent_video_call = response["agent_video_call"] as? String{
            
        }
        
        if let fugu_audio = response["fugu_audio"] as? String{
            
        }
        
        if let fugu_document = response["fugu_document"] as? String{
            
        }
        
        if let video = response["video"] as? String{
            
        }
        
        if let no_handler = response["no_handler"] as? String{
            
        }
        
        if let hippo_large_file = response["hippo_large_file"] as? String{
            
        }
        
        if let uploading = response["uploading"] as? String{
            
        }
        
        if let uploading_in_progress = response["uploading_in_progress"] as? String{
            
        }
        
        if let hippo_something_wrong = response["hippo_something_wrong"] as? String{
            HippoStrings.somethingWentWrong = hippo_something_wrong
        }
        
        if let broadcast_text = response["broadcast_text"] as? String{
            
        }
        
        if let broadcast = response["broadcast"] as? String{
            
        }
        
        if let broadcast_history = response["broadcast_history"] as? String{
            
        }
        
        if let recipients = response["recipients"] as? String{
            
        }
        
        if let broadcast_detail = response["broadcast_detail"] as? String{
            HippoStrings.broadcastDetails = broadcast_detail
        }
        
        if let no_broadcast_found = response["no_broadcast_found"] as? String{
            
        }
        
        if let peerchat = response["peerchat"] as? String{
            
        }
        
        if let members = response["members"] as? String{
            
        }
        
        if let close_reason = response["close_reason"] as? String{
            
        }
        
        if let conversation_history = response["conversation_history"] as? String{
            
        }
        
        if let history = response["history"] as? String{
            
        }
        
        if let no_change_found = response["no_change_found"] as? String{
            
        }
        
        if let fugu_pdf = response["fugu_pdf"] as? String{
            HippoStrings.document = fugu_pdf
        }
        
        if let fugu_camera = response["fugu_camera"] as? String{
            HippoStrings.camera = fugu_camera
        }
        
        if let facing_connectivity_issues = response["facing_connectivity_issues"] as? String{
            
        }
        
        if let take_over = response["take_over"] as? String{
            HippoStrings.takeOver = take_over
        }
        
        if let custom_date = response["custom_date"] as? String{
            
        }
        
        if let channel_journey = response["channel_journey"] as? String{
            
        }
        
        if let update = response["update"] as? String{
            
        }
        
        if let title = response["title"] as? String{
            HippoStrings.title = title
        }
        
        if let hippo_enter_title = response["hippo_enter_title"] as? String{
            HippoStrings.enterTitle = hippo_enter_title
        }
        
        if let hippo_title_item_price = response["hippo_title_item_price"] as? String{
            HippoStrings.price = hippo_title_item_price
        }
        
        if let hippo_title_item_description = response["hippo_title_item_description"] as? String{
            HippoStrings.description = hippo_title_item_description
        }
        
        if let hippo_total_count = response["hippo_total_count"] as? String{
            
        }
        
        if let hippo_add_an_option = response["hippo_add_an_option"] as? String{
            HippoStrings.addOption = hippo_add_an_option
        }
        
        if let hippo_request_payment = response["hippo_request_payment"] as? String{
            
        }
        
        if let hippo_item_price = response["hippo_item_price"] as? String{
            HippoStrings.enterPrice = hippo_item_price
        }
        
        if let hippo_item_description = response["hippo_item_description"] as? String{
            HippoStrings.enterDescription = hippo_item_description
        }
        
        if let hippo_currency = response["hippo_currency"] as? String{
            HippoStrings.currency = hippo_currency
        }
        
        if let hippo_search = response["hippo_search"] as? String{
            
        }
        
        if let hippo_no_sim_detected = response["hippo_no_sim_detected"] as? String{
            
        }
        
        if let hippo_error_no_countries_found = response["hippo_error_no_countries_found"] as? String{
            
        }
        
        if let hippo_country_picker_header = response["hippo_country_picker_header"] as? String{
            
        }
        
        if let hippo_send_payment = response["hippo_send_payment"] as? String{
            HippoStrings.sendPayment = hippo_send_payment
        }
        
        if let notes = response["notes"] as? String{
            
        }
        
        if let required = response["required"] as? String{
            
        }
        
        if let add_text_here_text = response["add_text_here_text"] as? String{
            
        }
        
        if let unverified_account = response["unverified_account"] as? String{
            
        }
        
        if let pending_verification = response["pending_verification"] as? String{
            
        }
        
        if let refresh = response["refresh"] as? String{
            
        }
        
        if let hippo_additional_information = response["hippo_additional_information"] as? String{
            
        }
        
        if let hippo_verify = response["hippo_verify"] as? String{
            
        }
        
        if let saved_plan = response["saved_plan"] as? String{
            HippoStrings.savedPlans = saved_plan
        }
        
        if let hippo_plan_title = response["hippo_plan_title"] as? String{
            
        }
        
        if let plan_name = response["plan_name"] as? String{
            HippoStrings.planName = plan_name
        }
        
        if let no_plan_available = response["no_plan_available"] as? String{
            
        }
        
        if let deal_name = response["deal_name"] as? String{
            
        }
        
        if let email = response["email"] as? String{
            HippoStrings.email = email
        }
        
        if let phone = response["phone"] as? String{
            
        }
        
        if let company = response["company"] as? String{
            
        }
        
        if let pipe_line = response["pipe_line"] as? String{
            
        }
        
        if let deal_owner = response["deal_owner"] as? String{
            
        }
        
        if let deal_follow = response["deal_follow"] as? String{
            
        }
        
        if let deal_location = response["deal_location"] as? String{
            
        }
        
        if let add_deal = response["add_deal"] as? String{
            
        }
        
        if let edit_deal = response["edit_deal"] as? String{
            
        }
        
        if let error_msg_yellow_bar = response["error_msg_yellow_bar"] as? String{
            HippoStrings.slowInternet = error_msg_yellow_bar
        }
        
        if let fugu_connecting = response["fugu_connecting"] as? String{
            HippoStrings.connecting = fugu_connecting
        }
        
        if let fugu_connected = response["fugu_connected"] as? String{
            HippoStrings.connected = fugu_connected
        }
        
        if let hippo_support = response["hippo_support"] as? String{
            HippoStrings.support = hippo_support
        }
        
        if let hippo_rating_review = response["hippo_rating_review"] as? String{
            
        }
        
        if let hippo_in_app = response["hippo_in_app"] as? String{
            HippoStrings.inApp = hippo_in_app
        }
        
        if let hippo_sender_name = response["hippo_sender_name"] as? String{
            
        }
        
        if let hippo_date = response["hippo_date"] as? String{
            
        }
        
        if let hippo_title = response["hippo_title"] as? String{
            
        }
        
        if let hippo_message = response["hippo_message"] as? String{
            
        }
        
        if let hippo_fallback_name = response["hippo_fallback_name"] as? String{
            
        }
        
        if let hippo_broadcast_type = response["hippo_broadcast_type"] as? String{
            
        }
        
        if let hippo_channel_info = response["hippo_channel_info"] as? String{
            HippoStrings.channelInfo = hippo_channel_info
        }
        
        if let hippo_no_channel_journey = response["hippo_no_channel_journey"] as? String{
            
        }
        
        if let hippo_no_member_found = response["hippo_no_member_found"] as? String{
            
        }
        
        if let hippo_please_select_valid_date = response["hippo_please_select_valid_date"] as? String{
            
        }
        
        if let hippo_no_user_found = response["hippo_no_user_found"] as? String{
            
        }
        
        if let hippo_from = response["hippo_from"] as? String{
            
        }
        
        if let hippo_to = response["hippo_to"] as? String{
            
        }
        
        if let hippo_update_plan = response["hippo_update_plan"] as? String{
            HippoStrings.updatePlan = hippo_update_plan
        }
        
        if let hippo_add_plan = response["hippo_add_plan"] as? String{
            
        }
        
        if let hippo_payment_request = response["hippo_payment_request"] as? String{
            HippoStrings.paymentRequest = hippo_payment_request
        }
        
        if let hippo_fill_pre_field = response["hippo_fill_pre_field"] as? String{
            
        }
        
        if let hippo_field_cant_empty = response["hippo_field_cant_empty"] as? String{
             HippoStrings.requiredField = hippo_field_cant_empty
        }
        
        if let hippo_invalid_price = response["hippo_invalid_price"] as? String{
            
        }
        
        if let hippo_payment = response["hippo_payment"] as? String{
            HippoStrings.payment = hippo_payment
        }
        
        if let hippo_verify_details = response["hippo_verify_details"] as? String{
            
        }
        
        if let hippo_save_card = response["hippo_save_card"] as? String{
            
        }
        
        if let hippo_delete_this_plan = response["hippo_delete_this_plan"] as? String{
            
        }
        
        if let hippo_yes = response["hippo_yes"] as? String{
            HippoStrings.yes = hippo_yes
        }
        
        if let hippo_no = response["hippo_no"] as? String{
            HippoStrings.no = hippo_no
        }
        
        if let hippo_business = response["hippo_business"] as? String{
            
        }
        
        if let hippo_self = response["hippo_self"] as? String{
            HippoStrings.selfTag = hippo_self
        }
        
        if let hippo_plan_id = response["hippo_plan_id"] as? String{
            HippoStrings.planId = hippo_plan_id
        }
        
        if let hippo_plan_name = response["hippo_plan_name"] as? String{
            HippoStrings.planNameTitle = hippo_plan_name
        }
        
        if let hippo_plan_type = response["hippo_plan_type"] as? String{
            HippoStrings.planOwner = hippo_plan_type
        }
        
        if let hippo_updated_at = response["hippo_updated_at"] as? String{
            HippoStrings.updatedAt = hippo_updated_at
        }
        
        if let file_not_supported = response["file_not_supported"] as? String{
            
        }
        
        if let hippo_revoked = response["hippo_revoked"] as? String{
            
        }
        
        if let hippo_active = response["hippo_active"] as? String{
            
        }
        
        if let hippo_inactive = response["hippo_inactive"] as? String{
            
        }
        
        if let hippo_invited = response["hippo_invited"] as? String{
            
        }
        
        if let hippo_read_at = response["hippo_read_at"] as? String{
            
        }
        
        if let hippo_delivered = response["hippo_delivered"] as? String{
            HippoStrings.delivered = hippo_delivered
        }
        
        if let hippo_paid = response["hippo_paid"] as? String{
            HippoStrings.paymentPaid = hippo_paid
        }
        
        if let hippo_new_chat = response["hippo_new_chat"] as? String{
            
        }
        
        if let hippo_me = response["hippo_me"] as? String{
            HippoStrings.me = hippo_me
        }
        
        if let hippo_na = response["hippo_na"] as? String{
            
        }
        
        if let hippo_no_saved_data_found = response["hippo_no_saved_data_found"] as? String{
            
        }
        
        if let hippo_files = response["hippo_files"] as? String{
            
        }
        
        if let hippo_photos = response["hippo_photos"] as? String{
            
        }
        
        if let hippo_site_visit = response["hippo_site_visit"] as? String{
            
        }
        
        if let hippo_please_select_field = response["hippo_please_select_field"] as? String{
            
        }
        
        if let hippo_send = response["hippo_send"] as? String{
            HippoStrings.sendTitle = hippo_send
        }
        
        if let hippo_copy_text = response["hippo_copy_text"] as? String{
            
        }
        
        if let p2p_chats = response["p2p_chats"] as? String{
            
        }
        
        if let hippo_server_disconnected = response["hippo_server_disconnected"] as? String{
            
        }
        
        if let hippo_server_connecting = response["hippo_server_connecting"] as? String{
            
        }
        
        if let hippo_you_sent_a_payment = response["hippo_you_sent_a_payment"] as? String{
            
        }
        
        if let hippo_sent_a_photo = response["hippo_sent_a_photo"] as? String{
            HippoStrings.sentAPhoto = hippo_sent_a_photo
        }
        
        if let you_receive_a_payment = response["you_receive_a_payment"] as? String{
            
        }
        
        if let hippo_you_received_a_photo = response["hippo_you_received_a_photo"] as? String{
            
        }
        
        if let hippo_sent_a_file = response["hippo_sent_a_file"] as? String{
            HippoStrings.sentAFile = hippo_sent_a_file
        }
        
        if let hippo_voice = response["hippo_voice"] as? String{
            HippoStrings.voice = hippo_voice
        }
        
        if let hippo_customer = response["hippo_customer"] as? String{
            HippoStrings.customer = hippo_customer
        }
        
        if let hippo_call_ended = response["hippo_call_ended"] as? String{
            HippoStrings.callEnded = hippo_call_ended
        }
        
        if let hippo_call_with = response["hippo_call_with"] as? String{
            
        }
        
        if let hippo_missed = response["hippo_missed"] as? String{
            HippoStrings.missed = hippo_missed
        }
        
        if let hippo_the = response["hippo_the"] as? String{
            HippoStrings.the = hippo_the
        }
        
        if let hippo_bot_in_progress = response["hippo_bot_in_progress"] as? String{
            HippoStrings.botInProgress = hippo_bot_in_progress
        }
        
        if let hippo_no_internet_connected = response["hippo_no_internet_connected"] as? String{
            HippoStrings.noNetworkConnection = hippo_no_internet_connected
        }
        
        if let hippo_close_conversation = response["hippo_close_conversation"] as? String{
            
        }
        
        if let hippo_closing_notes = response["hippo_closing_notes"] as? String{
            
        }
        
        if let hippo_conversation_closed = response["hippo_conversation_closed"] as? String{
            
        }
        
        if let hippo_assigned_to = response["hippo_assigned_to"] as? String{
            
        }
        
        if let hippo_assign_conversation = response["hippo_assign_conversation"] as? String{
            HippoStrings.assignConversation = hippo_assign_conversation
        }
        
        if let hippo_internal_notes = response["hippo_internal_notes"] as? String{
            HippoStrings.internalNotes = hippo_internal_notes
        }
        
        if let hippo_text = response["hippo_text"] as? String{
            HippoStrings.text = hippo_text
        }
        
        if let hippo_Bot = response["hippo_Bot"] as? String{
            HippoStrings.bot = hippo_Bot
        }
        
        if let hippo_savePaymentPlan = response["hippo_savePaymentPlan"] as? String{
            HippoStrings.savePaymentPlan = hippo_savePaymentPlan
        }
        
        if let hippo_EditPaymentPlanPopup = response["hippo_EditPaymentPlanPopup"] as? String{
            HippoStrings.editPaymentPlan = hippo_EditPaymentPlanPopup
        }
        
        if let hippo_DeletePaymentPlanPopup = response["hippo_DeletePaymentPlanPopup"] as? String{
            HippoStrings.deletePaymentPlan = hippo_DeletePaymentPlanPopup
        }
        
        if let hippo_send_this_plan = response["hippo_send_this_plan"] as? String{
            HippoStrings.sendPaymentRequestPopup = hippo_send_this_plan
        }
        if let hippo_is_required = response["hippo_is_required"] as? String{
            HippoStrings.isRequired = hippo_is_required
        }
        if let hippo_enter_planname = response["hippo_enter_planname"] as? String{
            HippoStrings.enterPlanName = hippo_enter_planname
        }
        if let hippo_invalid_price = response["hippo_invalid_price"] as? String{
            HippoStrings.invalidPriceAmount = hippo_invalid_price
        }
        if let hippo_takeover_chat = response["hippo_takeover_chat"] as? String{
            HippoStrings.takeOverChat = hippo_takeover_chat
        }
        
        if let video = response["video"] as? String{
            HippoStrings.video = video
        }
        if let hippo_assigned_to = response["hippo_assigned_to"] as? String{
            HippoStrings.assignedTo = hippo_assigned_to
        }
        if let hippo_calling_connection = response["hippo_calling_connection"] as? String{
            HippoStrings.connectingToMeeting = hippo_calling_connection
        }
        
        if let hippo_establishing_connection = response["hippo_establishing_connection"] as? String{
            HippoStrings.establishingConnection = hippo_establishing_connection
        }
        
        if let hippo_emptymessage = response["hippo_emptymessage"] as? String{
            HippoStrings.enterSomeText = hippo_emptymessage
        }
        
    }
    
    class func updateLanguageApi() {
        var params = [String: Any]()
        params["user_id"] = HippoUserDetail.fuguUserID
        params["en_user_id"] = HippoUserDetail.fuguEnUserID
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["update_lang"] = getCurrentLanguageLocale()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.updateLanguage.rawValue) { (responseObject, error, tag, statusCode) in
        }
    }
}
    
    


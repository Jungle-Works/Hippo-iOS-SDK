//
//  AllString.swift
//  Hippo
//
//  Created by Arohi Sharma on 23/06/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation
class AllString{
    
    class func getAllStrings() {
        var params = [String: Any]()
        params["request_source"] = HippoConfig.shared.appUserType == .agent ? 1 : 0
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["lang"] = getCurrentLanguageLocale()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.getLanguage.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                return
            }
            guard let apiResponse = responseObject as? [String : Any], let data = apiResponse["data"] as? [String : Any], let response = data["business_data"] as? [String: Any] else {
                return
            }
            
            if let appGurantee = response["app_guarantee"] as? String{
                
            }
            if let callAgain = response["call_again"] as? String{
                HippoStrings.callAgain = callAgain
            }
            
            if let cancelPayment = response["cancel_payment_text"] as? String{
                         
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
            
            if let loading = response["fugu_loading"] as? String{
                HippoStrings.loading = loading
            }
            
            if let retry = response["fugu_menu_retry"] as? String{
                HippoStrings.retry = retry
            }
            
            if let newConversation = response["fugu_no_conversation_found"] as? String{
               
            }
            
            if let noDataFound = response["fugu_no_data_found"] as? String{
               
            }
            
            if let notConnectedToInternet = response["fugu_not_connected_to_internet"] as? String{
                HippoStrings.noNetworkConnection = notConnectedToInternet
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
            if let retry = response["fugu_retry"] as? String{
                HippoStrings.retry = retry
            }
            if let send_message = response["fugu_send_message"] as? String{
                HippoConfig.shared.strings.messagePlaceHolderText = send_message
                
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
                HippoConfig.shared.strings.calling = hippo_call_calling
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
            if let hippo_no_internet_cancel = response["hippo_no_internet_cancel"] as? String{
                HippoStrings.cancel = hippo_no_internet_cancel
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
            if let hippo_smile_rating_bad = response["hippo_smile_rating_bad"] as? String{
                
            }
            if let hippo_smile_rating_good = response["hippo_smile_rating_good"] as? String{
                
            }
            if let hippo_smile_rating_great = response["hippo_smile_rating_great"] as? String{
                
            }
            if let hippo_smile_rating_okay = response["hippo_smile_rating_okay"] as? String{
               
            }
            if let hippo_smile_rating_terrible = response["hippo_smile_rating_terrible"] as? String{
                
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
            if let vw_no_photo_app = response["vw_no_photo_app"] as? String{
               
            }
            if let vw_no_video_app = response["vw_no_video_app"] as? String{
               
            }
            if let vw_rationale_storage = response["vw_rationale_storage"] as? String{
               
            }
            if let vw_up_to_max = response["vw_up_to_max"] as? String{
               
        
            }
            
        }
    }
    
}

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
        params["lang"] = getCurrentLanguageLocale()
        params["offering"] = HippoConfig.shared.offering
        params["device_type"] =  Device_Type_iOS
    
        if HippoConfig.shared.appUserType == .customer{
            if let enUserID = HippoUserDetail.fuguEnUserID{
                params["en_user_id"] = enUserID
            }

            if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
                if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                    params["user_identification_secret"] = userIdenficationSecret
                }
            }
            
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        
        if HippoConfig.shared.appUserType == .agent{
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }
               
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.getLanguage.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                HippoConfig.shared.log.debug(error ?? "", level: .error)
                completion(error as? HippoError, nil)
                return
            }
            guard let apiResponse = responseObject as? [String : Any], let data = apiResponse["data"] as? [String : Any], let response = data["business_data"] as? [String: Any] else {
                return
            }
            if HippoConfig.shared.appUserType == .agent{
              agentParsing(response)
            }else{
                print(response)
              customerParsing(response)
            }
            HippoStrings.updateHippoCallClientStrings()
            completion(error as? HippoError, nil)
        }
    }
    
    class func customerParsing(_ response: [String : Any]){
        if response["app_guarantee"] is String{
            
        }
        if let callAgain = response["call_again"] as? String{
            HippoStrings.callAgain = callAgain
        }
        
        if let cancelPayment = response["cancel_payment_text"] as? String{
            HippoStrings.cancelPayment = cancelPayment
        }
        
        if response["float_label_start_chat"] is String{
            
        }
        
        if response["fugu_agent_actions"] is String{
            
        }
        
        if response["fugu_attachment"] is String{
            
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
        
        if response["fugu_file_not_found"] is String{
            
        }
        
        if response["fugu_leave_comment"] is String{
            
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
        
        if response["fugu_no_data_found"] is String{
            
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
        if response["fugu_powered_by"] is String{
            // HippoStrings.powered_by = powered_by
        }
        
        if let send_message = response["fugu_send_message"] as? String{
            HippoStrings.messagePlaceHolderText = send_message
            
        }
        if response["fugu_show_more"] is String{
            
        }
        if let support = response["fugu_support"] as? String{
            HippoStrings.support = support
            
        }
        
        if response["fugu_tap_to_view"] is String{
            
        }
        if response["fugu_text"] is String{
            
        }
        
        if let title = response["fugu_title"] as? String{
            HippoStrings.title = title
        }
        
        if response["fugu_unable_to_connect_internet"] is String{
        }
        
        if let video = response["fugu_video"] as? String{
            HippoStrings.video = video
            
        }
        if let voice = response["fugu_voice"] as? String{
            HippoStrings.voice = voice
            
        }
        if response["hippo_activity_image_trans"] is String{
            
        }
        if let hippo_add_an_option = response["hippo_add_an_option"] as? String{
            HippoStrings.addOption = hippo_add_an_option
        }
        if let hippo_alert = response["hippo_alert"] as? String{
            HippoStrings.alert = hippo_alert
        }
        if response["hippo_all_agents_busy"] is String{
            
        }
        if let hippo_at = response["hippo_at"] as? String{
            HippoStrings.at = hippo_at
        }
        if response["hippo_attachment_file"] is String{
            
        }
        if response["hippo_audio_call"] is String{
            
        }
        if let hippo_broadcast_detail = response["hippo_broadcast_detail"] as? String{
            HippoStrings.broadcastDetails = hippo_broadcast_detail
        }
        if response["hippo_browse_other_doc"] is String{
            
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
        if response["hippo_call_ended"] is String{
            
        }
        if response["hippo_call_hungup"] is String{
            
        }
        if response["hippo_call_incoming"] is String{
            //HippoStrings.incomingCall = hippo_call_incoming
        }
        if response["hippo_call_incoming_audio_call"] is String{
            
        }
        if response["hippo_call_incoming_video_call"] is String{
            
        }
        if response["hippo_call_outgoing"] is String{
            
        }
        if response["hippo_call_rejected"] is String{
            
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
        if response["hippo_call_with"] is String{
            
        }
        if response["hippo_call_with_you"] is String{
            
        }
        if let hippo_calling_from_old = response["hippo_calling_from_old"] as? String{
            HippoStrings.callOldSdk = hippo_calling_from_old
        }
        if let hippo_cancel_payment = response["hippo_cancel_payment"] as? String{
            HippoStrings.cancelPaymentTitle = hippo_cancel_payment
        }
        if response["hippo_card"] is String{
            
        }
        if response["hippo_chat"] is String{
            
        }
        if response["hippo_chat_support"] is String{
            
        }
        if response["hippo_chats"] is String{
            
        }
        if let hippo_clear_all_notification = response["hippo_clear_all_notification"] as? String{
            HippoStrings.clearAll = hippo_clear_all_notification
        }
        if response["hippo_copy_to_clipboard"] is String{
            
        }
        if response["hippo_could_not_send_message"] is String{
            
        }
        if response["hippo_country_picker_header"] is String{
            
        }
        if let hippo_currency = response["hippo_currency"] as? String{
            HippoStrings.currency = hippo_currency
        }
        if let hippo_current = response["hippo_current"] as? String{
            HippoStrings.ongoing = hippo_current
        }
        if response["hippo_customer_missed_a"] is String{
            
        }
        if response["hippo_disconnect"] is String{
            
        }
        if response["hippo_empty_other_user_unique_keys"] is String{
            
        }
        if response["hippo_empty_transaction_id"] is String{
            
        }
        if let hippo_emptymessage = response["hippo_emptymessage"] as? String{
            HippoStrings.enterSomeText = hippo_emptymessage
        }
        if response["hippo_enter_number_only"] is String{
            
        }
        if response["hippo_enter_phone_number"] is String{
            
        }
        if let hippo_enter_title = response["hippo_enter_title"] as? String{
            HippoStrings.enterTitle = hippo_enter_title
        }
        
        if let hippo_enter_valid_email = response["hippo_enter_valid_email"] as? String{
            HippoStrings.enterValidEmail = hippo_enter_valid_email
        }
        if response["hippo_enter_valid_phn_no"] is String{
            
        }
        if response["hippo_enter_valid_price"] is String{
            
        }
        if response["hippo_error_msg_sending"] is String{
            
        }
        if response["hippo_error_no_countries_found"] is String{
            
        }
        if response["hippo_feature_no_supported"] is String{
            
        }
        if response["hippo_fetching_payment_methods"] is String{
            
        }
        if let hippo_field_cant_empty = response["hippo_field_cant_empty"] as? String{
            HippoStrings.requiredField = hippo_field_cant_empty
        }
        if response["hippo_file_already_in_queue"] is String{
            
        }
        if response["hippo_file_not_supported"] is String{
            
        }
        if response["hippo_files"] is String{
            
        }
        if response["hippo_fill_pre_field"] is String{
            
        }
        if response["hippo_find_an_expert"] is String{
            
        }
        if let hippo_free = response["hippo_free"] as? String{
            HippoStrings.free = hippo_free
        }
        if response["hippo_grant_permission"] is String{
            
        }
        if let hippo_history = response["hippo_history"] as? String{
            HippoStrings.chatHistory = hippo_history
        }
        if response["hippo_invalid_price"] is String{
            
        }
        if let hippo_item_description = response["hippo_item_description"] as? String{
            HippoStrings.enterDescription = hippo_item_description
        }
        if let hippo_item_price = response["hippo_item_price"] as? String{
            HippoStrings.enterPrice = hippo_item_price
        }
        if response["hippo_large_file"] is String{
            
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
        if response["hippo_missed_call"] is String{
            
        }
        if response["hippo_netbanking"] is String{
            
        }
        if let hippo_no = response["hippo_no"] as? String{
            HippoStrings.no = hippo_no
        }
        if let hippo_no_chat = response["hippo_no_chat"] as? String{
            HippoStrings.noChatStarted = hippo_no_chat
        }
        if response["hippo_no_chat_init"] is String{
            
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
        if response["hippo_notifications_deleted"] is String{
            
        }
        if response["hippo_notifications_title"] is String{
            
        }
        if let hippo_ongoing = response["hippo_ongoing"] as? String{
            HippoStrings.ongoing_call = hippo_ongoing
        }
        if let hippo_shared_media = response["hippo_shared_media"] as? String{
            HippoStrings.sharedMediaTitle = hippo_shared_media
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
        if response["hippo_pay_with_netbanking"] is String{
            
        }
        if response["hippo_pay_with_paymob"] is String{
            
        }
        if response["hippo_pay_with_paytm"] is String{
            
        }
        if response["hippo_pay_with_razorpay"] is String{
            
        }
        if response["hippo_payfort"] is String{
            
        }
        if response["hippo_payment_loader"] is String{
            
        }
        if let hippo_payment_title = response["hippo_payment_title"] as? String{
            HippoStrings.payment = hippo_payment_title
        }
        if response["hippo_paytm"] is String{
            
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
        if response["hippo_rationale_ask"] is String{
            
        }
        if response["hippo_rationale_ask_again"] is String{
            
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
        if response["hippo_search"] is String{
            
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
        if response["hippo_something_wentwrong"] is String{
            
        }
        if response["hippo_something_wrong"] is String{
            
        }
        if response["hippo_storage_permission"] is String{
            
        }
        if response["hippo_stripe"] is String{
            
        }
        if let hippo_submit = response["hippo_submit"] as? String{
            HippoStrings.submit = hippo_submit
        }
        if response["hippo_tap_to_retry"] is String{
            
        }
        if response["hippo_text"] is String{
            
        }
        if let hippo_the = response["hippo_the"] as? String{
            HippoStrings.the = hippo_the
        }
        if response["hippo_the_video_call"] is String{
            
        }
        if response["hippo_the_video_call_ended"] is String{
            
        }
        if response["hippo_the_voice_call"] is String{
            
        }
        if response["hippo_the_voice_call_ended"] is String{
            
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
        if response["hippo_video"] is String{
            
        }
        if response["hippo_with_country_code"] is String{
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
        if response["hippo_you_have_no_chats"] is String{
            
        }
        if response["hippo_you_missed_a"] is String{
            
        }
        if let logout = response["logout"] as? String{
            HippoStrings.logoutTitle = logout
        }
        if response["talk_to"] is String{
            
        }
        if response["title_settings_dialog"] is String{
            
        }
        if let unknown_message = response["unknown_message"] as? String{
            HippoStrings.unknownMessage = unknown_message
        }
        if response["uploading_in_progress"] is String{
            
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
        
        if response["vw_no_photo_app"] is String{
            
        }
        if response["vw_no_video_app"] is String{
            
        }
        if response["vw_rationale_storage"] is String{
            
        }
        if response["vw_up_to_max"] is String{
            
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
        if let hippo_day_ago = response["hippo_days_ago"] as? String{
            HippoStrings.daysAgo = hippo_day_ago
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
        if response["hello_blank_fragment"] is String{
            
        }
        
        if response["open_conversations"] is String{
            
        }
        
        if response["closed_conversations"] is String{
            
        }
        
        if response["fugu_unable_to_connect_internet"] is String{
            
        }
        
        if response["fugu_no_internet_connection_retry"] is String{
            
        }
        
        if response["hippo_something_wrong_api"] is String{
            
        }
        
        if let fugu_new_conversation = response["fugu_new_conversation"] as? String{
            HippoStrings.newConversation = fugu_new_conversation
        }
        
        if response["fugu_new_conversations"] is String{
            
        }
        
        if let fugu_loading = response["fugu_loading"] as? String{
            HippoStrings.loading = fugu_loading
        }
        
        if response["fugu_powered_by"] is String{
            
        }
        
        if response["fugu_menu_refresh"] is String{
            
        }
        
        if response["forgot_password"] is String{
            
        }
        
        if response["dont_have_account"] is String{
            
        }
        
        if response["confirmation"] is String{
            
        }
        
        if response["register_your_business"] is String{
            
        }
        
        if response["sign_in"] is String{
            
        }
        
        if response["sign_up"] is String{
            
        }
        
        if response["password"] is String{
            
        }
        
        if response["business_name"] is String{
            
        }
        
        if response["new_password"] is String{
            
        }
        
        if response["old_password"] is String{
            
        }
        
        if response["confirm_password"] is String{
            
        }
        
        if response["email_address"] is String{
            
        }
        
        if response["login_to_continue"] is String{
            
        }
        
        if response["err_msg_email"] is String{
            
        }
        
        if response["err_msg_search"] is String{
            
        }
        
        if response["err_msg_password"] is String{
            
        }
        
        if response["err_msg_name"] is String{
            
        }
        
        if response["err_msg_business_name"] is String{
            
        }
        
        if response["err_msg_phone"] is String{
            
        }
        
        if response["err_msg_phone_invalid"] is String{
            
        }
        
        if response["forgot_password_desc"] is String{
            
        }
        
        if response["done"] is String{
            
        }
        
        if let hippo_you = response["hippo_you"] as? String{
            HippoStrings.you = hippo_you
        }
        
        if response["hippo_user"] is String{
            
        }
        
        if response["details"] is String{
            
        }
        
        if let actions = response["actions"] as? String{
            HippoStrings.actions = actions
        }
        
        if let close_conversation = response["close_conversation"] as? String{
            HippoStrings.closeChat = close_conversation
        }
        
        if response["assign_conversation"] is String{
            
        }
        
        if response["participants"] is String{
            
        }
        
        if response["type_message_only"] is String{
            
        }
        
        if response["type_a_message"] is String{
            
        }
        
        if response["type_a_normal_message"] is String{
            
        }
        
        if let type_a_internal_note = response["type_a_internal_note"] as? String{
            HippoStrings.privateMessagePlaceHolder = type_a_internal_note
        }
        
        if response["reopen_conversation"] is String{
            
        }
        
        if response["pick_image_from"] is String{
            
        }
        
        if let camera = response["camera"] as? String{
            HippoStrings.camera = camera
        }
        
        if response["gallery"] is String{
            
        }
        
        if response["no_gallery"] is String{
            
        }
        
        if response["permission_was_not_granted_text"] is String{
            
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
        
        if response["leave_an_internal_note"] is String{
            
        }
        
        if response["saved_replies"] is String{
            
        }
        
        if let no_conversation_found = response["no_conversation_found"] as? String{
            HippoStrings.noConversationFound = no_conversation_found
        }
        
        if response["no_previous_conversation_found"] is String{
            
        }
        
        if response["we_could_not_found_any_conversation"] is String{
            
        }
        
        if response["we_could_not_found_previous_conversation"] is String{
            
        }
        
        if response["enter_code"] is String{
            
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
        
        if response["type"] is String{
            
        }
        
        if let my_chats = response["my_chats"] as? String{
            HippoStrings.myChats = my_chats
        }
        
        if let unassigned = response["unassigned"] as? String{
            HippoStrings.unassigned = unassigned
        }
        
        if response["tagged"] is String{
            
        }
        
        if response["labels"] is String{
            
        }
        
        if response["logout_message"] is String{
            
        }
        
        if response["proceed"] is String{
            
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
        
        if response["confirm"] is String{
            
        }
        
        if let close_chat_message = response["close_chat_message"] as? String{
            HippoStrings.closeChatPopup = close_chat_message
        }
        
        if response["close"] is String{
            
        }
        
        if let reopen_chat_message = response["reopen_chat_message"] as? String{
            HippoStrings.reopenChatPopup = reopen_chat_message
        }
        
        if response["reopen_caps"] is String{
            
        }
        
        if response["logout_caps"] is String{
            
        }
        
        if response["logout"] is String{
            
        }
        
        if response["tap_to_view"] is String{
            
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
        
        if response["tool_tip_filter"] is String{
            
        }
        
        if response["analytics"] is String{
            
        }
        
        if response["volume_trends"] is String{
            
        }
        
        if response["time_trends"] is String{
            
        }
        
        if response["agent_wise_trends"] is String{
            
        }
        
        if response["support"] is String{
            
        }
        
        if response["chat_with_fugu"] is String{
            
        }
        
        if let all_chats = response["all_chats"] as? String{
            HippoStrings.allChats = all_chats
        }
        
        if response["profile"] is String{
            
        }
        
        if response["all_agents"] is String{
            
        }
        
        if response["all_channels"] is String{
            
        }
        
        if response["all_tags"] is String{
            
        }
        
        if response["agents"] is String{
            
        }
        
        if response["new_text"] is String{
            
        }
        
        if response["replied"] is String{
            
        }
        
        if response["assigned"] is String{
            
        }
        
        if let apply = response["apply"] as? String{
            HippoStrings.apply = apply
        }
        
        if response["date"] is String{
            
        }
        
        if let today = response["today"] as? String{
            HippoStrings.today = today
        }
        
        if let yesterday = response["yesterday"] as? String{
            HippoStrings.yesterday = yesterday
        }
        
        if response["last_7_days"] is String{
            
        }
        
        if response["last_30_days"] is String{
            
        }
        
        if response["agent_wise_data"] is String{
            
        }
        
        if response["avg_resp_time"] is String{
            
        }
        
        if response["avg_close_time"] is String{
            
        }
        
        if response["avg_response_time"] is String{
            
        }
        
        if response["channels"] is String{
            
        }
        
        if let tags = response["tags"] as? String{
            HippoStrings.tags = tags
        }
        
        if let channel_info = response["channel_info"] as? String{
            HippoStrings.channelInfo = channel_info
        }
        
        if response["close_small"] is String{
            
        }
        
        if response["my_analytics"] is String{
            
        }
        
        if response["edit_profile"] is String{
            
        }
        
        if response["first_visit"] is String{
            
        }
        
        if response["url"] is String{
            
        }
        
        if response["device"] is String{
            
        }
        
        if response["no_of_visits"] is String{
            
        }
        
        if response["last_visit"] is String{
            
        }
        
        if response["business"] is String{
            
        }
        
        if response["name"] is String{
            
        }
        
        if response["name_caps"] is String{
            
        }
        
        if response["phone_no_caps"] is String{
            
        }
        
        if response["email_add_caps"] is String{
            
        }
        
        if response["no_of_visitors"] is String{
            
        }
        
        if response["social_profile"] is String{
            
        }
        
        if response["past_chats"] is String{
            
        }
        
        if response["view_more"] is String{
            
        }
        
        if response["shared_images"] is String{
            
        }
        
        if response["basic_info"] is String{
            
        }
        
        if response["custom_data"] is String{
            
        }
        
        if response["reassign_conversation"] is String{
            
        }
        
        if response["ok"] is String{
            
        }
        
        if response["user_info"] is String{
            
        }
        
        if let info = response["info"] as? String{
            HippoStrings.info = info
        }
        
        if response["change_password"] is String{
            
        }
        
        if response["your_profile"] is String{
            
        }
        
        if response["available"] is String{
            
        }
        
        if response["offline"] is String{
            
        }
        
        if response["away"] is String{
            
        }
        
        if response["away_message"] is String{
            
        }
        
        if response["updating_conversation"] is String{
            
        }
        
        if response["available_message"] is String{
            
        }
        
        if response["save"] is String{
            
        }
        
        if response["profile_save_succ"] is String{
            
        }
        
        if response["pass_save_succ"] is String{
            
        }
        
        if response["same_pass_err"] is String{
            
        }
        
        if let empty_msg = response["empty_msg"] as? String{
            HippoStrings.fieldEmpty = empty_msg
        }
     
        
        if response["PleaseEnterAddressType"] is String{
            
        }
        
        if response["PasswordDoesntMatch"] is String{
            
        }
        
        if response["PleaseEnterFirstName"] is String{
            
        }
        
        if response["PleaseEnterAddress"] is String{
            
        }
        
        if response["PleaseEnterDob"] is String{
            
        }
        
        if response["NameThreeCharLong"] is String{
            
        }
        
        if response["NameCannotContainSpecialCharacters"] is String{
            
        }
        
        if response["PleaseEnterLastName"] is String{
            
        }
        
        if response["LastNameCannotContainSpecialChar"] is String{
            
        }
        
        if response["PleaseEnterEmailId"] is String{
            
        }
        
        if response["PleaseEnterValidEmail"] is String{
            
        }
        
        if response["PleaseEnterPassword"] is String{
            
        }
        
        if response["PasswordContainAtleastSixChar"] is String{
            
        }
        
        if response["PleaseEnterPhoneNo"] is String{
            
        }
        
        if response["PhoneNoCannotStartFromZero"] is String{
            
        }
        
        if response["PhoneLengthAtmostfifteen"] is String{
            
        }
        
        if response["PhoneLengthAtleastSix"] is String{
            
        }
        
        if response["PleaseEnterValidPhoneNo"] is String{
            
        }
        
        if response["PleaseEnterFourDigitOtp"] is String{
            
        }
        
        if response["PleaseEnterCountryCode"] is String{
            
        }
        
        if response["PleaseEnterValidCountryCode"] is String{
            
        }
        
        if response["PleaseSelectYourRole"] is String{
            
        }
        
        if response["EmailNotVerified"] is String{
            
        }
        if response["PhoneNotVerified"] is String{
            
        }
        
        if response["RefNotVerify"] is String{
            
        }
        
        if response["PleaseFenceMsg"] is String{
            
        }
        
        if response["PleaseEnterOtp"] is String{
            
        }
        
        if response["Search"] is String{
            
        }
        
        if response["people"] is String{
            
        }
        
        if response["custom_attributes"] is String{
            
        }
        
        if response["visitor_info"] is String{
            
        }
        
        if response["utm_source"] is String{
            
        }
        
        if response["utm_medium"] is String{
            
        }
        
        if response["utm_product"] is String{
            
        }
        
        if response["utm_continent_code"] is String{
            
        }
        
        if response["utm_referrer"] is String{
            
        }
        
        if response["utm_vertical_page"] is String{
            
        }
        
        if response["utm_previous_page"] is String{
            
        }
        
        if response["utm_term"] is String{
            
        }
        
        if response["utm_web_referrer"] is String{
            
        }
        
        if response["utm_old_source"] is String{
            
        }
        
        if response["utm_old_medium"] is String{
            
        }
        
        if response["utm_gclid"] is String{
            
        }
        
        if response["old_utm_campaign"] is String{
            
        }
        
        if response["utm_campaign"] is String{
            
        }
        
        if response["utm_session_ip"] is String{
            
        }
        
        if response["show_more"] is String{
            
        }
        
        if response["show_less"] is String{
            
        }
        
        if response["day_list"] is String{
            
        }
        
        if response["hippo_feedback_text"] is String{
            
        }
        
        if response["default_feedback_msg"] is String{
            
        }
        
        if response["hippo_rating_title"] is String{
            
        }
        
        if response["hippo_rating_title_text"] is String{
            
        }
        
        if response["hippo_thanks"] is String{
            
        }
        
        if let hippo_rated_message = response["hippo_rated_message"] as? String{
            HippoStrings.thanksForFeedback = hippo_rated_message
        }
        
        if response["feedback_pending"] is String{
            
        }
        
        if response["feedback_popup"] is String{
            
        }
        
        if response["feedback_sent"] is String{
            
        }
        
        if response["terms_of_service"] is String{
            
        }
        
        if response["privacy_policy"] is String{
            
        }
        
        if response["tnc_title"] is String{
            
        }
        
        if response["tnc_message"] is String{
            
        }
        
        if response["decline"] is String{
            
        }
        
        if response["accept"] is String{
            
        }
        
        if response["no_bot_found"] is String{
            
        }
        
        if response["next"] is String{
            
        }
        
        if response["update_profile"] is String{
            
        }
        
        
        if response["assign_the_deal_to_me"] is String{
            
        }
        
        if response["could_not_send_message"] is String{
            
        }
        
        if response["tap_to_retry"] is String{
            
        }
        
        if response["no_internet_cancel"] is String{
            
        }
        
        if response["load_more"] is String{
            
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
        
        if response["search_here"] is String{
            
        }
        
        if response["fetching_messages"] is String{
            
        }
        
        if response["video_call"] is String{
            
        }
        
        if let call_again = response["call_again"] as? String{
             HippoStrings.callAgain = call_again
        }
        
        if let hippo_call_back = response["hippo_call_back"] as? String{
            HippoStrings.callback = hippo_call_back
        }
        
        if response["agent_video_call"] is String{
            
        }
        
        if response["fugu_audio"] is String{
            
        }
        
        if response["fugu_document"] is String{
            
        }
        
        if response["video"] is String{
            
        }
        
        if response["no_handler"] is String{
            
        }
        
        if response["hippo_large_file"] is String{
            
        }
        
        if response["uploading"] is String{
            
        }
        
        if response["uploading_in_progress"] is String{
            
        }
        
        if let hippo_something_wrong = response["hippo_something_wrong"] as? String{
            HippoStrings.somethingWentWrong = hippo_something_wrong
        }
        
        if response["broadcast_text"] is String{
            
        }
        
        if response["broadcast"] is String{
            
        }
        
        if response["broadcast_history"] is String{
            
        }
        
        if response["recipients"] is String{
            
        }
        
        if let broadcast_detail = response["broadcast_detail"] as? String{
            HippoStrings.broadcastDetails = broadcast_detail
        }
        
        if response["no_broadcast_found"] is String{
            
        }
        
        if response["peerchat"] is String{
            
        }
        
        if response["members"] is String{
            
        }
        
        if response["close_reason"] is String{
            
        }
        
        if response["conversation_history"] is String{
            
        }
        
        if response["history"] is String{
            
        }
        
        if response["no_change_found"] is String{
            
        }
        
        if let fugu_pdf = response["fugu_pdf"] as? String{
            HippoStrings.document = fugu_pdf
        }
        
        if let fugu_camera = response["fugu_camera"] as? String{
            HippoStrings.camera = fugu_camera
        }
        
        if response["facing_connectivity_issues"] is String{
            
        }
        
        if let take_over = response["take_over"] as? String{
            HippoStrings.takeOver = take_over
        }
        
        if response["custom_date"] is String{
            
        }
        
        if response["channel_journey"] is String{
            
        }
        
        if response["update"] is String{
            
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
        
        if response["hippo_total_count"] is String{
            
        }
        
        if let hippo_add_an_option = response["hippo_add_an_option"] as? String{
            HippoStrings.addOption = hippo_add_an_option
        }
        
        if response["hippo_request_payment"] is String{
            
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
        
        if response["hippo_search"] is String{
            
        }
        
        if response["hippo_no_sim_detected"] is String{
            
        }
        
        if response["hippo_error_no_countries_found"] is String{
            
        }
        
        if response["hippo_country_picker_header"] is String{
            
        }
        
        if let hippo_send_payment = response["hippo_send_payment"] as? String{
            HippoStrings.sendPayment = hippo_send_payment
        }
        
        if response["notes"] is String{
            
        }
        
        if response["required"] is String{
            
        }
        
        if response["add_text_here_text"] is String{
            
        }
        
        if response["unverified_account"] is String{
            
        }
        
        if response["pending_verification"] is String{
            
        }
        
        if response["refresh"] is String{
            
        }
        
        if response["hippo_additional_information"] is String{
            
        }
        
        if response["hippo_verify"] is String{
            
        }
        
        if let saved_plan = response["saved_plan"] as? String{
            HippoStrings.savedPlans = saved_plan
        }
        
        if response["hippo_plan_title"] is String{
            
        }
        
        if let plan_name = response["plan_name"] as? String{
            HippoStrings.planName = plan_name
        }
        
        if response["no_plan_available"] is String{
            
        }
        
        if response["deal_name"] is String{
            
        }
        
        if let email = response["email"] as? String{
            HippoStrings.email = email
        }
        
        if response["phone"] is String{
            
        }
        
        if response["company"] is String{
            
        }
        
        if response["pipe_line"] is String{
            
        }
        
        if response["deal_owner"] is String{
            
        }
        
        if response["deal_follow"] is String{
            
        }
        
        if response["deal_location"] is String{
            
        }
        
        if response["add_deal"] is String{
            
        }
        
        if response["edit_deal"] is String{
            
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
        
        if response["hippo_rating_review"] is String{
            
        }
        
        if let hippo_in_app = response["hippo_in_app"] as? String{
            HippoStrings.inApp = hippo_in_app
        }
        
        if response["hippo_sender_name"] is String{
            
        }
        
        if response["hippo_date"] is String{
            
        }
        
        if response["hippo_title"] is String{
            
        }
        
        if response["hippo_message"] is String{
            
        }
        
        if response["hippo_fallback_name"] is String{
            
        }
        
        if response["hippo_broadcast_type"] is String{
            
        }
        
        if let hippo_channel_info = response["hippo_channel_info"] as? String{
            HippoStrings.channelInfo = hippo_channel_info
        }
        
        if response["hippo_no_channel_journey"] is String{
            
        }
        
        if response["hippo_no_member_found"] is String{
            
        }
        
        if response["hippo_please_select_valid_date"] is String{
            
        }
        
        if response["hippo_no_user_found"] is String{
            
        }
        
        if response["hippo_from"] is String{
            
        }
        
        if response["hippo_to"] is String{
            
        }
        
        if let hippo_update_plan = response["hippo_update_plan"] as? String{
            HippoStrings.updatePlan = hippo_update_plan
        }
        
        if response["hippo_add_plan"] is String{
            
        }
        
        if let hippo_payment_request = response["hippo_payment_request"] as? String{
            HippoStrings.paymentRequest = hippo_payment_request
        }
        
        if response["hippo_fill_pre_field"] is String{
            
        }
        
        if let hippo_field_cant_empty = response["hippo_field_cant_empty"] as? String{
             HippoStrings.requiredField = hippo_field_cant_empty
        }
        
        if response["hippo_invalid_price"] is String{
            
        }
        
        if let hippo_payment = response["hippo_payment"] as? String{
            HippoStrings.payment = hippo_payment
        }
        
        if response["hippo_verify_details"] is String{
            
        }
        
        if response["hippo_save_card"] is String{
            
        }
        
        if response["hippo_delete_this_plan"] is String{
            
        }
        
        if let hippo_yes = response["hippo_yes"] as? String{
            HippoStrings.yes = hippo_yes
        }
        
        if let hippo_no = response["hippo_no"] as? String{
            HippoStrings.no = hippo_no
        }
        
        if response["hippo_business"] is String{
            
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
        
        if response["file_not_supported"] is String{
            
        }
        
        if response["hippo_revoked"] is String{
            
        }
        
        if response["hippo_active"] is String{
            
        }
        
        if response["hippo_inactive"] is String{
            
        }
        
        if response["hippo_invited"] is String{
            
        }
        
        if response["hippo_read_at"] is String{
            
        }
        
        if let hippo_delivered = response["hippo_delivered"] as? String{
            HippoStrings.delivered = hippo_delivered
        }
        
        if let hippo_paid = response["hippo_paid"] as? String{
            HippoStrings.paymentPaid = hippo_paid
        }
        
        if response["hippo_new_chat"] is String{
            
        }
        
        if let hippo_me = response["hippo_me"] as? String{
            HippoStrings.me = hippo_me
        }
        
        if response["hippo_na"] is String{
            
        }
        
        if response["hippo_no_saved_data_found"] is String{
            
        }
        
        if response["hippo_files"] is String{
            
        }
        
        if response["hippo_photos"] is String{
            
        }
        
        if response["hippo_site_visit"] is String{
            
        }
        
        if response["hippo_please_select_field"] is String{
            
        }
        
        if let hippo_send = response["hippo_send"] as? String{
            HippoStrings.sendTitle = hippo_send
        }
        
        if response["hippo_copy_text"] is String{
            
        }
        
        if response["p2p_chats"] is String{
            
        }
        
        if response["hippo_server_disconnected"] is String{
            
        }
        
        if response["hippo_server_connecting"] is String{
            
        }
        
        if response["hippo_you_sent_a_payment"] is String{
            
        }
        
        if let hippo_sent_a_photo = response["hippo_sent_a_photo"] as? String{
            HippoStrings.sentAPhoto = hippo_sent_a_photo
        }
        
        if response["you_receive_a_payment"] is String{
            
        }
        
        if response["hippo_you_received_a_photo"] is String{
            
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
        
        if response["hippo_call_with"] is String{
            
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
        
        if response["hippo_close_conversation"] is String{
            
        }
        
        if response["hippo_closing_notes"] is String{
            
        }
        
        if response["hippo_conversation_closed"] is String{
            
        }
        
        if response["hippo_assigned_to"] is String{
            
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
        params["en_user_id"] = HippoUserDetail.fuguEnUserID
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["update_lang"] = getCurrentLanguageLocale()
        params["offering"] = HippoConfig.shared.offering
        params["device_type"] =  Device_Type_iOS
        if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
            if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                params["user_identification_secret"] = userIdenficationSecret
            }
        }

        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.updateLanguage.rawValue) { (responseObject, error, tag, statusCode) in
        }
    }
}
    
    


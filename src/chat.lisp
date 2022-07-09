(defpackage #:cl-telegram-bot/chat
  (:use #:cl)
  (:import-from #:cl-telegram-bot/network
                #:make-request)
  (:import-from #:cl-telegram-bot/telegram-call
                #:prepare-arg
                #:def-telegram-call
                #:response)
  (:import-from #:alexandria
                #:ensure-symbol)
  (:export
   #:get-raw-data
   #:get-chat-id
   #:get-username
   #:get-first-name
   #:get-last-name
   #:chat
   #:private-chat
   #:group
   #:supergroup
   #:channel
   #:get-chat-by-id
   #:export-chat-invite-link
   #:promote-chat-member
   #:restrict-chat-member
   #:unban-chat-member
   #:kick-chat-member
   #:set-chat-title
   #:delete-chat-photo
   #:set-chat-photo
   #:set-chat-description
   #:pin-chat-message
   #:unpin-chat-message
   #:leave-chat
   #:get-chat-administrators
   #:get-chat-members-count
   #:get-chat-member
   #:send-chat-action))
(in-package cl-telegram-bot/chat)


(defclass chat ()
  ((id :initarg :id
       :reader get-chat-id)
   (username :initarg :username
             :reader get-username)
   (has-protected-content :initarg :has-protected-content
                          :reader get-has-protected-content)
   (message-auto-delete-time :initarg :message-auto-delete-time
                             :reader get-message-auto-delete-time)
   (raw-data :initarg :raw-data
             :reader get-raw-data)))

(defclass private-chat (chat)
  ((first-name :initarg :first-name
               :reader get-first-name)
   (last-name :initarg :last-name
              :reader get-last-name)
   (bio :initarg :bio
        :reader get-bio)
   (has-private-forwards :initarg :has-private-forwards
                         :reader get-has-private-forwards)))

(defclass base-group (chat)
  ((linked-chat-id :initarg :linked-chat-id
                   :reader get-linked-chat-id)
   (invite-link :initarg :invite-link
                :reader get-invite-link)
   (pinned-message :initarg :pinned-message
                   :reader get-pinned-message)
   (title :initarg :title
          :reader get-title)
   (description :initarg :description
                :reader get-description)))

(defclass group (base-group)
  ())

(defclass super-group (base-group)
  ((join-to-send-messages :initarg :join-to-send-messages
                          :reader get-join-to-send-messages)
   (join-by-request :initarg :join-by-request
                    :reader get-join-by-request)
   (slow-mode-delay :initarg :slow-mode-delay
                    :reader get-slow-mode-delay)
   (sticker-set-name :initarg :sticker-set-name
                     :reader get-sticker-set-name)
   (can-set-sticker-set :initarg :can-set-sticker-set
                        :reader get-can-set-sticker-set)))

(defclass channel (base-group)
  ())

(defun make-chat (data)
  (when data
    (let ((type (getf data :|type|)))
      (apply #'make-instance
             (cond
               ((string-equal type "group") 'group)
               ((string-equal type "supergroup") 'supergroup)
               ((string-equal type "channel") 'channel)
               (t 'private-chat))
             :id (getf data :|id|)
             :username (getf data :|username|)
             :has-protected-content (getf data :|has_protected_contents|)
             :message-auto-delete-time (getf data :|message_auto_delete_time|)
             :raw-data data
             (append
              (when (string-equal type "private")
                (list
                 :has-private-forwards (getf data :|has_private_forwards|)
                 :first-name (getf data :|first_name|)
                 :last-name (getf data :|last_name|)
                 :bio (getf data :|bio|)))
              (unless (string-equal type "private")
                (list :linked-chat-id (getf data :|linked_chat_id|)))
              (when (string-equal type "supergroup")
                (list :join-to-send-messages (getf data :|join_to_send_messages|)
                      :join-by-request (getf data :|join_by_request|)
                      :slow-mode-delay (getf data :|slow_mode_delay|)
                      :sticker-set-name (getf data :|sticker_set_name|)
                      :can-set-sticker-set (getf data :|can_set_sticker_set|))))))))


(defmethod print-object ((chat private-chat) stream)
  (print-unreadable-object
      (chat stream :type t)
    (format stream
            "id=~A username=~A"
            (get-chat-id chat)
            (get-username chat))))


(defmethod prepare-arg ((arg (eql :chat)))
  `(:|chat_id| (get-chat-id
                ,(ensure-symbol arg))))


(def-telegram-call (get-chat-by-id "getChat")
    (chat-id)
  "https://core.telegram.org/bots/api#getchat"
  (make-chat response))


(def-telegram-call kick-chat-member (chat user-id until-date)
  "https://core.telegram.org/bots/api#kickchatmember")


(def-telegram-call unban-chat-member (chat user-id)
  "https://core.telegram.org/bots/api#unbanchatmember")


(def-telegram-call restrict-chat-member (chat
                                         user-id
                                         until-date
                                         can-send-messages
                                         can-send-media-messages
                                         can-send-other-messages
                                         can-add-web-page-previews)
  "https://core.telegram.org/bots/api#restrictchatmember")


(def-telegram-call promote-chat-member (chat
                                        user-id
                                        can-change-info
                                        can-post-messages
                                        can-edit-messages
                                        can-delete-messages
                                        can-invite-users
                                        can-restrict-members
                                        can-pin-messages
                                        can-promote-members)
  "https://core.telegram.org/bots/api#promotechatmember")


(def-telegram-call export-chat-invite-link (chat)
  "https://core.telegram.org/bots/api#exportchatinvitelink")


(def-telegram-call set-chat-photo (chat photo)
  "https://core.telegram.org/bots/api#setchatphoto")


(def-telegram-call delete-chat-photo (chat)
  "https://core.telegram.org/bots/api#deletechatphoto")


(def-telegram-call set-chat-title (chat title)
  "https://core.telegram.org/bots/api#setchattitle")


(def-telegram-call set-chat-description (chat description)
  "https://core.telegram.org/bots/api#setchatdescription")


(def-telegram-call pin-chat-message (chat message-id disable-notification)
  "https://core.telegram.org/bots/api#pinchatmessage")


(def-telegram-call unpin-chat-message (chat)
  "https://core.telegram.org/bots/api#unpinchatmessage")


(def-telegram-call leave-chat (chat)
  "https://core.telegram.org/bots/api#leavechat")


(def-telegram-call get-chat-administrators (chat)
  "https://core.telegram.org/bots/api#getchatadministrators")


(def-telegram-call get-chat-members-count (chat)
  "https://core.telegram.org/bots/api#getchatmemberscount")


(def-telegram-call get-chat-member (chat user-id)
  "https://core.telegram.org/bots/api#getchatmember")


(def-telegram-call send-chat-action (chat action)
  "https://core.telegram.org/bots/api#sendchataction")

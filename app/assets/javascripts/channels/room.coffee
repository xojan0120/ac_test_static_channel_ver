# -----------------------------------------------------------------------------------------------------------------------------
# セレクタ定義
# -----------------------------------------------------------------------------------------------------------------------------
form_selector          = '[data-form]'
content_selector       = '[data-content]'
picture_selector       = '[data-picture]'
send_selector          = '[data-send]'

# -----------------------------------------------------------------------------------------------------------------------------
# 関数定義
# -----------------------------------------------------------------------------------------------------------------------------
clear_form = (selector) ->
  $(selector).find(":text, :file").val("")
  return

get_reader = (file) ->
  reader = new FileReader()
  reader.readAsDataURL(file)
  return reader

speak = ->
  content = $.trim($(content_selector).val())
  picture = $(picture_selector).get(0).files[0]

  has_content = if content.length   >  0          then true else false
  has_picture = if (picture != undefined && picture != null) then true else false

  if has_content || has_picture
    if has_picture
      file_name = picture.name
      reader    = get_reader(picture)
      reader.addEventListener "loadend", ->
        App.room.speak(content, reader.result, file_name)
    else
        App.room.speak(content)

  return

create_subscriptions = (params) ->
  # クライアント側でApp.cable.subscriptions.createが呼ばれると
  # サーバのチャンネルと通信が始まる？
  # paramsはapp/channels/room_channel.rbに渡される。
  # params内のchannelキーの値は、呼び出すapp/channels/room_channel.rbの
  # クラス名と同じでなければいけない。
  App.room = App.cable.subscriptions.create (params),
    connected: ->
      # Called when the subscription is ready for use on the server
  
    disconnected: ->
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      $('#messages').prepend(data['html'])
  
    speak: (content, data_uri, file_name) ->
      @perform('speak', { content: content, data_uri: data_uri, file_name: file_name })
      clear_form(form_selector)

# -----------------------------------------------------------------------------------------------------------------------------
# イベント定義
# -----------------------------------------------------------------------------------------------------------------------------
# channels_room_create_subscriptionsはapp/views/show.html.slimの
# 下部のtriggerメソッド用のカスタムイベントである。
# show.html.slimが読み込まれたらcreate_subscriptionsする。
$(document).on 'channels_room_create_subscriptions', ->
  create_subscriptions({ channel: "RoomChannel" })

$(document).on 'keypress', content_selector, (event) ->
  if event.which is 13 # = Enter
    speak()
    event.preventDefault()
  return

$(document).on 'click', send_selector, (event) ->
  speak()
  event.preventDefault()
  return

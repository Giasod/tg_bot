# frozen_string_literal: true

require 'telegram/bot'
require 'rest-client'
require 'open-uri'
require 'json'

class TelegramBot
  TOKEN = ENV['TELEGRAM_BOT_TOKEN']
  OAUTH_TOKEN = ENV['YANDEX_OAUTH_TOKEN']
  YANDEX_API_URL = 'https://stt.api.cloud.yandex.net/speech/v1/stt:recognize'

  def self.listen
    Telegram::Bot::Client.run(TOKEN) do |bot|
      bot.listen do |message|
        handle_message(message, bot)
      end
    end
  end

  def self.handle_message(message, bot)
    if message.voice
      puts 'Received a voice message.'
      handle_voice(message, bot)
    else
      puts 'Received a non-voice message.'
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'Sorry, I can only process voice messages. Please send me a voice message.')
    end
  rescue StandardError => e
    puts "Error handling message: #{e.message}"
  end

  def self.handle_voice(message, bot)
    voice_file_id = message.voice.file_id

    file_path = bot.api.get_file(file_id: voice_file_id)['result']['file_path']
    voice_file_url = "https://api.telegram.org/file/bot#{TOKEN}/#{file_path}"
    transcription = transcribe_voice(voice_file_url)

    if transcription.nil? || transcription.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'Sorry, I was unable to transcribe your voice message.')
    else
      bot.api.send_message(chat_id: message.chat.id, text: transcription)
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if e.error_code == 400
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'There was a problem processing your voice message. Please try again.')
      puts "Telegram API has returned the error: #{e.message}"
    else
      puts "Error handling voice: #{e.message}"
    end
  rescue StandardError => e
    puts "Unexpected error handling voice: #{e.message}"
  end

  def self.transcribe_voice(voice_file_url)
    iam_token = receive_iam_token
    folder_id = ENV['YANDEX_FOLDER_ID']
    language = 'ru-RU'

    url = "#{YANDEX_API_URL}?folderId=#{folder_id}&lang=#{language}"

    response = RestClient.post(
      url,
      URI.open(voice_file_url).read,
      Authorization: "Bearer #{iam_token}",
      content_type: 'audio/ogg'
    )

    JSON.parse(response.body)['result']
  rescue RestClient::BadRequest
    puts 'Error transcribing voice: 400 Bad Request'
    nil
  rescue StandardError => e
    puts "Unexpected error transcribing voice: #{e.message}"
    nil
  end

  def self.receive_iam_token
    response = RestClient.post(
      'https://iam.api.cloud.yandex.net/iam/v1/tokens',
      { yandexPassportOauthToken: OAUTH_TOKEN }.to_json,
      content_type: :json,
      accept: :json
    )

    JSON.parse(response.body)['iamToken']
  rescue StandardError => e
    puts "Error getting IAM token: #{e.message}"
    nil
  end
end

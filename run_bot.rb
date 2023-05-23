# frozen_string_literal: true

require 'dotenv/load'
require_relative 'app/services/telegram_bot'

TelegramBot.listen

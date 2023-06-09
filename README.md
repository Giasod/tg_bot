# README

### Telegram Voice Message Transcription Bot
This is a Ruby on Rails application that runs a Telegram bot for transcribing voice messages using the Yandex Speech-to-Text API.

## Requirements
* Ruby 3.2.0
* Rails 7.0.4
* A Telegram bot token
* A Yandex OAuth token for the Speech-to-Text API

## Installation
Clone the repository:

`git clone https://github.com/Giasod/tg_bot.git`

Navigate to the project directory:

`cd tg_bot`

Install the dependencies:

`bundle install`


## Configuration
Create a .env file in the root directory of the project and add the following environment variables:

`TELEGRAM_BOT_TOKEN=your_telegram_bot_token`

`YANDEX_OAUTH_TOKEN=your_yandex_oauth_token`

`YANDEX_FOLDER_ID=your_yandex_folder_id`

Replace them with your actual tokens and IDs.

## Running the Bot locally

You can start the bot by running the `run_bot.rb` script:

`ruby run_bot.rb`

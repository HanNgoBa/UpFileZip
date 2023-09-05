# frozen_string_literal: true

require 'faraday'
require 'json'
require 'zip'
require 'htmltoword'
require 'google_drive'
require 'csv'

class UserConnection
  def self.create_new_user(param)
    link_api = Faraday.new(url: 'https://6418014ee038c43f38c45529.mockapi.io') do |faraday|
      faraday.adapter Faraday.default_adapter
    end

    response = link_api.post do |req|
      req.url '/api/v1/users'
      req.headers['Content-Type'] = 'application/json'
      req.body = param.to_json
    end

    JSON.parse(response.body)
  end
end

CSV.foreach('filecsv.csv', headers: true) do |row|
  created_at = row['created_at']
  name = row['name']
  avatar = row['avatar']
  sex = row['sex']
  active = row['active'].downcase == 'true'
  param = {
    name: name,
    sex: sex,
    avatar: avatar,
    created_at: created_at,
    active: active
  }
  UserConnection.create_new_user(param)
end

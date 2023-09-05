# frozen_string_literal: true

require 'faraday'
require 'json'
require 'zip'
require 'htmltoword'
require 'google_drive'

class UserConnection
  def self.user_get
    link_api = Faraday.new(url: 'https://6418014ee038c43f38c45529.mockapi.io') do |item|
      item.adapter Faraday.default_adapter
    end

    reponse = link_api.get('/api/v1/users')

    users = JSON.parse(reponse.body)

    users.select { |item| item['active'] == true }
  end

  def self.export_to_file(users, file_path)
    my_html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
      </head>
      <body>
      <table>
          <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Avatar</th>
          <th>Sex</th>
          <th>Active</th>
          <th>Created At</th>
          </tr>
          #{users.map do |user| # {' '}
            "<tr>
                  <td>#{user['id']}</td>
                  <td>#{user['name']}</td>
                  <td>#{user['avatar']}</td>
                  <td>#{user['sex']}</td>
                  <td>#{user['active']}</td>
                  <td>#{user['created_at']}</td>
              </tr>"
          end.join}
      </table>
      </body>
      </html>
    HTML

    Htmltoword::Document.create_and_save my_html, file_path
  end

  def self.create_zip_file(file_path, zip_file_path)
    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
      zipfile.add(File.basename(file_path), file_path)
    end
  end
end



user_get_true_active = UserConnection.user_get

doc_file_path = '/Users/han/Documents/learn_Ruby/test1/BTVN/rubybt7.doc'
zip_file_path = "/Users/han/Documents/learn_Ruby/test1/BTVN/rubybt7#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"

UserConnection.export_to_file(user_get_true_active, doc_file_path)
UserConnection.create_zip_file(doc_file_path, zip_file_path)

session = GoogleDrive::Session.from_config("config.json")
session.upload_from_file(zip_file_path,"bt9.zip")


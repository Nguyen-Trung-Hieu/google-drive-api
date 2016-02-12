module Google
  FOLDER_MIME = "application/vnd.google-apps.folder"

  class Client
    attr_reader :client, :drive

    def initialize credentials
      @client = build_client credentials
      @drive = build_drive client
    end

    def get_user_info
      oauth2= client.discovered_api "oauth2", "v2"
      result = client.execute! api_method: oauth2.userinfo.get
      if result.status == 200
        result
      else
        false
      end
    end

    def get_files
      client.execute api_method: drive.files.list
    end

    def get_file file_id
      client.execute api_method: drive.files.get, parameters: {fileId: file_id}
    end

    def create_folder folder_name
      folder = drive.files.insert.request_schema.new({
        title: folder_name,
        mimeType: FOLDER_MIME
      })

      client.execute api_method: drive.files.insert, body_object: folder
    end

    def insert_file file_path, title: nil, parent_id: nil, description: nil
      mime_type = MIME::Types.type_for(file_path).first.content_type
      file = drive.files.insert.request_schema.new({
        title: title || File.basename(file_path),
        description: description,
        mimeType: mime_type
      })
      if parent_id
        file.parents = [{id: parent_id}]
      end
      media = Google::APIClient::UploadIO.new file_path, mime_type
      result = client.execute api_method: drive.files.insert,
        body_object: file,
        media: media,
        parameters: {
          uploadType: "multipart",
          alt: "json"
        }
    end

    private
    def build_client credentials
      client = Google::APIClient.new
      client.authorization = credentials
      client
    end

    def build_drive client
      client.discovered_api("drive", "v2")
    end
  end
end
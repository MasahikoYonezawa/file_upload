class ElectronicFilesController < ApplicationController
  
  AWS_ACCESS_KEY_ID = ENV['AWS_S3_ACCESS_KEY_ID']
  AWS_SECRET_KEY = ENV['AWS_S3_SECRET_ACCESS_KEY']
  S3_BUCKET = ENV['S3_BUCKET']
  S3_REGION = ENV['S3_REGION']
  
  def upload
    # アップロード後のファイル名
    # key = "#{Time.zone.now.strftime("%Y-%m-%d_%T")}_#{params[:name]}"
    key = "#{params[:time]}_#{params[:name]}"
    
    acl = 'public-read'
    ctype = params[:content_type]

    # ポリシー作成
    policy_document = {
      # 1分間のみ有効
      expiration: (Time.now + 1.minute).utc,
      conditions: [
        # アップロード先のS3バケット
        { bucket: S3_BUCKET },
        # ファイルの権限
        { acl: acl },
        # ファイル名
        { key: key },
        # ファイルの形式
        { 'Content-Type' => ctype },
        # アップロード可能なファイルのサイズ
        ['content-length-range', params[:size], params[:size]]
      ]
    }.to_json
    policy = Base64.encode64(policy_document).gsub("\n", '')

    # signatureの作成
    signature = Base64.encode64(
        OpenSSL::HMAC.digest(
            OpenSSL::Digest.new('sha1'),
            AWS_SECRET_KEY, policy)).gsub("\n", '')

    # アップロードに必要な情報をJSON形式でクライアントに返す
    render json: {
      url: "https://#{S3_BUCKET}.s3-#{S3_REGION}.amazonaws.com/",
      form: {
        AWSAccessKeyId: AWS_ACCESS_KEY_ID,
        signature: signature,
        policy: policy,
        key: key,
        acl: acl,
        'Content-Type' => ctype
      }
    }
  end
  
  def new
    @file = ElectronicFile.new
    gon.s3_bucket = ENV['S3_BUCKET']
    gon.s3_region = ENV['S3_REGION']
    gon.aws_access_key_id = ENV['AWS_S3_ACCESS_KEY_ID']
    gon.aws_secret_key = ENV['AWS_S3_SECRET_ACCESS_KEY']
  end
  
  def create
    @file = ElectronicFile.new(electronic_file_params)
    if @file.save!
      redirect_to '/electronic_files/new', notice: '保存しました。'
    else
      render :new, alert: '保存に失敗しました。'
    end
  end
  
  private
    
    def electronic_file_params
      params.require(:electronic_file).permit(:path)
    end
end

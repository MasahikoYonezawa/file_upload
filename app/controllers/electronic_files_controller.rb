class ElectronicFilesController < ApplicationController
  require 'aws-sdk'
  require 'byebug'
  require 'uri'
  require 'timers'
  
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
        { bucket: ENV['S3_BUCKET'] },
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
            ENV['AWS_S3_SECRET_ACCESS_KEY'], policy)).gsub("\n", '')

    # アップロードに必要な情報をJSON形式でクライアントに返す
    render json: {
      url: "https://#{ENV['S3_BUCKET']}.s3-#{ENV['S3_REGION']}.amazonaws.com/",
      form: {
        AWSAccessKeyId: ENV['AWS_S3_ACCESS_KEY_ID'],
        signature: signature,
        policy: policy,
        key: key,
        acl: acl,
        'Content-Type' => ctype
      }
    }
  end
  
  def download
    name = params[:name]
    s3 = Aws::S3::Resource.new(region: ENV['S3_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])
    object = bucket.object(name)
    # puts url = URI.parse(object.presigned_url(:get, expires_in: 30))
    # url = object.url_for(:read, :expires => 10*60)
    # p url
    # debugger
    # File.open(object) do |o|
    # IO#each_lineは1行ずつ文字列として読み込み、それを引数にブロックを実行する
    # 第1引数: 行の区切り文字列
    # 第2引数: 最大の読み込みバイト数
    # 読み込み用にオープンされていない場合にIOError
    # file.each_line do |labmen|
    #   # labmenには読み込んだ行が含まれる
    #   puts labmen
    # end
      render :json => {key: object.key}
    # end
    
  end
  
  def copy
    s3 = Aws::S3::Client.new(region: ENV['S3_REGION'])
    s3.copy_object({bucket: ENV['S3_BUCKET2'], copy_source: ENV['S3_BUCKET'] + '/' + params[:key], key: params[:key]})
    
    # 遅延処理後に元オブジェクトを削除
    timers = Timers::Group.new
    timers.after(0.5) {
      s3.delete_object(:bucket => ENV['S3_BUCKET'], :key => params[:key]) 
    }
    timers.wait
  end
  
  def new
    @file = ElectronicFile.new
    gon.s3_bucket = ENV['S3_BUCKET']
    gon.s3_region = ENV['S3_REGION']
    # gon.aws_access_key_id = ENV['AWS_S3_ACCESS_KEY_ID']
    # gon.aws_secret_key = ENV['AWS_S3_SECRET_ACCESS_KEY']
  end
  
  def create
    p electronic_file_params["path"]
    electronic_file_params["path"].gsub!(ENV['S3_BUCKET'], ENV['S3_BUCKET2'])
    p electronic_file_params["path"]
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

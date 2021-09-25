class GenerateQr < ApplicationService
  attr_reader :post
  
  def initialize(post)
    @post = post
  end

  include Rails.application.routes.url_helpers
  
  require "rqrcode"

  def call
    qr_url = url_for(controller: 'posts',
            action: 'show',
            id: post.id,
            only_path: false,
            host: 'superails.com',
            protocol: 'https',
            source: 'from_qr'
            )

    qrcode = RQRCode::QRCode.new(qr_url)

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )

    image_name = SecureRandom.hex

    IO.binwrite("tmp/#{image_name}.png", png.to_s)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: File.open("tmp/#{image_name}.png"),
      filename: image_name,
      content_type: 'png'
    )

    post.qr_code.attach(blob)
  end
end

class Post < ApplicationRecord
  validates :title, presence: true

  has_one_attached :qr_code
  has_one_attached :barcode

  after_create :generate_qr
  def generate_qr
    GenerateQr.call(self)
    GenerateBarcode.call(self)
  end
  
  def to_s
    title
  end
end

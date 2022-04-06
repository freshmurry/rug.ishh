class Review < ApplicationRecord
  belongs_to :rug
  belongs_to :reservation
  belongs_to :guest
  belongs_to :host
end

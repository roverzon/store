class Order < ActiveRecord::Base
  include AASM

  aasm do
    state :order_placed, :initial => true
    state :paid, :after_commit => :pay!
    event :make_payment do 
      transitions :from => :order_placed, :to => :paid
    end

    state :shipping
    event :ship do 
      transitions :form => :paid, :to => :shipping
    end

    state :shipped
    event :deliver do 
      transitions :from => :shipping, :to => :shipped
    end 

    state :order_cancelled
    event :cancell_order do 
      transitions :from => [:order_placed,:paid], :to => :order_cancelled
    end

    state :good_returned
    event :return_good do 
      transitions :form => [:shipped], :to => :good_returned
    end   
  end 

  belongs_to :user
  has_many :items, class_name: "OrderItem", dependent: :destroy
  has_one :info, class_name: "OrderInfo", dependent: :destroy

  accepts_nested_attributes_for :info

  scope :recent, -> { order("id DESC")}

  before_create :generate_token

  include Tokenable

  def calculate_total!(cart)
    self.total = cart.total_price
    self.save
  end

  def build_item_cache_from_cart(cart)
    cart.items.each do |cart_item|
      item = items.build
      item.product_name = cart_item.title
      item.quantity = cart.find_cart_item(cart_item).quantity
      item.price = cart_item.price
      item.save
    end
  end

  def set_payment_with!(method)
    self.update_columns(payment_method: method)
  end

  def pay!
    self.update_columns(is_paid: true)
  end
end

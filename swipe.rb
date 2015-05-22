# A pretty basic abstractor for the Swipe API
# Allows you to set up an adHoc transaction and check for payment
# Quesitons, bugs etc to paul[at]flyingpenguins.co.nz

require 'net/https'

class Swipe
  
  attr_accessor :name, :price, :user_data, :callback_url, :lpn_url, :identifier_id
  
  def initialize(data = {})
    self.name ||= data[:name]
    self.price ||= data[:price]
    self.user_data ||= data[:user_data]
    self.callback_url ||= data[:callback_url]
    self.lpn_url ||= data[:lpn_url]
    
    @api_url ||= "https://api.swipehq.com/"
    @payment_page_url ||= "https://payment.swipehq.com/"
    
    @merchant_id ||= ENV['SWIPE_ID']
    @api_key ||= ENV['SWIPE_API_KEY'] 
    
    self.callback_url ||= ENV['SWIPE_CALLBACK_URL']
    self.lpn_url ||= ENV['SWIPE_LPN_URL']
    
    self #Allows chaining
  end
  
  def identify(extra_data={})
    data = extra_data.merge({td_item: name, td_amount: price, td_user_data: user_data, td_callback_url: callback_url, td_lpn_url: lpn_url})
    
    response = call_api("createTransactionIdentifier.php", data)
    
    if response["response_code"] == 200
      self.identifier_id = response["data"]["identifier"]
      page = @payment_page_url+"?identifier_id="+response["data"]["identifier"]
    else
      raise response["message"]
    end
  end
  
  def accepted?(transaction_id)  
    response = call_api("verifyTransaction.php", {transaction_id: transaction_id})
    response["data"]["transaction_approved"] === 'yes' ? true : false
  end
  
  def self.accepted?(transaction_id)
    Swipe.new.accepted?(transaction_id)
  end
  
  private
  
    def call_api(method, data={})
      data = data.merge({merchant_id: @merchant_id, api_key: @api_key})
      
      url = @api_url+method+"?"+data.to_query
      response = URI.parse(url).read  
      JSON.parse(response)
 
    end
  
end

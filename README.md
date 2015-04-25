# swipe-rails
A pretty basic abstractor in Ruby (on Rails) for the Swipe API modelled on examples visible here: https://www.swipehq.co.nz/tools/

## Who should use this?
This is quick and dirty and is designed to help you out if you don't want to take credit card on your site. If you want take cards on your site and use Swipe as your background processing mechanism go use [ActiveMerchant](https://github.com/Shopify/active_merchant) which supports Swipe. If you want people to input their cards directly on the Swipe screen, but still host your own cart, this might help you.

## Usage Example

1. Grab a copy of swipe.rb and drop it into your `app/models/` or `config/initalizers/` directory.
2. If you don't use [Figaro](https://github.com/laserlemon/figaro) to manage ENV vars, consider doing so, or edit the following lines to suit your needs:

    ```ruby
    @merchant_id ||= ENV['SWIPE_ID']
    @api_key ||= ENV['SWIPE_API_KEY'] 
    
    self.callback_url ||= ENV['SWIPE_CALLBACK_URL']
    self.lpn_url ||= ENV['SWIPE_LPN_URL']
    ```

3. Create yourself a new method that will handle the redirect from your cart to the Swipe payment page, something along the lines of:

    ```ruby
    def swipe
      order_id = Time.now.strftime("%y%m%d%H%M%S")
    
      swipe_params = {
        name: "Order ##{order_id}",
        price: @basket.total_with_shipping,
        user_data: order_id
      }
      @swipe = Swipe.new(swipe_params)
      
      redirect_to @swipe.identify
    end
    ```

4. Create another action that will receive the LPN, something like:

  ```ruby
  def lpn
    unless params[:td_user_data].empty?
      item_id = params[:td_user_data]
      transaction_id = params[:transaction_id]
      if Swipe.accepted?(transaction_id)
        # ... your sales logic
      end
    end
  end
  ```

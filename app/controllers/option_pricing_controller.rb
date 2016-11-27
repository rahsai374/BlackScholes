class OptionPricingController < ApplicationController

  def new
    gon.preference = "hello"
  end

  def calcuate_option_pricing
    diff =  params[:volatality_max].to_f - params[:volatality_min].to_f
    step = diff / 6.0
    volatality = params[:volatality_min].to_f
    @option_price = {}
    6.times do
      volatality+= step 
      price =black_scholes params[:call_put_flag], params[:stock_price].to_f, params[:strike_price].to_f,params[:duration].to_f, params[:interest_rate].to_f, volatality 
      @option_price.merge!({volatality.round(2) => price.round(2)})
    end
    @keys = @option_price.keys
    @keys.unshift('x')
    @values = @option_price.values
    @values.unshift('option-price')
    respond_to do |format|
       format.json {render json: {keys: @keys, values: @values}}
       format.html
    end 
  end

  private
  # Cumulative normal distribution
    def cnd x
      a1, a2, a3, a4, a5 = 0.31938153, -0.356563782, 1.781477937, -1.821255978, 1.330274429
      l = x.abs
      k = 1.0 / (1.0 + 0.2316419 * l)
      w = 1.0 - 1.0 / Math.sqrt(2*Math::PI)*Math.exp(-l*l/2.0) * (a1*k + a2*k*k + a3*(k**3) + a4*(k**4) + a5*(k**5))
      w = 1.0 - w if x < 0
      w
    end

  def black_scholes call_put_flag, s, x, t, r, v 
    d1 = (Math.log(s/x)+(r+v*v/2.0)*t)/(v*Math.sqrt(t))
    d2 = d1-v*Math.sqrt(t)
    if call_put_flag == 'call'
      s*cnd(d1)-x*Math.exp(-r*t)*cnd(d2)
    else
     
      x*Math.exp(-r*t)*cnd(-d2)-s*cnd(-d1)
    end
  end 
end


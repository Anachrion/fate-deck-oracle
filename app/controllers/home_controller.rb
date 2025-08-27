class HomeController < ApplicationController
  
  def index
    # Get values from params if they exist (from redirect)
    @attacker_value = params[:attacker_value]
    @defender_value = params[:defender_value]
    @duel_data = params[:duel_data] 
  end

  def calculate
    attacker_value = params[:attacker_value]&.to_i
    defender_value = params[:defender_value]&.to_i

    result = ::DuelCalculationService
      .new(
        attacker_value: attacker_value,
        defender_value: defender_value
      )
      .call
      
    duel_data = {
      attacker_value:,
      defender_value:,
      result:
    }
    
    # Redirect back to index with the values and result
    redirect_to root_path(
      attacker_value: ,
      defender_value:,
      duel_data:
    )
  end
end

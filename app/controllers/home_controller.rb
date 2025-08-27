class HomeController < ApplicationController
  
  def index
    # Get values from params if they exist (from redirect)
    @attacker_stat = params[:attacker_stat]
    @defender_stat = params[:defender_stat]
    @duel_data = params[:duel_data] 
  end

  def calculate
    attacker_stat = params[:attacker_stat]&.to_i
    defender_stat = params[:defender_stat]&.to_i

    result = ::DuelCalculationService
      .new(
        attacker_stat:,
        defender_stat:
      )
      .call
      
    duel_data = {
      attacker_stat:,
      defender_stat:,
      global_success_rate: result[:global_success_rate],
      global_success_rate_with_raise: result[:global_success_rate_with_raise]
    }
    
    # Redirect back to index with the values and result
    redirect_to root_path(
      attacker_stat: ,
      defender_stat:,
      duel_data:
    )
  end
end

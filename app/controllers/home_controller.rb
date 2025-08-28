# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Get values from params if they exist (from redirect)
    @attacker_stat = params[:attacker_stat]
    @defender_stat = params[:defender_stat]
    @attacker_modifier = params[:attacker_modifier]
    @defender_modifier = params[:defender_modifier]
    @duel_type = params[:duel_type] || "opposed"
    @target_number = params[:target_number] || 0
  end

  def calculate
    # Always read the current form values
    attacker_stat = params[:attacker_stat].presence&.to_i
    defender_stat = params[:defender_stat].presence&.to_i
    target_number = params[:target_number].presence&.to_i
    attacker_flips = params[:attacker_modifier]
    defender_flips = params[:defender_modifier]
    
    result = ::DuelCalculationService
             .new(
               attacker_stat:,
               defender_stat:,
               target_number:,
               attacker_flips:,
               defender_flips:,
             )
             .call

    duel_data = {
      attacker_stat:,
      defender_stat:,
      target_number:,
      global_success_rate: result[:global_success_rate],
      global_success_rate_with_raise: result[:global_success_rate_with_raise]
    }

    # Respond to Turbo requests by rendering turbo_stream
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('results_turbo_frame', partial: 'results', locals: { duel_data: duel_data })
        ]
      end
    end
  end
end

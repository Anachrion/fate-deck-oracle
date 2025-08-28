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
    attacker_stat = params[:attacker_stat]&.to_i
    defender_stat = params[:defender_stat]&.to_i
    attacker_flips = params[:attacker_modifier]
    defender_flips = params[:defender_modifier]
    duel_type = params[:duel_type] || "opposed"

    result = ::DuelCalculationService
             .new(
               attacker_stat: attacker_stat,
               defender_stat: defender_stat,
               attacker_flips: attacker_flips,
               defender_flips: defender_flips,
               duel_type: duel_type,
               target_number: params[:target_number]&.to_i
             )
             .call

    duel_data = {
      attacker_stat: attacker_stat,
      defender_stat: defender_stat,
      duel_type: duel_type,
      target_number: params[:target_number]&.to_i || 0,
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

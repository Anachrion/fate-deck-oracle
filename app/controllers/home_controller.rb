# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Get values from params if they exist (from redirect)
    @attacker_stat = simulation_params[:attacker_stat]
    @defender_stat = simulation_params[:defender_stat]
    @target_number = simulation_params[:target_number]
    @attacker_modifier = simulation_params[:attacker_modifier]
    @defender_modifier = simulation_params[:defender_modifier]
    @duel_type = simulation_params[:duel_type] || 'opposed'
  end

  def calculate
    # Always read the current form values
    duel_type = simulation_params[:duel_type]
    attacker_stat = simulation_params[:attacker_stat].presence&.to_i
    defender_stat = duel_type == 'simple' ? nil : simulation_params[:defender_stat].presence&.to_i
    target_number = duel_type == 'opposed' ? nil : simulation_params[:target_number].presence&.to_i
    attacker_flips = simulation_params[:attacker_modifier]
    defender_flips = simulation_params[:defender_modifier]

    result = ::DuelCalculationService
             .new(
               attacker_stat:,
               defender_stat:,
               target_number:,
               attacker_flips:,
               defender_flips:
             )
             .call

    duel_data = {
      attacker_stat:,
      defender_stat:,
      target_number:,
      attacker_flips:,
      defender_flips:,
      duel_type:,
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

  private

  def simulation_params
    params.permit(
      :attacker_stat,
      :defender_stat,
      :target_number,
      :attacker_modifier,
      :defender_modifier,
      :duel_type
    )
  end
end

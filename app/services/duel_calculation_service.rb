# frozen_string_literal: true

class DuelCalculationService
  FATE_DECK = (1..13).to_a * 4 + [0, 14]

  def initialize(
    attacker_stat:,
    defender_stat: nil,
    target_number: nil,
    attacker_flips: '',
    defender_flips: ''
  )
    @attacker_stat = attacker_stat
    @defender_stat = defender_stat
    @attacker_flips = attacker_flips
    @defender_flips = defender_flips
    @target_number = target_number
  end

  attr_reader :attacker_stat, :defender_stat, :attacker_flips, :defender_flips, :target_number

  def call
    check_consistency_params

    results = defender_stat.nil? ? simple_duel_results : opposed_duel_results

    global_success_rate = ((results.count { |value| value >= 0 } / results.size.to_f) * 100).round
    global_success_rate_with_raise = ((results.count { |value| value >= 5 } / results.size.to_f) * 100).round

    {
      global_success_rate: global_success_rate,
      global_success_rate_with_raise: global_success_rate_with_raise
    }
  end

  def check_consistency_params
    # Check that we have either a defender_stat (opposed duel) or target_number (simple duel)
    raise 'Unknown duel type' if defender_stat.blank? && target_number.blank?

    # Flips are defined as a string , either "++", "+", "", "-" or "--"
    [attacker_flips, defender_flips].each do |flips|
      flip_array = flips.split('')
      raise 'Unknown flip value' if flip_array.any? { |flip| !['+', '-'].include?(flip) }
      raise "You can't mix positive and negative flips" if flip_array.uniq.length > 1
      raise "You can't have more than two flip modifiers" if flip_array.length > 2
    end
  end

  def process_flips(flips:)
    flip_array = flips.split('')
    return [1, nil] if flips.empty?

    [flip_array.length + 1, flip_array.first]
  end

  def simple_duel_results
    attacker_combinations = process_combinations(flips: attacker_flips)

    attacker_combinations.map do |attacker_draw_value|
      # In a simple duel, success is when attacker's total meets or exceeds the target
      (attacker_draw_value + attacker_stat) - target_number
    end
  end

  def opposed_duel_results
    attacker_combinations = process_combinations(flips: attacker_flips)
    defender_combinations = process_combinations(flips: defender_flips)

    results = []

    attacker_combinations.each do |attacker_draw_value|
      defender_combinations.each do |defender_draw_value|
        final_attacker_value = (attacker_draw_value + attacker_stat)
        result = final_attacker_value - (defender_draw_value + defender_stat)
        result = -1 if target_number && final_attacker_value < target_number
        results << result
      end
    end
    results
  end

  def process_combinations(flips:)
    number_of_cards, flip_symbol = process_flips(flips:)

    draw_results = combinations(number_of_cards: number_of_cards)

    draw_results.map do |combination|
      determine_draw_value(cards: combination, flip_symbol: flip_symbol)
    end
  end

  def combinations(number_of_cards:)
    FATE_DECK.combination(number_of_cards).to_a
  end

  def determine_draw_value(cards:, flip_symbol: nil)
    raise 'Inconsistent params' if cards.size > 1 && flip_symbol.nil?

    # If only one card is drawn, return the value of the card
    return cards.first if cards.one?

    # Black joker
    return 0 if cards.include?(0)

    # Red joker
    return 14 if cards.include?(14)

    if flip_symbol == '+'
      cards.max
    elsif flip_symbol == '-'
      cards.min
    end
  end
end

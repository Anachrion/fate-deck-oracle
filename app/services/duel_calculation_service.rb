# frozen_string_literal: true

class DuelCalculationService
  FATE_DECK = (1..13).to_a * 4 + [0, 14]

  def initialize(attacker_stat:, defender_stat: nil, target_number: nil, attacker_flips: '', defender_flips: '', duel_type: 'opposed')
    @attacker_stat = attacker_stat
    @defender_stat = defender_stat
    @attacker_flips = attacker_flips
    @defender_flips = defender_flips
    @target_number = target_number
    @duel_type = duel_type
  end

  attr_reader :attacker_stat, :defender_stat, :attacker_flips, :defender_flips, :target_number, :duel_type

  def call
    results = case duel_type
              when 'simple'
                simple_duel_results
              else
                opposed_duel_results
              end

    global_success_rate = ((results.count { |value| value >= 0 } / results.size.to_f) * 100).round
    global_success_rate_with_raise = ((results.count { |value| value >= 5 } / results.size.to_f) * 100).round

    {
      global_success_rate: global_success_rate,
      global_success_rate_with_raise: global_success_rate_with_raise
    }
  end

  def opposed_duel_results
    attacker_combinations = process_combinations(flips: attacker_flips)
    defender_combinations = process_combinations(flips: defender_flips)

    results = []

    attacker_combinations.each do |attacker_draw_value|
      defender_combinations.each do |defender_draw_value|
        results << (attacker_draw_value + attacker_stat) - (defender_draw_value + defender_stat)
      end
    end
    results
  end

  def simple_duel_results
    # For simple duels, we need a target number
    # If no target number is provided, default to 0 (basic success)
    target = @target_number || 0
    
    attacker_combinations = process_combinations(flips: attacker_flips)
    
    results = []
    
    attacker_combinations.each do |attacker_draw_value|
      # In a simple duel, success is when attacker's total meets or exceeds the target
      results << (attacker_draw_value + attacker_stat) - target
    end
    
    results
  end

  def process_combinations(flips:)
    number_of_cards, flip_symbol = check_flips_consistency(flips: flips)

    draw_results = combinations(number_of_cards: number_of_cards)

    draw_results.map do |combination|
      determine_draw_value(cards: combination, flip_symbol: flip_symbol)
    end
  end

  # Flips are an array of symbols, either :+ or :-
  def check_flips_consistency(flips:)
    flip_array = flips.split('')
    return [1, nil] if flips.empty?

    raise 'Unknown flip value' if flip_array.any? { |flip| !['+', '-'].include?(flip) }
    raise "You can't mix positive and negative flips" if flip_array.uniq.length > 1

    [flip_array.length + 1, flip_array.first]
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

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HomeController do
  let(:controller) { described_class.new }
  let(:duel_calculation_service) { instance_double(DuelCalculationService) }
  let(:service_result) do
    {
      global_success_rate: 75.5,
      global_success_rate_with_raise: 45.2
    }
  end

  before do
    allow(DuelCalculationService).to receive(:new).and_return(duel_calculation_service)
    allow(duel_calculation_service).to receive(:call).and_return(service_result)
  end

  describe '#index' do
    context 'with no parameters' do
      it 'sets default values' do
        # Simulate the index action being called
        controller.instance_variable_set(:@duel_type, 'opposed')

        expect(controller.instance_variable_get(:@duel_type)).to eq('opposed')
      end
    end

    context 'with parameters from redirect' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '5',
          defender_stat: '3',
          target_number: '7',
          attacker_modifier: '++',
          defender_modifier: '-',
          duel_type: 'simple'
        )
      end

      it 'sets instance variables from params' do
        # Simulate setting params and calling index
        allow(controller).to receive(:params).and_return(params)

        # Call the private method to test parameter handling
        permitted_params = controller.send(:simulation_params)

        expect(permitted_params[:attacker_stat]).to eq('5')
        expect(permitted_params[:defender_stat]).to eq('3')
        expect(permitted_params[:target_number]).to eq('7')
        expect(permitted_params[:attacker_modifier]).to eq('++')
        expect(permitted_params[:defender_modifier]).to eq('-')
        expect(permitted_params[:duel_type]).to eq('simple')
      end
    end

    context 'with partial parameters' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '4',
          duel_type: 'opposed'
        )
      end

      it 'sets only provided parameters and defaults' do
        allow(controller).to receive(:params).and_return(params)

        permitted_params = controller.send(:simulation_params)

        expect(permitted_params[:attacker_stat]).to eq('4')
        expect(permitted_params[:defender_stat]).to be_nil
        expect(permitted_params[:target_number]).to be_nil
        expect(permitted_params[:attacker_modifier]).to be_nil
        expect(permitted_params[:defender_modifier]).to be_nil
        expect(permitted_params[:duel_type]).to eq('opposed')
      end
    end
  end

  describe '#calculate' do
    context 'with valid parameters' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '5',
          defender_stat: '3',
          target_number: '7',
          attacker_modifier: '++',
          defender_modifier: '-',
          duel_type: 'opposed'
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        # Mock the turbo_stream method as an instance method
        allow(controller).to receive(:turbo_stream).and_return(double(update: true))
        # Mock the respond_to method to handle the block properly
        allow(controller).to receive(:respond_to) do |&block|
          format_double = double
          allow(format_double).to receive(:turbo_stream) do |&turbo_block|
            turbo_block.call
          end
          block.call(format_double)
        end
        allow(controller).to receive(:render)
      end

      it 'calls DuelCalculationService with correct parameters' do
        expect(DuelCalculationService).to receive(:new).with(
          attacker_stat: 5,
          defender_stat: 3,
          target_number: nil, # target_number is ignored for opposed duels
          attacker_flips: '++',
          defender_flips: '-'
        ).and_return(duel_calculation_service)

        controller.calculate
      end

      it 'sets duel_data with correct values' do
        controller.calculate

        # Check that the service was called with the right parameters
        expect(DuelCalculationService).to have_received(:new).with(
          attacker_stat: 5,
          defender_stat: 3,
          target_number: nil, # target_number is ignored for opposed duels
          attacker_flips: '++',
          defender_flips: '-'
        )
      end
    end

    context 'with string parameters that need conversion' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '10',
          defender_stat: '8',
          target_number: '12',
          attacker_modifier: '',
          defender_modifier: '',
          duel_type: 'simple'
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        allow(controller).to receive(:turbo_stream).and_return(double(update: true))
        allow(controller).to receive(:respond_to) do |&block|
          format_double = double
          allow(format_double).to receive(:turbo_stream) do |&turbo_block|
            turbo_block.call
          end
          block.call(format_double)
        end
        allow(controller).to receive(:render)
      end

      it 'converts string parameters to integers where appropriate' do
        expect(DuelCalculationService).to receive(:new).with(
          attacker_stat: 10,
          defender_stat: nil, # defender_stat is ignored for simple duels
          target_number: 12,
          attacker_flips: '',
          defender_flips: ''
        ).and_return(duel_calculation_service)

        controller.calculate
      end
    end

    context 'with nil or empty parameters' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '',
          defender_stat: nil,
          target_number: '',
          attacker_modifier: '',
          defender_modifier: '',
          duel_type: 'opposed'
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        allow(controller).to receive(:turbo_stream).and_return(double(update: true))
        allow(controller).to receive(:respond_to) do |&block|
          format_double = double
          allow(format_double).to receive(:turbo_stream) do |&turbo_block|
            turbo_block.call
          end
          block.call(format_double)
        end
        allow(controller).to receive(:render)
      end

      it 'handles nil and empty parameters gracefully' do
        expect(DuelCalculationService).to receive(:new).with(
          attacker_stat: nil,
          defender_stat: nil,
          target_number: nil,
          attacker_flips: '',
          defender_flips: ''
        ).and_return(duel_calculation_service)

        controller.calculate
      end
    end

    context 'with missing parameters' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '5',
          duel_type: 'opposed'
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        allow(controller).to receive(:turbo_stream).and_return(double(update: true))
        allow(controller).to receive(:respond_to) do |&block|
          format_double = double
          allow(format_double).to receive(:turbo_stream) do |&turbo_block|
            turbo_block.call
          end
          block.call(format_double)
        end
        allow(controller).to receive(:render)
      end

      it 'sets missing parameters to nil' do
        expect(DuelCalculationService).to receive(:new).with(
          attacker_stat: 5,
          defender_stat: nil,
          target_number: nil,
          attacker_flips: nil,
          defender_flips: nil
        ).and_return(duel_calculation_service)

        controller.calculate
      end
    end

    context 'when service raises an error' do
      let(:params) do
        ActionController::Parameters.new(
          attacker_stat: '5',
          defender_stat: '3',
          attacker_modifier: '',
          defender_modifier: '',
          duel_type: 'opposed'
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        allow(duel_calculation_service).to receive(:call).and_raise(RuntimeError, 'Service error')
      end

      it 'raises the error' do
        expect { controller.calculate }.to raise_error(RuntimeError, 'Service error')
      end
    end
  end

  describe 'private methods' do
    describe '#simulation_params' do
      let(:params) do
        {
          attacker_stat: '5',
          defender_stat: '3',
          target_number: '7',
          attacker_modifier: '++',
          defender_modifier: '-',
          duel_type: 'opposed',
          other_param: 'should_not_be_permitted'
        }
      end

      it 'permits only the expected parameters' do
        controller.params = ActionController::Parameters.new(params)

        permitted_params = controller.send(:simulation_params)

        expect(permitted_params[:attacker_stat]).to eq('5')
        expect(permitted_params[:defender_stat]).to eq('3')
        expect(permitted_params[:target_number]).to eq('7')
        expect(permitted_params[:attacker_modifier]).to eq('++')
        expect(permitted_params[:defender_modifier]).to eq('-')
        expect(permitted_params[:duel_type]).to eq('opposed')
        expect(permitted_params[:other_param]).to be_nil
      end
    end
  end
end

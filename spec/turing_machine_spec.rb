# frozen_string_literal: true

require 'spec_helper'
require_relative '../turing_machine'

RSpec.describe TuringMachine do
  subject(:turing_machine) do
    TuringMachine.new(
      tape: tape,
      starting_state: starting_state,
      accepting_states: accepting_states,
      step_instructions: step_instructions
    )
  end

  describe 'suffix "ab"' do
    let(:starting_state) { 'q0' }
    let(:accepting_states) { ['q3'] }

    # ensure tape is long enough
    let(:tape) { %w[f a b] }
    let(:step_instructions) do
      [
        'q0,a,a,R,q1',
        'q0,f,f,R,q0',
        'q0,b,b,R,q0',
        'q1,b,b,R,q2',
        'q1,a,a,R,q0',
        'q1,f,f,R,q0',
        'q2,_,_,R,q3',
        'q2,a,a,R,q0',
        'q2,b,b,R,q0',
        'q2,f,f,R,q0'
      ]
    end

    it 'runs' do
      _, status = turing_machine.run
      expect(status).to eq :accepted
    end

    context 'with "fabb" as suffix' do
      let(:tape) { %w[f a b b] }

      it 'runs' do
        _, status = turing_machine.run
        expect(status).to eq :rejected
      end
    end
  end

  describe 'multiplication' do
    let(:starting_state) { 'q0' }
    let(:accepting_states) { ['q4'] }

    # ensure tape is long enough
    let(:tape) { ['0'] * a + ['1'] + ['0'] * b }
    # current_state, tape_char, replace, move_to, new_state
    let(:step_instructions) do
      [
        'q0,0,0,R,q0',
        'q0,1,1,R,q0',
        'q0,_,=,L,q1',
        'q1,0,0,L,q1',
        'q1,1,1,L,q1',
        'q1,_,_,R,q2',
        'q2,1,_,R,q3',
        'q2,0,_,R,q5',
        'q3,0,_,R,q3',
        'q3,=,_,R,q4',
        'q5,0,0,R,q5',
        'q5,1,1,R,q6',
        'q6,0,X,R,q7',
        'q6,=,=,L,q9',
        'q7,=,=,R,q7',
        'q7,0,0,R,q7',
        'q7,_,0,L,q8',
        'q8,0,0,L,q8',
        'q8,=,=,L,q8',
        'q8,X,X,R,q6',
        'q9,X,0,L,q9',
        'q9,0,0,L,q9',
        'q9,1,1,L,q9',
        'q9,_,_,R,q2'
      ]
    end

    context 'with small numbers' do
      let(:a) { 2 }
      let(:b) { 4 }

      it 'runs' do
        tape, status = turing_machine.run
        expect(tape.count('0')).to eq a * b
        expect(status).to eq :accepted
      end
    end

    context 'with high numbers' do
      let(:a) { 10 }
      let(:b) { 12 }

      it 'runs' do
        tape, status = turing_machine.run
        expect(tape.count('0')).to eq a * b
        expect(status).to eq :accepted
      end
    end

    context 'when the tape is malformated' do
      let(:tape) { ['0'] * 2 + ['1'] + ['1'] + ['0'] * 3 }

      it 'errors' do
        _, status = turing_machine.run
        expect(status).to eq :rejected
      end
    end
  end
end

# frozen_string_literal: true

class TuringMachine
  SHOW_OUTPUT = true
  attr_accessor :tape, :starting_state, :accepting_states, :step_instructions

  def initialize(attributes = {})
    attributes.map { |key, value| public_send(:"#{key}=", value) }

    @current_position = 0
    @current_state = starting_state
  end

  def run
    status = perform_simulation
    [tape, status]
  end

  private

  def perform_simulation
    loop do
      current_character = tape[@current_position]
      instruction = step_instructions.select { |i| i.start_with?("#{@current_state},#{current_character}") }.first
      return :rejected if instruction.nil?

      perform_step(instruction)
      return :accepted if accepting_states.include?(@current_state)

      print_tape if SHOW_OUTPUT
    end
  end

  def perform_step(step_instruction)
    _, _, write, direction, new_state = step_instruction.split(',')
    tape[@current_position] = write

    @current_position += direction == 'R' ? move_right : move_left
    @current_state = new_state
  end

  def move_right
    tape.append('_') if @current_position >= tape.length - 1
    1
  end

  def move_left
    if @current_position.zero?
      tape.prepend('_')
      0
    else
      -1
    end
  end

  TAPE_PADDING = 50

  def print_tape
    sleep 0.1
    start_position = [0, @current_position - TAPE_PADDING].max
    end_position = [tape.length, @current_position + TAPE_PADDING].min

    print("\r")
    print("#{@current_state}: ")
    print_padding(@current_position - start_position)

    print(tape[start_position..@current_position - 1].join(''))
    print("[#{tape[@current_position]}]")
    print(tape[@current_position + 1..end_position].join(''))

    print_padding(end_position - @current_position)
  end

  def print_padding(padding)
    print((['_'] * (TAPE_PADDING - padding)).join('')) if padding < TAPE_PADDING
  end
end

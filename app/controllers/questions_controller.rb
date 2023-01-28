require 'answer_service.rb'

class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def ask
    @question = params[:question]
    puts "1", @question

    if @question.nil?
      return render json: { error: "No question provided" }, status: 400
    end
    
    @question = @question.downcase

    if !@question.end_with?("?")
      @question = @question + "?"
    end
    puts "2", @question
    
    @already_asked = Question.find_by(question: @question)
    puts "3", @already_asked

    if @already_asked && @already_asked.answer
      puts "Already asked", @already_asked
      @already_asked.ask_count += 1
      @already_asked.save
      return render json: @already_asked
    end

    @answer_service = AnswerService.new

    @response = @answer_service.get_answer(@question)
    puts "4", @response

    if @response[:success]
      @answer = @response[:answer]
      @context = @response[:context]
      @record = Question.create(question: @question, answer: @answer, context: @context)
      puts "5", @record
      @record.save
      return render json: @record
    end

    render json: { error: "No answer found" }, status: 400

  end
end

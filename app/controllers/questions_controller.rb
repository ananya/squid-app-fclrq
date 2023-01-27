require 'answer_service.rb'

class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def ask
    @question = params[:question]
    puts @question

    if @question.nil?
      return render json: { error: "No question provided" }, status: 400
    end
    
    @question = @question.downcase

    if !@question.end_with?("?")
      @question = @question + "?"
    end
    
    @already_asked = Question.find_by(question: @question)
    if @already_asked && @already_asked.answer
      puts "Already asked", @already_asked
      @already_asked.ask_count += 1
      @already_asked.save
      return render json: @already_asked
    end

    @answer_service = AnswerService.new

    @response = @answer_service.get_answer(question)
    if @response[:success]
      @answer = @response[:answer]
      @context = @response[:context]
      @record = Question.create(question: @question, answer: @answer, context: @context)
      @record.save
      return render json: @record
    end

    render json: { error: "No answer found" }, status: 400

  end
end

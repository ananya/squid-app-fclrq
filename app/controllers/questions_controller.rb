class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def ask
    puts "ask method called"
    questions = params[:question]
    puts questions
  end
end

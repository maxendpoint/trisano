require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/edit.html.erb" do
  include QuestionsHelper
  
  before do
    @question = mock_model(Question)
    @question.stub!(:text).and_return("MyString")
    @question.stub!(:help).and_return("MyString")
    @question.stub!(:question_type_id).and_return("1")
    @question.stub!(:group_id).and_return("1")
    @question.stub!(:condition).and_return("1")
    @question.stub!(:follow_up_group_id).and_return("4")
    assigns[:question] = @question
  end

  it "should render edit form" do
    render "/questions/edit.html.haml"
    
    response.should have_tag("form[action=#{question_path(@question)}][method=post]") do
      with_tag('input#question_text[name=?]', "question[text]")
      with_tag('input#question_help[name=?]', "question[help]")
    end
  end
end



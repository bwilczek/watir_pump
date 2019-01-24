# frozen_string_literal: true

RSpec.describe '.inspect' do
  describe '#inspect_properties' do
    class YesNoWidget2 < WatirPump::Component
      # inspect_properties [:result]
      button :yes, data_role: 'btn_yes'
      button :no, data_role: 'btn_no'
      span_reader :result, data_role: 'yes_or_no'
    end

    class QuestionWidget2 < WatirPump::Component
      inspect_properties [:controls]
      span :question, data_role: 'question'
      component :controls, YesNoWidget2

      def for_inspection
        'ready'
      end
    end

    class IndexPage2 < WatirPump::Page
      uri '/index.html'
      components :questions, QuestionWidget2, :divs, data_role: 'question_wrapper'
    end

    specify do
      IndexPage2.open do
        expect do
          questions.inspect
          questions.last.controls.inspect
        end.not_to raise_error
      end
    end
  end
end

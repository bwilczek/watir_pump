# frozen_string_literal: true

require 'forwardable'

require 'watir_pump'

class ProductTable < WatirPump::Component
  extend Forwardable

  delegate Enumerable.instance_methods(false) => :data
  delegate %i[[] empty? each] => :data

  query :cols, -> { node.thead.ths.map(&:text) }

  def data
    column_names = cols
    [].tap do |ret|
      root.tbody.trs.each do |row|
        ret_row = {}
        (0...column_names.count).each do |i|
          ret_row[column_names[i]] = row.tds[i].text
        end
        ret << ret_row
      end
    end
  end
end

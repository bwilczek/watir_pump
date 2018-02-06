# frozen_string_literal: true

require 'watir_pump'

class ProductTable < WatirPump::Component
  query :cols, -> { node.thead.ths.map(&:text) }

  def data
    ret = []
    column_names = cols
    node.tbody.trs.each do |row|
      ret_row = {}
      (0...column_names.count).each do |i|
        ret_row[column_names[i]] = row.tds[i].text
      end
      ret << ret_row
    end
    ret
  end
end

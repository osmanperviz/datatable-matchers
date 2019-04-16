# frozen_string_literal: true
RSpec::Matchers.define :have_cell do |value: nil, match: nil, column:, record:|
  include ActionView::RecordIdentifier
  match do |table|
    return error('The :have_cell matcher requires a RemoteDatatables as object') unless table.is_a? RemoteDatatable

    record_id = dom_id(record)
    row = table.json['data'].find { |data_row| data_row['DT_RowId'] == record_id }

    return error("Datatable has no row with id #{record_id}") unless row
    return error("Datatable has no column named #{column}") unless row.key? column.to_s

    real_value = row[column.to_s]
    if !value.nil?
      return error("value is '#{real_value}', expected '#{value}'") unless real_value == value
    elsif !match.nil?
      return error("value '#{real_value}' does not match #{match}") unless real_value =~ match
    else
      return error('matcher :have_cell needs :value or :match as parameters')
    end

    true
  end

  def error(message)
    @error = message
    false
  end

  failure_message do |_table|
    @error
  end
end

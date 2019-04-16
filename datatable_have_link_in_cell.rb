# frozen_string_literal: true

# this matchers lets you look into a databable and check wether
# it a link to a given URL is at a specific cell.
#
# For example:
#   it 'checks a link' do
#     record = FactoryGirl.create :some_record
#     datatable = remote_datatable('table#some-id')
#     expect(datatable).to have_link_in_cell :column_name,
#                                            to: some_url,
#                                            for_record: dom_id(record)
#   end
RSpec::Matchers.define :have_link_in_cell do |cell_name, to:, for_record:|
  include ActionView::RecordIdentifier
  match do |table|
    @message = 'stub'
    next fail_with(message: 'first argument mus be a RemoteTable') unless table.is_a? RemoteDatatable

    record = table.json['data'].find { |r| r['DT_RowId'] == for_record }
    next fail_with(message: "cant find row #{for_record}") unless record

    raw_cell = record[cell_name.to_s]
    next fail_with(message: "cant find cell #{cell_name} for row #{for_record}") unless raw_cell

    cell = Nokogiri::HTML(cell)
    unless cell.css("a[href=\"#{to}\"]")
      next fail_with(message: "cell #{cell_name} in row #{for_record} does not have link to #{to}")
    end

    true
  end

  def fail_with(message)
    @message = message
    false
  end

  failure_message do |_page|
    @message
  end
end

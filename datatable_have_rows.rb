# frozen_string_literal: true

# this matcher lets you check wether a given datatable has rows for
# a list of records
#
# For example:
#   it 'checks for inclusion of rows' do
#     included_records = FactoryGirl.create_list :record, 3, :good_trait
#     excluded_records = FactoryGirl.create_list :record, 3, :bad_trait
#     datatable = remote_datatable('table#some-id')
#     expect(datatable).to have_rows(include_records)
#     expect(datatable).to_not have_rows(excluded_records)
#   end
RSpec::Matchers.define :have_rows do |*records|
  include ActionView::RecordIdentifier
  match do |table|
    @missing = []
    @found = []
    @total_rows = table.json['recordsTotal']
    records.flatten.each do |record|
      record_id = dom_id(record)
      if table.json['data'].any? { |row| row['DT_RowId'] == record_id }
        @found << record_id
      else
        @missing << record_id
      end
    end
    # useful during spec development
    @other = table.json['data']
                  .collect { |row| row['DT_RowId'] }
                  .reject { |id| (id.in? @found) || (id.in? @missing) }
    @missing.empty?
  end

  failure_message do |_page|
    "These ids dont match:  #{@missing.join(', ')};\n" \
    "found: #{@found.join(', ') || 'none'};\n" \
    "other: #{@other.join(', ') || 'none'};\n" \
    "the result had a total of #{@total_rows} rows."
  end
end

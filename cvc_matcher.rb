# frozen_string_literal: true
# checks that the last loaded page is a csv document
#
# Usage:
#   visit some_url_that_downloads_a_file_path(format: :csv)
#
#   expect(page).to be_a_csv_document(
#     columns: %i[a b c d e},
#     delimiter: ',',
#     row_count: 3
#   )
RSpec::Matchers.define :be_a_csv_document do |**args|
  match do |page|
    expect(page.status_code).to eq(200)
    expect(page.response_headers['Content-Type']).to match(%r{text/(plain|csv)})

    csv_rows = page.body.split(/\n/)

    @errors = []

    if args.key?(:columns) && args.key?(:delimiter)
      columns = args.delete(:columns)
      delimiter = args.delete(:delimiter)
      expected_header = columns.join(delimiter)
      actual_header = csv_rows.first
      if actual_header != expected_header
        @errors << "header should be '#{expected_header}', but was '#{actual_header}'"
      end
    end

    if args.key? :row_count
      expected_row_count = args.delete :row_count
      actual_row_count = csv_rows.size
      if actual_row_count != expected_row_count
        @errors << "shoud have #{expected_row_count} rows, but has #{actual_row_count}"
      end
    end

    @errors << "unknown arguments #{args.keys.join(', ')}" unless args.empty?

    @errors.empty?
  end

  failure_message do |_page|
    return 'no @errors in be_a_csv_document matcher' unless @errors
    @errors.join(', ')
  end
end

# frozen_string_literal: true
class RemoteDatatable
  include ActionView::RecordIdentifier

  attr_accessor :node, :json, :header

  def initialize(node, json_response)
    @node = node
    self.json = JSON.parse(json_response.body)
    self.header = json_response.header
  end

  def url
    @node['data-source']
  end

  def data_for_object(object)
    row_id = dom_id(object)
    json['data'].find do |row|
      row['DT_RowId'] == row_id
    end.except('DT_RowId', 'DT_RowData')
  end

  def valid?
    valid_json? && url && valid_http_header?
  end

  private

  def valid_json?
    @json.key?('recordsTotal') &&
      @json.key?('recordsFiltered') &&
      @json.key?('draw') &&
      @json.key?('data')
  end

  def valid_http_header?
    @header['Content-Type'] == 'application/json; charset=utf-8'
  end
end

# frozen_string_literal: true
module DatatableHelper
  def remote_datatable(selector)
    node = find(selector)
    response = page.driver.browser.get(node['data-source'])
    RemoteDatatable.new(node, response)
  end
end

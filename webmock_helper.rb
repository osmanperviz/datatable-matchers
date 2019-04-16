# frozen_string_literal: true
# Webmock Helper
module WebmockHelper
  def self.allow_report_server_access
    WebMock.disable_net_connect!(allow_localhost: true,
                                 allow: [URI(Settings.reports.server.url).host])
  end

  def allow_net_access(*urls)
    around do |example|
      begin
        WebMock.disable_net_connect!(allow_localhost: true,
                                     allow: urls + [URI(Settings.reports.server.url).host])
        example.call
      ensure
        WebmockHelper.allow_report_server_access
      end
    end
  end

  def disallow_all_net_access
    around do |example|
      begin
        WebMock.disable_net_connect!(allow_localhost: false)
        example.call
      ensure
        WebmockHelper.allow_report_server_access
      end
    end
  end
end

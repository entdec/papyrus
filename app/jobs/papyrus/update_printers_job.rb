module Papyrus
  class UpdatePrintersJob < ApplicationJob
    def perform(user, printers_list)
      printers_list['printersList'].each do |item|
        printer = user.printers.find_or_initialize_by(name: item['name'])
        printer.assign_attributes(default: item['default'], papers: item['papers'], local: item['isLocal'],
                                  shared: item['isShared'], network: item['isNetwork'], connected: item['connected'],
                                  port: item['port'], metadata: item)
        printer.save!
      end
    end
  end
end

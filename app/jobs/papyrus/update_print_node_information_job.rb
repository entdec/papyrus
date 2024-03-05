module Papyrus
  class UpdatePrintNodeInformationJob < ApplicationJob
    def perform
      return unless Papyrus.print_client

      after = nil
      printers = []
      computer_client_ids = []
      printer_client_ids = []

      loop do
        api_str = after ? "/printers?after=#{after}&dir=asc" : '/printers?dir=asc'

        response = Papyrus.print_client.get(api_str)
        raise Papyrus::UpdatePrintNodeInformationException, 'Rate limit Error' if response.code == '429'
        raise Net::HTTPResponseError.new(response.code) if response.code != '200'

        printers = Papyrus.print_client.parse_array_to_struct(::JSON.parse(response.body))
        break if printers.empty?

        printers.each do |p|
          computer = Papyrus::Computer.find_or_initialize_by(client_id: p.computer.id)
          computer.name = p.computer.name
          computer.hostname = p.computer.hostname
          computer.state = p.computer.state
          computer.save!

          computer_client_ids << p.computer.id

          printer = Papyrus::Printer.find_or_initialize_by(client_id: p.id)
          printer.name = p.name
          printer.description = p.description
          printer.state = p.state
          printer.computer = computer
          printer.save!

          printer_client_ids << p.id
        end

        after = printers.last['id']
      end

      computers = Papyrus::Computer.where.not(client_id: computer_client_ids)
      printers = Papyrus::Printer.where.not(client_id: printer_client_ids)

      Papyrus::PreferredPrinter.where(printer_id: printers.map(&:id))
                               .or(Papyrus::PreferredPrinter.where(computer_id: computers.map(&:id))).destroy_all

      printers.destroy_all
      computers.destroy_all
    end
  end
end
